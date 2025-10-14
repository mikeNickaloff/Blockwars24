#include "gamescene.h"

#include "gamedataobject.h"
#include "gameelementstore.h"
#include "gamesignal.h"

#include <QMetaObject>
#include <QMetaProperty>
#include <QMutexLocker>
#include <QQuickItem>
#include <QVariant>

#include <type_traits>

GameScene::GameScene(QQuickItem* parent)
    : AbstractGameElement(parent)
{
}

bool GameScene::addElement(AbstractGameElement* element)
{
    if (!element || element == this)
        return false;

    {
        QMutexLocker locker(&m_elementsMutex);
        for (const auto& existing : std::as_const(m_elements)) {
            if (existing == element)
                return false;
        }

        element->setParent(this);
        element->setParentItem(this);
        m_elements.append(element);
    }

    connect(element, &QObject::destroyed, this, &GameScene::onElementDestroyed, Qt::UniqueConnection);
    emit elementAdded(element);
    return true;
}

bool GameScene::removeElement(AbstractGameElement* element)
{
    if (!element)
        return false;

    bool removed = false;
    {
        QMutexLocker locker(&m_elementsMutex);
        for (int i = m_elements.size() - 1; i >= 0; --i) {
            if (m_elements[i] == element) {
                m_elements.remove(i);
                removed = true;
            }
        }
    }

    if (removed) {
        if (element->parentItem() == this)
            element->setParentItem(nullptr);
        if (element->parent() == this)
            element->setParent(nullptr);
        disconnect(element, &QObject::destroyed, this, &GameScene::onElementDestroyed);
        emit elementRemoved(element);
    }

    return removed;
}

QVariantList GameScene::listElements() const
{
    QVariantList result;

    QMutexLocker locker(&m_elementsMutex);
    for (const auto& pointer : m_elements) {
        if (!pointer)
            continue;
        result.append(QVariant::fromValue(static_cast<QObject*>(pointer.data())));
    }

    return result;
}

AbstractGameElement* GameScene::findElement(const QString& objectName) const
{
    if (objectName.isEmpty())
        return nullptr;

    if (objectName == this->objectName())
        return const_cast<GameScene*>(this);

    QMutexLocker locker(&m_elementsMutex);
    for (const auto& element : m_elements) {
        if (!element)
            continue;
        if (element->objectName() == objectName)
            return element;
        if (AbstractGameElement* child = findElementRecursive(element, objectName))
            return child;
    }

    return nullptr;
}

QVariantMap GameScene::serializeElement(AbstractGameElement* element) const
{
    if (!element)
        return {};
    return element->serialize();
}

QVariantList GameScene::serializeElements() const
{
    QVariantList serialized;
    QMutexLocker locker(&m_elementsMutex);
    for (const auto& element : m_elements) {
        if (!element)
            continue;
        serialized.append(element->serialize());
    }
    return serialized;
}

bool GameScene::unserializeElement(AbstractGameElement* element, const QVariantMap& data)
{
    if (!element)
        return false;
    return element->unserialize(data);
}

bool GameScene::unserializeElements(GameDataObject* obj)
{
    if (!obj)
        return false;

    const QVariantList list = obj->asList();
    if (list.isEmpty())
        return false;

    bool anyApplied = false;
    for (const QVariant& entryVar : list) {
        const QVariantMap map = entryVar.toMap();
        if (map.isEmpty())
            continue;

        const QString objectName = map.value(QStringLiteral("objectName")).toString();
        if (objectName.isEmpty())
            continue;

        AbstractGameElement* element = findElement(objectName);
        if (!element)
            continue;

        if (element->unserialize(map))
            anyApplied = true;
    }

    return anyApplied;
}

bool GameScene::queueEvents(GameElementStore* elementAndSignals)
{
    if (!elementAndSignals)
        return false;

    const QList<GameElementStoreEntry> entries = elementAndSignals->entries();
    if (entries.isEmpty())
        return false;

    bool queued = false;

    for (const GameElementStoreEntry& entry : entries) {
        if (entry.element.isNull())
            continue;

        GameSceneQueuedEvent event;
        event.element = entry.element;

        for (const QPointer<GameSignal>& signal : entry.gsignals) {
            if (signal.isNull() || signal->name().isEmpty())
                continue;
            GameSceneQueuedSignal queuedSignal;
            queuedSignal.name = signal->name();
            queuedSignal.arguments = signal->arguments();
            event.gsignals.append(queuedSignal);
        }

        if (event.gsignals.isEmpty())
            continue;

        {
            QMutexLocker locker(&m_eventMutex);
            m_eventQueue.enqueue(event);
        }
        queued = true;
    }

    if (queued)
        emit queuedEventsAvailable();

    return queued;
}

int GameScene::queuedEventCount() const
{
    QMutexLocker locker(&m_eventMutex);
    return m_eventQueue.size();
}

bool GameScene::dispatchQueuedEvents()
{
    bool dispatchedAny = false;

    while (true) {
        GameSceneQueuedEvent event;
        {
            QMutexLocker locker(&m_eventMutex);
            if (m_eventQueue.isEmpty())
                break;
            event = m_eventQueue.dequeue();
        }

        AbstractGameElement* element = event.element.data();
        if (!element)
            continue;

        for (const GameSceneQueuedSignal& signal : event.gsignals) {
            if (signal.name.isEmpty())
                continue;

            const QByteArray methodName = signal.name.toUtf8();
            QVariantList args = signal.arguments;
            bool invoked = false;

            switch (args.size()) {
            case 0:
                invoked = QMetaObject::invokeMethod(element, methodName.constData(), Qt::QueuedConnection);
                break;
            case 1:
                invoked = QMetaObject::invokeMethod(element, methodName.constData(), Qt::QueuedConnection,
                                                    Q_ARG(QVariant, args.at(0)));
                break;
            case 2:
                invoked = QMetaObject::invokeMethod(element, methodName.constData(), Qt::QueuedConnection,
                                                    Q_ARG(QVariant, args.at(0)), Q_ARG(QVariant, args.at(1)));
                break;
            case 3:
                invoked = QMetaObject::invokeMethod(element, methodName.constData(), Qt::QueuedConnection,
                                                    Q_ARG(QVariant, args.at(0)), Q_ARG(QVariant, args.at(1)),
                                                    Q_ARG(QVariant, args.at(2)));
                break;
            default:
                // Fallback: pass the arguments as a single QVariantList
                invoked = QMetaObject::invokeMethod(element, methodName.constData(), Qt::QueuedConnection,
                                                    Q_ARG(QVariantList, args));
                break;
            }

            dispatchedAny = dispatchedAny || invoked;
        }
    }

    return dispatchedAny;
}

void GameScene::blockGameElementBranch(AbstractGameElement* elem, bool blockBranch)
{
    if (!elem)
        return;

    QList<QQuickItem*> stack;
    stack.append(elem);

    while (!stack.isEmpty()) {
        QQuickItem* item = stack.takeLast();
        if (!item)
            continue;

        item->setEnabled(!blockBranch);

        if (auto* gameElement = qobject_cast<AbstractGameElement*>(item)) {
            gameElement->setExecutionQueuePaused(blockBranch);
        }

        const auto children = item->childItems();
        for (QQuickItem* child : children) {
            stack.append(child);
        }
    }
}

void GameScene::onElementDestroyed(QObject* object)
{
    auto* element = qobject_cast<AbstractGameElement*>(object);
    if (!element)
        return;

    QMutexLocker locker(&m_elementsMutex);
    for (int i = m_elements.size() - 1; i >= 0; --i) {
        if (m_elements[i] == element)
            m_elements.remove(i);
    }
}

AbstractGameElement* GameScene::findElementRecursive(AbstractGameElement* element, const QString& objectName) const
{
    if (!element)
        return nullptr;

    const auto children = element->findChildren<AbstractGameElement*>(QString(), Qt::FindDirectChildrenOnly);
    for (AbstractGameElement* child : children) {
        if (!child)
            continue;
        if (child->objectName() == objectName)
            return child;
        if (AbstractGameElement* nested = findElementRecursive(child, objectName))
            return nested;
    }

    return nullptr;
}

