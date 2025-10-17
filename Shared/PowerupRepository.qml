import QtQuick
import QtQml.Models
import "./"

QtObject {
    id: repository

    property alias model: _powerupModel
    property string scope: "editor_custom_powerups"
    property var entries: []

    property var persistence: PowerupDataStore {
        scope: repository.scope
    }

    property var energyModel: PowerupEnergyModel {}

    ListModel {
        id: _powerupModel
    }

    Component.onCompleted: reload()
    onScopeChanged: reload()

    function reload() {
        const loaded = persistence.loadAll()
        const normalized = []
        _powerupModel.clear()
        let nextId = 0
        for (let i = 0; i < loaded.length; ++i) {
            const entry = _normalizeEntry(loaded[i])
            entry.id = nextId
            nextId += 1
            normalized.push(entry)
            _powerupModel.append(entry)
        }
        entries = normalized
    }

    function addPowerup(specification) {
        const entry = _normalizeEntry(specification)
        entry.id = _powerupModel.count
        _powerupModel.append(entry)
        entries = _collectEntries()
        _persist()
        return entry
    }

    function updatePowerup(identifier, specification) {
        const index = _indexForId(identifier)
        if (index < 0)
            return false
        const current = _powerupModel.get(index)
        const merged = Object.assign({ id: identifier }, specification || {}, { id: identifier })
        const entry = _normalizeEntry(merged)
        entry.id = identifier
        _powerupModel.set(index, entry)
        entries = _collectEntries()
        _persist()
        return true
    }

    function entryForId(identifier) {
        const index = _indexForId(identifier)
        if (index < 0)
            return null
        return _powerupModel.get(index)
    }

    function _collectEntries() {
        const list = []
        for (let i = 0; i < _powerupModel.count; ++i)
            list.push(_normalizeEntry(_powerupModel.get(i)))
        return list
    }

    function _persist() {
        persistence.replaceAll(entries)
    }

    function _normalizeEntry(source) {
        const draft = source || {}
        const colorDetails = _colorForKey(draft.colorKey)
        const typeDetails = _typeForKey(draft.typeKey)
        const targetDetails = _targetForKey(draft.targetKey)
        const sanitizedBlocks = _sanitizeBlocks(draft.blocks)
        const hp = Math.round(Math.max(0, Number(draft.hp || 0)))
        const blockCount = sanitizedBlocks.length === 0 ? Math.max(1, Number(draft.blockCount || 0)) : sanitizedBlocks.length

        return {
            id: draft.id !== undefined ? draft.id : -1,
            typeKey: typeDetails.key,
            typeLabel: typeDetails.label,
            targetKey: targetDetails.key,
            targetLabel: targetDetails.label,
            colorKey: colorDetails.key,
            colorLabel: colorDetails.label,
            colorHex: colorDetails.hex,
            hp: hp,
            blockCount: blockCount,
            blocks: sanitizedBlocks,
            energy: energyModel.estimateEnergy({
                        hp: hp,
                        blockCount: Math.max(1, blockCount),
                        typeKey: typeDetails.key,
                        targetKey: targetDetails.key
                    })
        }
    }

    function _sanitizeBlocks(blocks) {
        const source = Array.isArray(blocks) ? blocks : []
        const sanitized = []
        const seen = {}
        for (let i = 0; i < source.length; ++i) {
            const candidate = source[i]
            if (!candidate)
                continue
            const row = Math.max(0, Math.min(5, Math.floor(Number(candidate.row))))
            const column = Math.max(0, Math.min(5, Math.floor(Number(candidate.column))))
            const key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        return sanitized
    }

    function _colorForKey(key) {
        const map = {
            red: { key: "red", label: qsTr("Red"), hex: "#ef4444" },
            blue: { key: "blue", label: qsTr("Blue"), hex: "#3b82f6" },
            green: { key: "green", label: qsTr("Green"), hex: "#22c55e" },
            yellow: { key: "yellow", label: qsTr("Yellow"), hex: "#facc15" }
        }
        return map[key] || map.red
    }

    function _typeForKey(key) {
        const map = {
            enemy: { key: "enemy", label: qsTr("Enemy") },
            self: { key: "self", label: qsTr("Self") }
        }
        return map[key] || map.enemy
    }

    function _targetForKey(key) {
        const map = {
            blocks: { key: "blocks", label: qsTr("Blocks") },
            heroes: { key: "heroes", label: qsTr("Hero Units") },
            players: { key: "players", label: qsTr("Player Health") }
        }
        return map[key] || map.blocks
    }

    function _indexForId(identifier) {
        const targetId = Number(identifier)
        if (isNaN(targetId))
            return -1
        for (let i = 0; i < _powerupModel.count; ++i) {
            const candidate = _powerupModel.get(i)
            if (candidate && Number(candidate.id) === targetId)
                return i
        }
        return -1
    }
}
