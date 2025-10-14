#include "gameelementstore.h"

#include "abstractgameelement.h"
#include "gamesignal.h"

GameElementStore::GameElementStore(QObject* parent)
    : QObject(parent)
{
}

void GameElementStore::addElement(AbstractGameElement* element, GameSignal* signal)
{
    if (!element || !signal)
        return;

    if (!signal->parent())
        signal->setParent(this);

    for (auto& entry : m_entries) {
        if (entry.element == element) {
            entry.signals.append(signal);
            emit changed();
            return;
        }
    }

    GameElementStoreEntry entry;
    entry.element = element;
    entry.signals.append(signal);
    m_entries.append(entry);
    emit changed();
}

void GameElementStore::addSignals(AbstractGameElement* element, const QList<GameSignal*>& signals)
{
    if (!element || signals.isEmpty())
        return;

    for (GameSignal* signal : signals) {
        addElement(element, signal);
    }
}

void GameElementStore::clear()
{
    if (m_entries.isEmpty())
        return;

    m_entries.clear();
    emit changed();
}

QList<GameElementStoreEntry> GameElementStore::entries() const
{
    return m_entries;
}
