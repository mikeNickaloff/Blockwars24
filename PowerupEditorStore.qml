import QtQuick
import QtQuick.LocalStorage
import QtQml.Models

QtObject {
    id: root

    property alias createdPowerupsModel: root.createdPowerups

    // Full powerup payloads are cached separately from the ListModel so we can
    // preserve complex data (like the selected block coordinates) without
    // violating ListModel's simple-role requirements.
    property var powerupCache: ({})

    readonly property string databaseName: "BlockwarsPowerups"
    readonly property string tableName: "powerups"

    readonly property var typeOptions: [
        { key: "enemy", label: qsTr("Enemy") },
        { key: "self", label: qsTr("Self") }
    ]

    readonly property var targetOptions: [
        { key: "blocks", label: qsTr("Blocks") },
        { key: "heroes", label: qsTr("Hero(s)") },
        { key: "player", label: qsTr("Player Health") }
    ]

    readonly property var colorOptions: [
        { key: "red", label: qsTr("Red"), color: "#ef4444" },
        { key: "green", label: qsTr("Green"), color: "#22c55e" },
        { key: "blue", label: qsTr("Blue"), color: "#3b82f6" },
        { key: "yellow", label: qsTr("Yellow"), color: "#eab308" }
    ]

    property var createdPowerups: ListModel {
        dynamicRoles: true
    }

    Component.onCompleted: initialize()

    function initialize() {
        ensureTable()
        loadPowerups()
    }

    function ensureTable() {
        var db = openDatabase()
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + root.tableName + " (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL)")
        })
    }

    function openDatabase() {
        return LocalStorage.openDatabaseSync(root.databaseName, "1.0", "Blockwars powerup data", 1024 * 1024)
    }

    function loadPowerups() {
        createdPowerups.clear()
        powerupCache = ({})
        var db = openDatabase()
        db.transaction(function(tx) {
            var result = tx.executeSql("SELECT id, data FROM " + root.tableName + " ORDER BY id DESC")
            for (var i = 0; i < result.rows.length; ++i) {
                var row = result.rows.item(i)
                var payload = {}
                try {
                    payload = JSON.parse(row.data)
                } catch (error) {
                    payload = {}
                }
                var normalized = normalizePowerup(payload)
                normalized.powerupId = row.id
                normalized.energy = energyForPowerup(normalized)
                cachePowerup(normalized.powerupId, normalized)
                createdPowerups.append(summarizePowerup(normalized))
            }
        })
    }

    function addPowerup(powerup) {
        var normalized = normalizePowerup(powerup)
        var db = openDatabase()
        var insertedId = -1
        db.transaction(function(tx) {
            var result = tx.executeSql("INSERT INTO " + root.tableName + " (data) VALUES (?)", [JSON.stringify(normalized)])
            insertedId = result.insertId
        })
        normalized.powerupId = insertedId
        normalized.energy = energyForPowerup(normalized)
        cachePowerup(normalized.powerupId, normalized)
        createdPowerups.insert(0, summarizePowerup(normalized))
        return insertedId
    }

    function updatePowerup(id, powerup) {
        if (id === undefined || id === null || id < 0)
            return
        var normalized = normalizePowerup(powerup)
        var db = openDatabase()
        db.transaction(function(tx) {
            tx.executeSql("UPDATE " + root.tableName + " SET data = ? WHERE id = ?", [JSON.stringify(normalized), id])
        })
        var index = indexForId(id)
        if (index >= 0) {
            normalized.powerupId = id
            normalized.energy = energyForPowerup(normalized)
            cachePowerup(id, normalized)
            createdPowerups.set(index, summarizePowerup(normalized))
        }
    }

    function getPowerupById(id) {
        var cached = powerupCache[id]
        if (cached)
            return deepCopyPowerup(cached)

        var db = openDatabase()
        var loaded = null
        db.transaction(function(tx) {
            var result = tx.executeSql("SELECT id, data FROM " + root.tableName + " WHERE id = ?", [id])
            if (result.rows.length === 0)
                return
            var row = result.rows.item(0)
            var payload = {}
            try {
                payload = JSON.parse(row.data)
            } catch (error) {
                payload = {}
            }
            var normalized = normalizePowerup(payload)
            normalized.powerupId = row.id
            normalized.energy = energyForPowerup(normalized)
            cachePowerup(normalized.powerupId, normalized)
            loaded = deepCopyPowerup(normalized)
        })
        return loaded
    }

    function indexForId(id) {
        for (var i = 0; i < createdPowerups.count; ++i) {
            var entry = createdPowerups.get(i)
            if (entry.powerupId === id)
                return i
        }
        return -1
    }

    function normalizePowerup(raw) {
        var type = resolveOption(raw.typeKey, raw.typeLabel || raw.type, root.typeOptions, "enemy")
        var target = resolveOption(raw.targetKey, raw.targetLabel || raw.target, root.targetOptions, "blocks")
        var color = resolveOption(raw.colorKey, raw.colorLabel || raw.color, root.colorOptions, "red")

        var hpValue = Number(raw.hp)
        if (isNaN(hpValue))
            hpValue = 0
        hpValue = Math.max(0, Math.round(hpValue))

        var blocks = []
        if (raw.blocks && raw.blocks.length) {
            for (var i = 0; i < raw.blocks.length; ++i) {
                var block = raw.blocks[i]
                if (!block)
                    continue
                var row = Number(block.row)
                var column = Number(block.column)
                if (isNaN(row) || isNaN(column))
                    continue
                blocks.push({ row: Math.max(0, Math.floor(row)), column: Math.max(0, Math.floor(column)) })
            }
        }

        return {
            typeKey: type.key,
            typeLabel: type.label,
            targetKey: target.key,
            targetLabel: target.label,
            colorKey: color.key,
            colorLabel: color.label,
            colorHex: color.color || colorHexForKey(color.key),
            hp: hpValue,
            blocks: blocks
        }
    }

    function resolveOption(key, label, options, fallbackKey) {
        var option = optionByKey(options, key)
        if (!option && label)
            option = optionByLabel(options, label)
        if (!option)
            option = optionByKey(options, fallbackKey)
        if (!option && options.length > 0)
            option = options[0]
        return option || { key: "", label: "", color: "#94a3b8" }
    }

    function summarizePowerup(powerup) {
        var energy = powerup.energy
        if (energy === undefined || energy === null)
            energy = energyForPowerup(powerup)
        return {
            powerupId: powerup.powerupId,
            typeKey: powerup.typeKey,
            typeLabel: powerup.typeLabel,
            targetKey: powerup.targetKey,
            targetLabel: powerup.targetLabel,
            colorKey: powerup.colorKey,
            colorLabel: powerup.colorLabel,
            colorHex: powerup.colorHex,
            hp: powerup.hp,
            energy: energy,
            blockCount: powerup.targetKey === "blocks" && powerup.blocks ? powerup.blocks.length : 0
        }
    }

    function cachePowerup(id, powerup) {
        if (id === undefined || id === null)
            return
        powerupCache[id] = deepCopyPowerup(powerup)
    }

    function deepCopyPowerup(powerup) {
        return JSON.parse(JSON.stringify(powerup || {}))
    }

    function optionByKey(options, key) {
        if (!options)
            return null
        var normalizedKey = (key || "").toString().toLowerCase()
        for (var i = 0; i < options.length; ++i) {
            var option = options[i]
            if ((option.key || "").toString().toLowerCase() === normalizedKey)
                return option
        }
        return null
    }

    function optionByLabel(options, label) {
        if (!options)
            return null
        var normalizedLabel = (label || "").toString().toLowerCase()
        for (var i = 0; i < options.length; ++i) {
            var option = options[i]
            if ((option.label || "").toString().toLowerCase() === normalizedLabel)
                return option
        }
        return null
    }

    function colorHexForKey(key) {
        var option = optionByKey(root.colorOptions, key)
        return option && option.color ? option.color : "#94a3b8"
    }

    function energyForPowerup(powerup) {
        if (!powerup)
            return 0
        var targetCount = 1
        if (powerup.targetKey === "blocks")
            targetCount = powerup.blocks ? powerup.blocks.length : 0
        return targetCount * (powerup.hp || 0) * 0.5
    }
}
