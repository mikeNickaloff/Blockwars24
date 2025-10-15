import QtQuick

QtObject {
    id: repo

    property var editorStore

    readonly property var defaultCatalog: [
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
        const defaults = buildDefaultOptions()
        const customs = buildCustomOptions()
        for (let i = 0; i < customs.length; ++i)
            defaults.push(customs[i])
        return defaults
    }

    function optionById(optionId) {
        if (!optionId)
            return null

        const combined = availableOptions()
        for (let i = 0; i < combined.length; ++i) {
            const candidate = combined[i]
            if (candidate && candidate.id === optionId)
                return candidate
        }
        return null
    }

    function buildDefaultOptions() {
        const options = []
        for (let i = 0; i < defaultCatalog.length; ++i) {
            const definition = defaultCatalog[i]
            const metadata = {
                id: "default:" + definition.id,
                source: "default",
                description: definition.description
            }
            const option = normalize(definition, metadata)
            if (option)
                options.push(option)
        }
        return options
    }

    function buildCustomOptions() {
        const options = []
        if (!editorStore || !editorStore.createdPowerupsModel)
            return options

        const model = editorStore.createdPowerupsModel
        for (let i = 0; i < model.count; ++i) {
            const summary = model.get(i)
            if (!summary || summary.powerupId === undefined)
                continue

            const full = editorStore.getPowerupById(summary.powerupId)
            if (!full)
                continue

            const metadata = {
                id: "custom:" + summary.powerupId,
                source: "custom",
                description: summary.description || full.description || "",
                powerupId: summary.powerupId
            }
            const option = normalize(full, metadata)
            if (option)
                options.push(option)
        }
        return options
    }

    function normalize(raw, metadata) {
        if (!raw)
            return null

        const powerup = {
            name: raw.name || qsTr("Powerup"),
            typeKey: raw.typeKey || "enemy",
            targetKey: raw.targetKey || "blocks",
            colorKey: raw.colorKey || "red",
            hp: raw.hp !== undefined ? raw.hp : 0,
            blocks: raw.blocks ? raw.blocks.slice() : []
        }

        return {
            id: metadata && metadata.id ? metadata.id : powerup.name,
            source: metadata && metadata.source ? metadata.source : "unknown",
            description: metadata && metadata.description ? metadata.description : "",
            powerup: powerup,
            summary: buildSummary(powerup)
        }
    }

    function buildSummary(powerup) {
        const targetLabel = labelForTarget(powerup.targetKey)
        const typeLabel = labelForType(powerup.typeKey)
        const colorLabel = labelForColor(powerup.colorKey)
        const hpLabel = powerup.hp !== undefined ? powerup.hp : 0
        const blockCount = powerup.blocks ? powerup.blocks.length : 0

        const bullets = [typeLabel + " • " + targetLabel, qsTr("Color: %1").arg(colorLabel)]
        if (blockCount > 0)
            bullets.push(qsTr("Affects %1 block%2").arg(blockCount).arg(blockCount === 1 ? "" : "s"))
        bullets.push(qsTr("Power: %1 HP").arg(hpLabel))
        return bullets
    }

    function labelForType(typeKey) {
        switch (typeKey) {
        case "self": return qsTr("Self")
        case "enemy": return qsTr("Enemy")
        default: return qsTr("Unknown")
        }
    }

    function labelForTarget(targetKey) {
        switch (targetKey) {
        case "blocks": return qsTr("Blocks")
        case "player": return qsTr("Player Health")
        case "heroes": return qsTr("Heroes")
        default: return qsTr("Unknown")
        }
    }

    function labelForColor(colorKey) {
        switch (colorKey) {
        case "red": return qsTr("Red")
        case "blue": return qsTr("Blue")
        case "green": return qsTr("Green")
        case "yellow": return qsTr("Yellow")
        default: return qsTr("Mystery")
        }
    }
}
