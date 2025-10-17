import QtQuick
import QtQml.Models
import "."

Item {
    id: controller

    property alias createdPowerupsModel: createdModel
    property string table: "editor_custom_powerups"
    property int _nextIdentifier: 0

    PowerupDataStore {
        id: persistenceAdapter
        table: controller.table
    }

    ListModel {
        id: createdModel
    }

    Component.onCompleted: controller.reload()

    function reload() {
        const persisted = persistenceAdapter ? persistenceAdapter.getPowerupData() : []
        createdModel.clear()
        let nextIdCandidate = 0
        for (let i = 0; i < persisted.length; ++i) {
            const entry = controller._cloneEntry(persisted[i])
            if (entry.id === undefined || entry.id === null || isNaN(entry.id)) {
                entry.id = nextIdCandidate
                nextIdCandidate += 1
            } else {
                entry.id = Math.max(0, Math.floor(entry.id))
                nextIdCandidate = Math.max(nextIdCandidate, entry.id + 1)
            }
            createdModel.append(entry)
        }
        controller._nextIdentifier = nextIdCandidate
    }

    function addPowerup(payload) {
        const entry = controller._cloneEntry(payload)
        entry.id = controller._nextIdentifier
        controller._nextIdentifier += 1
        createdModel.append(entry)
        controller._persistSnapshot()
        return entry.id
    }

    function updatePowerup(identifier, payload) {
        const index = controller._indexOfId(identifier)
        if (index < 0)
            return false
        const entry = controller._cloneEntry(payload)
        entry.id = identifier
        createdModel.set(index, entry)
        controller._persistSnapshot()
        return true
    }

    function getPowerup(identifier) {
        const index = controller._indexOfId(identifier)
        if (index < 0)
            return null
        return controller._cloneEntry(createdModel.get(index))
    }

    function allPowerups() {
        const values = []
        for (let i = 0; i < createdModel.count; ++i)
            values.push(controller._cloneEntry(createdModel.get(i)))
        return values
    }

    function cloneEntry(payload) {
        return controller._cloneEntry(payload)
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
        const sanitizedBlocks = controller._sanitizeBlocks(base.blocks)
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
            snapshot.push(controller._cloneEntry(createdModel.get(i)))
        persistenceAdapter.setPowerupData(snapshot)
    }
}
