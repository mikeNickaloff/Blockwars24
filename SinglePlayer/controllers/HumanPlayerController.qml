import QtQuick

Item {
    id: controller

    property int dashboardIndex: 1
    property var preparedLoadout: []

    signal loadoutPrepared(int dashboardIndex, var loadout)
    signal initiativeRolled(int dashboardIndex, int rollValue)

    function prepareLoadout(loadout) {
        preparedLoadout = Array.isArray(loadout) ? loadout : []
        loadoutPrepared(dashboardIndex, preparedLoadout)
    }

    function rollInitiative() {
        const value = Math.floor(Math.random() * 5000000) + 1
        initiativeRolled(dashboardIndex, value)
    }
}
