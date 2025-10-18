import QtQuick
import "../../Shared"
import "../../lib/promise.js" as Q

Item {
    id: controller

    property int dashboardIndex: 0
    property var preparedLoadout: []
    property var linkedDashboard: null
    property var hydrationPromise: null

    signal loadoutPrepared(int dashboardIndex, var loadout)
    signal initiativeRolled(int dashboardIndex, int rollValue)

    DefaultPowerupRepository {
        id: defaults
    }

    function prepareLoadout() {
        const entries = defaults.allPowerups()
        preparedLoadout = entries.slice(0, 4)
        hydrationPromise = Q.promise()
        loadoutPrepared(dashboardIndex, preparedLoadout)
        return hydrationPromise
    }

    function rollInitiative() {
        const value = Math.floor(Math.random() * 5000000) + 1
        initiativeRolled(dashboardIndex, value)
    }

    function selectBestSwap(grid) {
        const activeGrid = grid || (linkedDashboard ? linkedDashboard.gridElement : null)
        if (!activeGrid)
            return null
        const options = []
        for (let r = 0; r < activeGrid.rowCount; ++r) {
            for (let c = 0; c < activeGrid.columnCount; ++c) {
                if (c + 1 < activeGrid.columnCount) {
                    const scoreH = activeGrid.evaluateSwapPotential(r, c, r, c + 1)
                    if (scoreH > 0)
                        options.push({ row1: r, column1: c, row2: r, column2: c + 1, score: scoreH })
                }
                if (r + 1 < activeGrid.rowCount) {
                    const scoreV = activeGrid.evaluateSwapPotential(r, c, r + 1, c)
                    if (scoreV > 0)
                        options.push({ row1: r, column1: c, row2: r + 1, column2: c, score: scoreV })
                }
            }
        }
        if (!options.length)
            return null
        options.sort(function(a, b) { return b.score - a.score })
        return options[0]
    }
}
