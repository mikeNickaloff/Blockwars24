import QtQuick
import QtQuick.LocalStorage

QtObject {
    id: store

    property string databaseName: "BlockwarsPowerups"
    property string databaseVersion: "1.0"
    property string databaseDescription: "Block Wars powerup persistence"
    property int estimatedSize: 1024 * 1024
    property string scope: "editor_custom_powerups"

    property var _database: null
    property bool _schemaReady: false

    function loadAll() {
        _prepare()
        const values = []
        const db = _openDatabase()
        db.transaction(function(tx) {
            const result = tx.executeSql(
                        "SELECT payload FROM powerup_records WHERE scope = ? ORDER BY position ASC, id ASC",
                        [scope])
            for (let i = 0; i < result.rows.length; ++i)
                values.push(_parsePayload(result.rows.item(i).payload))
        })
        return values
    }

    function replaceAll(entries) {
        _prepare()
        const list = Array.isArray(entries) ? entries : []
        const db = _openDatabase()
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM powerup_records WHERE scope = ?", [scope])
            for (let i = 0; i < list.length; ++i) {
                tx.executeSql(
                            "INSERT INTO powerup_records (scope, position, payload) VALUES (?, ?, ?)",
                            [scope, i, JSON.stringify(list[i] || {})])
            }
        })
    }

    function _openDatabase() {
        if (!_database)
            _database = LocalStorage.openDatabaseSync(databaseName, databaseVersion, databaseDescription, estimatedSize)
        return _database
    }

    function _prepare() {
        if (_schemaReady)
            return
        const db = _openDatabase()
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS powerup_records (" +
                          "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                          "scope TEXT NOT NULL, " +
                          "position INTEGER NOT NULL DEFAULT 0, " +
                          "payload TEXT NOT NULL)")
            tx.executeSql("CREATE INDEX IF NOT EXISTS idx_powerup_scope ON powerup_records(scope)")
        })
        _schemaReady = true
    }

    function _parsePayload(data) {
        if (!data)
            return {}
        try {
            return JSON.parse(data)
        } catch (error) {
            console.warn("PowerupDataStore: unable to parse payload", error)
            return {}
        }
    }
}
