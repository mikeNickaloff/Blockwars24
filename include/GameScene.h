#pragma once

#include "AbstractGameElement.h"
#include "GameDataObject.h"
#include "GameElementsStore.h"
#include "GameSignal.h"

#include <QHash>
#include <QList>
#include <QPair>
#include <QPointer>
#include <QQueue>
#include <QVariantList>

#include <QtQml/qqmlregistration.h>

#include <functional>

class GameScene : public AbstractGameElement
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool hasQueuedEvents READ hasQueuedEvents NOTIFY queuedEventsChanged FINAL)

public:
    explicit GameScene(const QString &name = QString(), QObject *parent = nullptr);

    using TraversalDirective = AbstractGameElement::TraversalDirective;

    Q_INVOKABLE QObject *addElement(QObject *element, QObject *parent = nullptr);
    Q_INVOKABLE bool removeElement(QObject *element);
    AbstractGameElement *addElement(AbstractGameElement *element, AbstractGameElement *parent = nullptr);
    bool removeElement(AbstractGameElement *element);
    QList<AbstractGameElement *> listElements(bool includeDescendants = true) const;
    AbstractGameElement *findElement(const QString &elementId) const;
    AbstractGameElement *findElement(const std::function<bool(const AbstractGameElement *)> &predicate) const;

    Q_INVOKABLE QObject *findElementById(const QString &elementId) const;
    Q_INVOKABLE QVariantList listElementIds(bool includeDescendants = true) const;

    QVariantMap serializeElement(const AbstractGameElement *element) const;
    QVariantList serializeElements(const QList<AbstractGameElement *> &elements) const;
    Q_INVOKABLE QVariantMap serializeElementById(const QString &elementId) const;
    Q_INVOKABLE QVariantList serializeAllElements(bool includeDescendants = true) const;

    AbstractGameElement *unserializeElement(const GameDataObject &object, AbstractGameElement *parent = nullptr);
    QList<AbstractGameElement *> unserializeElements(const GameDataObject &object, AbstractGameElement *parent = nullptr);
    Q_INVOKABLE QObject *unserializeElement(const QVariantMap &data, QObject *parent = nullptr);
    Q_INVOKABLE QList<QObject *> unserializeElements(const QVariantList &objects, QObject *parent = nullptr);

    void queueEvents(const GameElementsStore &elementAndSignals);
    bool hasQueuedEvents() const;
    QPair<AbstractGameElement *, GameSignal> dequeueEvent();
    Q_INVOKABLE QVariantMap dequeueSerializedEvent();
    Q_INVOKABLE void clearQueuedEvents();

    void blockGameElementBranch(AbstractGameElement *element, bool blockBranch);
    Q_INVOKABLE bool blockBranchById(const QString &elementId, bool blockBranch);

signals:
    void queuedEventsChanged();
    void elementAdded(AbstractGameElement *element);
    void elementRemoved(AbstractGameElement *element);
    void elementDeserialized(AbstractGameElement *element);

private:
    bool containsElement(const AbstractGameElement *element) const;
    bool adoptElement(AbstractGameElement *element, AbstractGameElement *parent);
    AbstractGameElement *ensureElement(QObject *object) const;
    QVariantMap serializeQueuedEvent(const QPair<AbstractGameElement *, GameSignal> &event) const;
    void enqueueSignal(AbstractGameElement *element, const GameSignal &signal);
    void registerElement(AbstractGameElement *element);
    void unregisterElement(AbstractGameElement *element);
    void handleChildAdded(AbstractGameElement *parent, AbstractGameElement *child);
    void handleChildRemoved(AbstractGameElement *parent, AbstractGameElement *child);
    void handleElementDestroyed(AbstractGameElement *element);
    void handleElementIdChanged(AbstractGameElement *element);
    QString ensureUniqueId(AbstractGameElement *element);
    bool isKnownElement(const AbstractGameElement *element) const;

protected:
    virtual AbstractGameElement *createElement(const QVariantMap &data) const;

    using QueuedSignal = QPair<QPointer<AbstractGameElement>, GameSignal>;
    QQueue<QueuedSignal> m_eventQueue;
    struct ElementConnections {
        QMetaObject::Connection idChanged;
        QMetaObject::Connection childAdded;
        QMetaObject::Connection childRemoved;
        QMetaObject::Connection destroyed;
    };
    QHash<AbstractGameElement *, ElementConnections> m_connections;
    QHash<QString, QPointer<AbstractGameElement>> m_elementIndex;
    QHash<AbstractGameElement *, QString> m_reverseIndex;
};
