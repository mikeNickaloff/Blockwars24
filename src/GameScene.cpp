#include "GameScene.h"

#include <QMetaType>
#include <QVariantList>
#include <QVariantMap>

namespace {
constexpr auto ELEMENTS_KEY = "elements";
constexpr auto CHILDREN_KEY = "children";
constexpr auto NAME_KEY = "name";
}

GameScene::GameScene(const QString &name, QObject *parent)
    : AbstractGameElement(name, parent)
{
    qRegisterMetaType<GameSignal>("GameSignal");
}

QObject *GameScene::addElement(QObject *element, QObject *parent)
{
    auto *gameElement = ensureElement(element);
    auto *gameParent = parent ? ensureElement(parent) : nullptr;
    return addElement(gameElement, gameParent);
}

bool GameScene::removeElement(QObject *element)
{
    return removeElement(ensureElement(element));
}

AbstractGameElement *GameScene::addElement(AbstractGameElement *element, AbstractGameElement *parent)
{
    if (!element || element == this) {
        return nullptr;
    }

    AbstractGameElement *targetParent = parent ? parent : this;
    if (!containsElement(targetParent)) {
        return nullptr;
    }

    if (!adoptElement(element, targetParent)) {
        return nullptr;
    }

    emit elementAdded(element);
    return element;
}

bool GameScene::removeElement(AbstractGameElement *element)
{
    if (!element || element == this || !containsElement(element)) {
        return false;
    }

    AbstractGameElement *parent = element->parentElement();
    if (!parent) {
        parent = this;
    }

    const bool removed = parent->removeChildElement(element);
    if (removed) {
        emit elementRemoved(element);
    }
    return removed;
}

QList<AbstractGameElement *> GameScene::listElements(bool includeDescendants) const
{
    if (!includeDescendants) {
        return childElements();
    }

    QList<AbstractGameElement *> elements;
    forEachDescendant([&](AbstractGameElement *candidate) {
        if (candidate != this) {
            elements.append(candidate);
        }
        return TraversalDirective::Continue;
    });
    return elements;
}

AbstractGameElement *GameScene::findElement(const QString &elementId) const
{
    if (elementId.isEmpty()) {
        return nullptr;
    }

    return findElement([&](const AbstractGameElement *element) {
        return element->elementId() == elementId;
    });
}

AbstractGameElement *GameScene::findElement(const std::function<bool(const AbstractGameElement *)> &predicate) const
{
    if (!predicate) {
        return nullptr;
    }

    if (predicate(this)) {
        return const_cast<GameScene *>(this);
    }

    AbstractGameElement *result = nullptr;
    forEachDescendant([&](AbstractGameElement *candidate) {
        if (!candidate) {
            return TraversalDirective::Continue;
        }
        if (predicate(candidate)) {
            result = candidate;
            return TraversalDirective::Stop;
        }
        return TraversalDirective::Continue;
    });
    return result;
}

QObject *GameScene::findElementById(const QString &elementId) const
{
    return findElement(elementId);
}

QVariantList GameScene::listElementIds(bool includeDescendants) const
{
    QVariantList ids;
    const auto elements = listElements(includeDescendants);
    ids.reserve(elements.size());
    for (const auto *element : elements) {
        if (!element) {
            continue;
        }
        ids.append(element->elementId());
    }
    return ids;
}

QVariantMap GameScene::serializeElement(const AbstractGameElement *element) const
{
    if (!element || !containsElement(element)) {
        return {};
    }

    return element->serialize();
}

QVariantList GameScene::serializeElements(const QList<AbstractGameElement *> &elements) const
{
    QVariantList serialized;
    serialized.reserve(elements.size());
    for (const auto *element : elements) {
        if (!element) {
            continue;
        }
        serialized.append(serializeElement(element));
    }
    return serialized;
}

QVariantMap GameScene::serializeElementById(const QString &elementId) const
{
    return serializeElement(findElement(elementId));
}

QVariantList GameScene::serializeAllElements(bool includeDescendants) const
{
    return serializeElements(listElements(includeDescendants));
}

AbstractGameElement *GameScene::unserializeElement(const GameDataObject &object, AbstractGameElement *parent)
{
    if (!object.isValid()) {
        return nullptr;
    }

    AbstractGameElement *targetParent = parent ? parent : this;
    if (!containsElement(targetParent)) {
        return nullptr;
    }

    auto *element = createElement(object.data());
    if (!element) {
        return nullptr;
    }

    if (!addElement(element, targetParent)) {
        element->deleteLater();
        return nullptr;
    }

    const auto childrenVariant = object.value(CHILDREN_KEY).toList();
    for (const auto &childVariant : childrenVariant) {
        if (!childVariant.canConvert<QVariantMap>()) {
            continue;
        }
        GameDataObject childObject(childVariant.toMap());
        unserializeElement(childObject, element);
    }

    emit elementDeserialized(element);
    return element;
}

QList<AbstractGameElement *> GameScene::unserializeElements(const GameDataObject &object, AbstractGameElement *parent)
{
    QList<AbstractGameElement *> createdElements;
    if (!object.isValid()) {
        return createdElements;
    }

    const QVariantMap &data = object.data();
    if (data.contains(ELEMENTS_KEY)) {
        const auto elementsVariant = data.value(ELEMENTS_KEY).toList();
        for (const auto &entry : elementsVariant) {
            if (!entry.canConvert<QVariantMap>()) {
                continue;
            }
            GameDataObject elementObject(entry.toMap());
            if (auto *element = unserializeElement(elementObject, parent)) {
                createdElements.append(element);
            }
        }
    } else {
        if (auto *element = unserializeElement(object, parent)) {
            createdElements.append(element);
        }
    }

    return createdElements;
}

QObject *GameScene::unserializeElement(const QVariantMap &data, QObject *parent)
{
    return unserializeElement(GameDataObject(data), ensureElement(parent));
}

QList<QObject *> GameScene::unserializeElements(const QVariantList &objects, QObject *parent)
{
    QList<QObject *> created;
    AbstractGameElement *parentElement = ensureElement(parent);
    for (const auto &entry : objects) {
        if (!entry.canConvert<QVariantMap>()) {
            continue;
        }
        if (auto *element = unserializeElement(GameDataObject(entry.toMap()), parentElement)) {
            created.append(element);
        }
    }
    return created;
}

void GameScene::queueEvents(const GameElementsStore &elementAndSignals)
{
    const auto &entries = elementAndSignals.entries();
    for (auto it = entries.cbegin(); it != entries.cend(); ++it) {
        AbstractGameElement *element = it.key();
        if (!element || !containsElement(element) || element->isBlocked()) {
            continue;
        }

        const auto &signals = it.value();
        for (const auto &signal : signals) {
            enqueueSignal(element, signal);
        }
    }
}

bool GameScene::hasQueuedEvents() const
{
    return !m_eventQueue.isEmpty();
}

QPair<AbstractGameElement *, GameSignal> GameScene::dequeueEvent()
{
    if (m_eventQueue.isEmpty()) {
        return {nullptr, {}};
    }

    const auto queued = m_eventQueue.dequeue();
    if (m_eventQueue.isEmpty()) {
        emit queuedEventsChanged();
    }
    return {queued.first.data(), queued.second};
}

QVariantMap GameScene::dequeueSerializedEvent()
{
    return serializeQueuedEvent(dequeueEvent());
}

void GameScene::clearQueuedEvents()
{
    if (m_eventQueue.isEmpty()) {
        return;
    }
    m_eventQueue.clear();
    emit queuedEventsChanged();
}

void GameScene::blockGameElementBranch(AbstractGameElement *element, bool blockBranch)
{
    if (!element) {
        element = this;
    }

    if (!containsElement(element)) {
        return;
    }

    element->setBlocked(blockBranch);
    element->forEachDescendant([&](AbstractGameElement *child) {
        if (child) {
            child->setBlocked(blockBranch);
        }
        return TraversalDirective::Continue;
    });
}

bool GameScene::blockBranchById(const QString &elementId, bool blockBranch)
{
    if (auto *element = findElement(elementId)) {
        blockGameElementBranch(element, blockBranch);
        return true;
    }
    return false;
}

bool GameScene::containsElement(const AbstractGameElement *element) const
{
    return element && (element == this || element->isDescendantOf(this));
}

bool GameScene::adoptElement(AbstractGameElement *element, AbstractGameElement *parent)
{
    if (!element || !parent) {
        return false;
    }

    if (parent == element || parent->isDescendantOf(element)) {
        return false;
    }

    return parent->addChildElement(element);
}

AbstractGameElement *GameScene::ensureElement(QObject *object) const
{
    return qobject_cast<AbstractGameElement *>(object);
}

QVariantMap GameScene::serializeQueuedEvent(const QPair<AbstractGameElement *, GameSignal> &event) const
{
    QVariantMap serialized;
    if (!event.first || !event.second.isValid()) {
        return serialized;
    }

    serialized.insert(QStringLiteral("elementId"), event.first->elementId());
    serialized.insert(QStringLiteral("signal"), event.second.toVariantMap());
    return serialized;
}

void GameScene::enqueueSignal(AbstractGameElement *element, const GameSignal &signal)
{
    if (!element || !containsElement(element) || !signal.isValid()) {
        return;
    }

    const bool wasEmpty = m_eventQueue.isEmpty();
    m_eventQueue.enqueue({element, signal});
    if (wasEmpty) {
        emit queuedEventsChanged();
    }
}

AbstractGameElement *GameScene::createElement(const QVariantMap &data) const
{
    auto *element = new AbstractGameElement(data.value(NAME_KEY).toString());
    element->deserialize(data);
    return element;
}
