#include "GameElementsStore.h"

#include "AbstractGameElement.h"
#include "GameSignal.h"


void GameElementsStore::addSignal(AbstractGameElement *element, const GameSignal &signal)
{
    if (!element || !signal.isValid()) {
        return;
    }

    auto &list = m_entries[element];
    list.append(signal);
}

void GameElementsStore::addSignals(AbstractGameElement *element, const QList<GameSignal> &signals)
{
    if (!element) {
        return;
    }

    QList<GameSignal> filteredSignals;
    filteredSignals.reserve(signals.size());
    for (const auto &signal : signals) {
        if (signal.isValid()) {
            filteredSignals.append(signal);
        }
    }

    if (filteredSignals.isEmpty()) {
        return;
    }

    auto &list = m_entries[element];
    list.append(filteredSignals);
}

const QHash<AbstractGameElement *, QList<GameSignal>> &GameElementsStore::entries() const
{
    return m_entries;
}

bool GameElementsStore::contains(AbstractGameElement *element) const
{
    return m_entries.contains(element);
}

bool GameElementsStore::isEmpty() const
{
    return m_entries.isEmpty();
}

void GameElementsStore::clear()
{
    m_entries.clear();
}
