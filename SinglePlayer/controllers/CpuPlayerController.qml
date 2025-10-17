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

    function selectBestSwap(grid) {
        if (!grid)
            return null
        const options = []
        for (let r = 0; r < grid.rowCount; ++r) {
            for (let c = 0; c < grid.columnCount; ++c) {
                if (c + 1 < grid.columnCount) {
                    const scoreH = grid.evaluateSwapPotential(r, c, r, c + 1)
                    if (scoreH > 0)
                        options.push({ row1: r, column1: c, row2: r, column2: c + 1, score: scoreH })
                }
                if (r + 1 < grid.rowCount) {
                    const scoreV = grid.evaluateSwapPotential(r, c, r + 1, c)
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
