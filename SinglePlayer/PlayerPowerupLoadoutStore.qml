import QtQuick
import QtQml.Models
import "../Shared"

Item {
    id: store

    property int slotCount: 4
    property alias model: loadoutModel
    readonly property bool ready: _computeReady()

    signal loadoutChanged()

    visible: false
    width: 0
    height: 0

    PowerupDataStore {
        id: persistence
        tableName: "single_player_loadout"
    }

    PowerupEnergyModel {
        id: energyModel
    }

    ListModel {
        id: loadoutModel
    }

    Component.onCompleted: reload()
    onSlotCountChanged: _ensureSlotCapacity()

    function reload() {
        loadoutModel.clear()
        const persisted = persistence.loadAll()
        const sanitized = _sanitizeEntries(persisted)
        for (let i = 0; i < Math.max(slotCount, sanitized.length); ++i) {
            const entry = i < sanitized.length ? sanitized[i] : _blankEntry(i)
            loadoutModel.append(entry)
        }
        _persist()
        loadoutChanged()
    }

    function setSlot(index, payload) {
        if (index < 0 || index >= slotCount)
            return
        const entry = payload ? _normalize(payload, index) : _blankEntry(index)
        loadoutModel.set(index, entry)
        _persist()
        loadoutChanged()
    }

    function clearSlot(index) {
        if (index < 0 || index >= slotCount)
            return
        loadoutModel.set(index, _blankEntry(index))
        _persist()
        loadoutChanged()
    }

    function loadoutSnapshot() {
        const list = []
        for (let i = 0; i < loadoutModel.count; ++i) {
            const entry = loadoutModel.get(i)
            if (entry && entry.filled)
                list.push(entry.payload)
        }
        return list
    }

    function _ensureSlotCapacity() {
        const current = loadoutModel.count
        if (current === slotCount)
            return
        if (current > slotCount) {
            while (loadoutModel.count > slotCount)
                loadoutModel.remove(loadoutModel.count - 1)
        } else {
            for (let i = current; i < slotCount; ++i)
                loadoutModel.append(_blankEntry(i))
        }
        _persist()
        loadoutChanged()
    }

    function _computeReady() {
        if (loadoutModel.count === 0)
            return false
        for (let i = 0; i < Math.min(slotCount, loadoutModel.count); ++i) {
            const entry = loadoutModel.get(i)
            if (!entry || !entry.filled)
                return false
        }
        return true
    }

    function _sanitizeEntries(entries) {
        const source = Array.isArray(entries) ? entries : []
        const sanitized = []
        for (let i = 0; i < source.length; ++i)
            sanitized.push(_normalize(source[i], i))
        return sanitized
    }

    function _normalize(raw, slotIndex) {
        const draft = raw || {}
        const sanitizedBlocks = _sanitizeBlocks(draft.blocks)
        const hp = Math.max(0, Math.round(Number(draft.hp || 0)))
        const blockCount = sanitizedBlocks.length === 0 ? Math.max(1, Number(draft.blockCount || 0)) : sanitizedBlocks.length
        const payload = {
            typeKey: draft.typeKey || "enemy",
            typeLabel: draft.typeLabel || qsTr("Assault"),
            targetKey: draft.targetKey || "blocks",
            targetLabel: draft.targetLabel || qsTr("Blocks"),
            colorKey: draft.colorKey || "red",
            colorLabel: draft.colorLabel || qsTr("Red"),
            colorHex: draft.colorHex || "#ef4444",
            hp: hp,
            blockCount: blockCount,
            blocks: sanitizedBlocks,
            energy: energyModel.estimateEnergy({
                        hp: hp,
                        blockCount: Math.max(1, blockCount),
                        typeKey: draft.typeKey || "enemy",
                        targetKey: draft.targetKey || "blocks"
                    })
        }
        return {
            slotIndex: slotIndex,
            filled: payload.typeKey !== "",
            payload: payload
        }
    }

    function _blankEntry(index) {
        return {
            slotIndex: index,
            filled: false,
            payload: {
                typeKey: "",
                typeLabel: "",
                targetKey: "",
                targetLabel: "",
                colorKey: "",
                colorLabel: "",
                colorHex: "#1f2937",
                hp: 0,
                blockCount: 0,
                blocks: [],
                energy: 0
            }
        }
    }

    function _sanitizeBlocks(blocks) {
        const source = Array.isArray(blocks) ? blocks : []
        const sanitized = []
        const seen = {}
        for (let i = 0; i < source.length; ++i) {
            const cell = source[i]
            if (!cell)
                continue
            const row = Math.max(0, Math.min(5, Math.floor(Number(cell.row))))
            const column = Math.max(0, Math.min(5, Math.floor(Number(cell.column))))
            const key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        return sanitized
    }

    function _persist() {
        const snapshot = []
        for (let i = 0; i < loadoutModel.count; ++i)
            snapshot.push(loadoutModel.get(i).payload)
        persistence.replaceAll(snapshot)
    }
}
