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
            entry.gsignals.append(signal);
            emit changed();
            return;
        }
    }

    GameElementStoreEntry entry;
    entry.element = element;
    entry.gsignals.append(signal);
    m_entries.append(entry);
    emit changed();
}

void GameElementStore::addSignals(AbstractGameElement* element, const QList<GameSignal*>& gsignals)
{
    if (!element || gsignals.isEmpty())
        return;

    for (GameSignal* signal : gsignals) {
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
