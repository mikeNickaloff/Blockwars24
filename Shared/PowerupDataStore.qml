import QtQuick
import QtQuick.LocalStorage

Item {
    id: store
    visible: false
    width: 0
    height: 0

    property string databaseName: "BlockwarsPowerups"
    property string databaseVersion: "1.0"
    property string databaseDescription: "Block Wars powerup persistence"
    property int estimatedSize: 1024 * 1024
    property string tableName: "editor_custom_powerups"

    property var _database: null
    property bool _schemaReady: false

    function loadAll() {
        _prepare()
        const values = []
        const db = _openDatabase()
        db.transaction(function(tx) {
            const result = tx.executeSql(
                        "SELECT payload FROM powerup_records WHERE table_name = ? ORDER BY position ASC, id ASC",
                        [tableName])
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
            tx.executeSql("DELETE FROM powerup_records WHERE table_name = ?", [tableName])
            for (let i = 0; i < list.length; ++i) {
                tx.executeSql(
                            "INSERT INTO powerup_records (table_name, position, payload) VALUES (?, ?, ?)",
                            [tableName, i, JSON.stringify(list[i] || {})])
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
                          "table_name TEXT NOT NULL, " +
                          "position INTEGER NOT NULL DEFAULT 0, " +
                          "payload TEXT NOT NULL)")
            tx.executeSql("CREATE INDEX IF NOT EXISTS idx_powerup_scope ON powerup_records(table_name)")
            try {
                tx.executeSql("ALTER TABLE powerup_records ADD COLUMN scope TEXT")
            } catch (error) {
                // legacy column optional
            }
            try {
                tx.executeSql("UPDATE powerup_records SET table_name = COALESCE(scope, ?) WHERE table_name IS NULL OR table_name = ''",
                               [tableName])
            } catch (error) {
            }
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
