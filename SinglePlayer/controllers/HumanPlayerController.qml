import QtQuick
import "../../lib/promise.js" as Q

Item {
    id: controller

    property int dashboardIndex: 1
    property var preparedLoadout: []
    property var linkedDashboard: null
    property var hydrationPromise: null

    signal loadoutPrepared(int dashboardIndex, var loadout)
    signal initiativeRolled(int dashboardIndex, int rollValue)

    function prepareLoadout(loadout) {
        preparedLoadout = Array.isArray(loadout) ? loadout : []
        hydrationPromise = Q.promise()
        loadoutPrepared(dashboardIndex, preparedLoadout)
        return hydrationPromise
    }

    function rollInitiative() {
        const value = Math.floor(Math.random() * 5000000) + 1
        initiativeRolled(dashboardIndex, value)
    }
}
