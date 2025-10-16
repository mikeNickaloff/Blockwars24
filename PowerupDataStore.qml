import QtQuick

Item {
    id: store

    property string table: ""
    property var _powerups: []

    function setPowerupData(entries) {
        _powerups = (entries || []).map(function(item) { return Object.assign({}, item) })
        return _powerups.length
    }

    function getPowerupData() {
        return _powerups.slice()
    }

    function appendPowerup(entry) {
        _powerups.push(Object.assign({}, entry || {}))
        return _powerups.length
    }

    function clearPowerupData() {
        _powerups = []
    }
}
