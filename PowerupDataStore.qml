import QtQuick
import QtQuick.LocalStorage

Item {
    id: store

    property string table: ""
    property string databaseName: "BlockwarsPowerups"
    property int databaseVersion: 1
    property string databaseDescription: "Blockwars powerup persistence"
    property int databaseEstimatedSize: 1024 * 1024

    property var _database: null
    property bool _schemaReady: false

    readonly property string _defaultTable: "powerup_entries"

    Component.onCompleted: _prepare()

    function setPowerupData(entries) {
        _prepare()
        const list = Array.isArray(entries) ? entries : []
        const name = _tableKey()
        let total = 0
        const database = _openDatabase()
        database.transaction(function(tx) {
            tx.executeSql("DELETE FROM powerup_records WHERE table_name = ?", [name])
            for (let i = 0; i < list.length; ++i) {
                tx.executeSql(
                            "INSERT INTO powerup_records (table_name, position, payload) VALUES (?, ?, ?)",
                            [name, i, JSON.stringify(list[i] || {})])
            }
            const result = tx.executeSql(
                        "SELECT COUNT(*) AS count FROM powerup_records WHERE table_name = ?",
                        [name])
            total = result.rows.item(0).count
        })
        return total
    }

    function getPowerupData() {
        _prepare()
        const database = _openDatabase()
        const name = _tableKey()
        const values = []
        database.transaction(function(tx) {
            const result = tx.executeSql(
                        "SELECT payload FROM powerup_records WHERE table_name = ? ORDER BY position ASC, id ASC",
                        [name])
            for (let i = 0; i < result.rows.length; ++i)
                values.push(_parsePayload(result.rows.item(i).payload))
        })
        return values
    }

    function appendPowerup(entry) {
        _prepare()
        const database = _openDatabase()
        const name = _tableKey()
        let total = 0
        database.transaction(function(tx) {
            const positionResult = tx.executeSql(
                        "SELECT IFNULL(MAX(position), -1) AS position FROM powerup_records WHERE table_name = ?",
                        [name])
            const nextPosition = positionResult.rows.item(0).position + 1
            tx.executeSql(
                        "INSERT INTO powerup_records (table_name, position, payload) VALUES (?, ?, ?)",
                        [name, nextPosition, JSON.stringify(entry || {})])
            const countResult = tx.executeSql(
                        "SELECT COUNT(*) AS count FROM powerup_records WHERE table_name = ?",
                        [name])
            total = countResult.rows.item(0).count
        })
        return total
    }

    function clearPowerupData() {
        _prepare()
        const database = _openDatabase()
        const name = _tableKey()
        database.transaction(function(tx) {
            tx.executeSql("DELETE FROM powerup_records WHERE table_name = ?", [name])
        })
    }

    function _openDatabase() {
        if (!_database)
            _database = LocalStorage.openDatabaseSync(databaseName, databaseVersion, databaseDescription, databaseEstimatedSize)
        return _database
    }

    function _prepare() {
        if (_schemaReady)
            return
        const database = _openDatabase()
        database.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS powerup_records (" +
                          "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                          "table_name TEXT NOT NULL, " +
                          "position INTEGER NOT NULL DEFAULT 0, " +
                          "payload TEXT NOT NULL)")
            tx.executeSql("CREATE INDEX IF NOT EXISTS idx_powerup_records_table ON powerup_records(table_name)")
        })
        _schemaReady = true
    }

    function _tableKey() {
        const key = table && table.length > 0 ? String(table) : _defaultTable
        return key.replace(/[^A-Za-z0-9_]/g, "_")
    }

    function _parsePayload(data) {
        if (!data)
            return {}
        try {
            return JSON.parse(data)
        } catch (error) {
            console.warn("PowerupDataStore: failed to parse payload", error)
            return {}
        }
    }
}
