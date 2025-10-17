import QtQuick
import "../../Shared"

Item {
    id: controller

    property int dashboardIndex: 0
    property var preparedLoadout: []

    signal loadoutPrepared(int dashboardIndex, var loadout)
    signal initiativeRolled(int dashboardIndex, int rollValue)

    DefaultPowerupRepository {
        id: defaults
    }

    function prepareLoadout() {
        const entries = defaults.allPowerups()
        preparedLoadout = entries.slice(0, 4)
        loadoutPrepared(dashboardIndex, preparedLoadout)
    }

    function rollInitiative() {
        const value = Math.floor(Math.random() * 5000000) + 1
        initiativeRolled(dashboardIndex, value)
    }
}
