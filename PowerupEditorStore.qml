import QtQuick
import QtQml.Models
import "."

Item {
    id: store

    property alias createdPowerupsModel: createdModel

    property int _nextId: 0
    readonly property string persistenceTable: "editor_custom_powerups"

    PowerupDataStore {
        id: persistenceAdapter
        table: store.persistenceTable
    }

    ListModel {
        id: createdModel
    }

    Component.onCompleted: store._loadPersistedPowerups()

    function addPowerup(payload) {
        const entry = store._cloneEntry(payload)
        entry.id = store._nextId
        store._nextId += 1
        createdModel.append(entry)
        store._persistSnapshot()
        return entry.id
    }

    function updatePowerup(identifier, payload) {
        const index = store._indexOfId(identifier)
        if (index < 0)
            return false
        const entry = store._cloneEntry(payload)
        entry.id = identifier
        createdModel.set(index, entry)
        store._persistSnapshot()
        return true
    }

    function getPowerup(identifier) {
        const index = store._indexOfId(identifier)
        if (index < 0)
            return null
        return store._cloneEntry(createdModel.get(index))
    }

    function allPowerups() {
        const values = []
        for (let i = 0; i < createdModel.count; ++i)
            values.push(store._cloneEntry(createdModel.get(i)))
        return values
    }

    function _indexOfId(identifier) {
        const count = createdModel.count
        for (let i = 0; i < count; ++i) {
            const candidate = createdModel.get(i)
            if (candidate && candidate.id === identifier)
                return i
        }
        return -1
    }

    function _cloneEntry(payload) {
        const base = Object.assign({}, payload || {})
        const sanitizedBlocks = store._sanitizeBlocks(base.blocks)
        base.blocks = sanitizedBlocks
        base.blockCount = sanitizedBlocks.length
        if (base.id !== undefined && base.id !== null)
            base.id = Number(base.id)
        return base
    }

    function _sanitizeBlocks(blocks) {
        const source = Array.isArray(blocks) ? blocks : []
        const seen = {}
        const sanitized = []
        for (let i = 0; i < source.length; ++i) {
            const cell = source[i]
            if (!cell)
                continue
            const row = Math.max(0, Math.min(5, Number(cell.row)))
            const column = Math.max(0, Math.min(5, Number(cell.column)))
            const key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        return sanitized
    }

    function _persistSnapshot() {
        if (!persistenceAdapter)
            return
        const snapshot = []
        for (let i = 0; i < createdModel.count; ++i)
            snapshot.push(store._cloneEntry(createdModel.get(i)))
        persistenceAdapter.setPowerupData(snapshot)
    }

    function _loadPersistedPowerups() {
        if (!persistenceAdapter)
            return
        const persisted = persistenceAdapter.getPowerupData()
        createdModel.clear()
        let nextIdCandidate = 0
        for (let i = 0; i < persisted.length; ++i) {
            const entry = store._cloneEntry(persisted[i])
            if (entry.id === undefined || entry.id === null || isNaN(entry.id)) {
                entry.id = nextIdCandidate
                nextIdCandidate += 1
            } else {
                entry.id = Math.max(0, Math.floor(entry.id))
                nextIdCandidate = Math.max(nextIdCandidate, entry.id + 1)
            }
            createdModel.append(entry)
        }
        store._nextId = nextIdCandidate
    }
}
