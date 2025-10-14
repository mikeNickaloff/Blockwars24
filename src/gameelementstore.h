#ifndef GAMEELEMENTSTORE_H
#define GAMEELEMENTSTORE_H

#include <QObject>
#include <QPointer>
#include <QVector>
#include <QList>

#include <QtQml/qqmlregistration.h>

class AbstractGameElement;
class GameSignal;

struct GameElementStoreEntry
{
    QPointer<AbstractGameElement> element;
    QList<QPointer<GameSignal>> signals;
};

class GameElementStore : public QObject
{
    Q_OBJECT

    QML_ELEMENT

public:
    explicit GameElementStore(QObject* parent = nullptr);

    Q_INVOKABLE void addElement(AbstractGameElement* element, GameSignal* signal);
    Q_INVOKABLE void addSignals(AbstractGameElement* element, const QList<GameSignal*>& signals);
    Q_INVOKABLE void clear();

    QList<GameElementStoreEntry> entries() const;

signals:
    void changed();

private:
    QList<GameElementStoreEntry> m_entries;
};

#endif // GAMEELEMENTSTORE_H
