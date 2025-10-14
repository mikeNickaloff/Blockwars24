#pragma once

#include <QHash>
#include <QList>

class AbstractGameElement;
class GameSignal;

class GameElementsStore
{
public:
    void addSignal(AbstractGameElement *element, const GameSignal &signal);
    void addSignals(AbstractGameElement *element, const QList<GameSignal> &signals);

    const QHash<AbstractGameElement *, QList<GameSignal>> &entries() const;
    bool contains(AbstractGameElement *element) const;
    bool isEmpty() const;
    void clear();

private:
    QHash<AbstractGameElement *, QList<GameSignal>> m_entries;
};
