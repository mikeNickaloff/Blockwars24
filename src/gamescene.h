#ifndef GAMESCENE_H
#define GAMESCENE_H

#include "abstractgameelement.h"

#include <QList>
#include <QMutex>
#include <QPointer>
#include <QQueue>
#include <QVariantList>
#include <QVector>

#include <QtQml/qqmlregistration.h>

class GameDataObject;
class GameElementStore;
class GameSignal;
struct GameElementStoreEntry;

class GameScene : public AbstractGameElement
{
    Q_OBJECT

    QML_ELEMENT

public:
    explicit GameScene(QQuickItem* parent = nullptr);

    Q_INVOKABLE bool addElement(AbstractGameElement* element);
    Q_INVOKABLE bool removeElement(AbstractGameElement* element);
    Q_INVOKABLE QVariantList listElements() const;
    Q_INVOKABLE AbstractGameElement* findElement(const QString& objectName) const;

    Q_INVOKABLE QVariantMap serializeElement(AbstractGameElement* element) const;
    Q_INVOKABLE QVariantList serializeElements() const;
    Q_INVOKABLE bool unserializeElement(AbstractGameElement* element, const QVariantMap& data);
    Q_INVOKABLE bool unserializeElements(GameDataObject* obj);

    Q_INVOKABLE bool queueEvents(GameElementStore* elementAndSignals);
    Q_INVOKABLE int queuedEventCount() const;
    Q_INVOKABLE bool dispatchQueuedEvents();

    Q_INVOKABLE void blockGameElementBranch(AbstractGameElement* elem, bool blockBranch);

signals:
    void elementAdded(AbstractGameElement* element);
    void elementRemoved(AbstractGameElement* element);
    void queuedEventsAvailable();

private slots:
    void onElementDestroyed(QObject* object);

private:
    struct QueuedSignal
    {
        QString name;
        QVariantList arguments;
    };

    struct QueuedEvent
    {
        QPointer<AbstractGameElement> element;
        QList<QueuedSignal> signals;
    };

    AbstractGameElement* findElementRecursive(AbstractGameElement* element, const QString& objectName) const;

    mutable QMutex m_elementsMutex;
    mutable QVector<QPointer<AbstractGameElement>> m_elements;

    mutable QMutex m_eventMutex;
    mutable QQueue<QueuedEvent> m_eventQueue;
};

#endif // GAMESCENE_H
