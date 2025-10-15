import QtQuick
import Blockwars24
import "."
GameScene {
    id: root

    property var editorStore

    property var helper: PowerupLoadoutHelper {

    }

    readonly property var defaultDefinitions: [
        ({
            id: "flare_barrage",
            name: qsTr("Flare Barrage"),
            description: qsTr("Sear the enemy front line with a trio of molten projectiles."),
            typeKey: "enemy",
            targetKey: "blocks",
            colorKey: "red",
            hp: 12,
            blocks: [
                { row: 2, column: 1 },
                { row: 2, column: 2 },
                { row: 2, column: 3 }
            ]
        }),
        ({
            id: "tidal_surge",
            name: qsTr("Tidal Surge"),
            description: qsTr("Crashes through a column, sweeping away brittle defenses."),
            typeKey: "enemy",
            targetKey: "blocks",
            colorKey: "blue",
            hp: 10,
            blocks: [
                { row: 1, column: 4 },
                { row: 2, column: 4 },
                { row: 3, column: 4 },
                { row: 4, column: 4 }
            ]
        }),
        ({
            id: "verdant_bulwark",
            name: qsTr("Verdant Bulwark"),
            description: qsTr("Reinforces a cluster of allied blocks with rejuvenating growth."),
            typeKey: "self",
            targetKey: "blocks",
            colorKey: "green",
            hp: 8,
            blocks: [
                { row: 3, column: 2 },
                { row: 3, column: 3 },
                { row: 4, column: 2 },
                { row: 4, column: 3 }
            ]
        }),
        ({
            id: "aurora_reservoir",
            name: qsTr("Aurora Reservoir"),
            description: qsTr("Channels celestial light to restore your team's vitality."),
            typeKey: "self",
            targetKey: "player",
            colorKey: "yellow",
            hp: 15
        }),
        ({
            id: "shadow_lash",
            name: qsTr("Shadow Lash"),
            description: qsTr("Strikes enemy heroes with chilling precision."),
            typeKey: "enemy",
            targetKey: "heroes",
            colorKey: "blue",
            hp: 9
        }),
        ({
            id: "radiant_vanguard",
            name: qsTr("Radiant Vanguard"),
            description: qsTr("Empowers allied heroes with a surge of protective light."),
            typeKey: "self",
            targetKey: "heroes",
            colorKey: "yellow",
            hp: 12
        })
    ]

    function availableOptions() {
        var combined = defaultOptions()
        var customs = customOptions()
        for (var i = 0; i < customs.length; ++i)
            combined.push(customs[i])
        return combined
    }

    function defaultOptions() {
        var options = []
        for (var i = 0; i < defaultDefinitions.length; ++i) {
            var definition = defaultDefinitions[i]
            var metadata = {
                id: "default:" + definition.id,
                source: "default",
                name: definition.name,
                description: definition.description
            }
            var option = helper.buildOption(definition, metadata)
            if (option)
                options.push(option)
        }
        return options
    }

    function customOptions() {
        var options = []
        if (!editorStore || !editorStore.createdPowerupsModel)
            return options
        var model = editorStore.createdPowerupsModel
        for (var i = 0; i < model.count; ++i) {
            var summary = model.get(i)
            if (!summary || summary.powerupId === undefined)
                continue
            var full = editorStore.getPowerupById(summary.powerupId)
            if (!full)
                continue
            var metadata = {
                id: "custom:" + summary.powerupId,
                source: "custom",
                powerupId: summary.powerupId
            }
            var option = helper.buildOption(full, metadata)
            if (option)
                options.push(option)
        }
        return options
    }
}
