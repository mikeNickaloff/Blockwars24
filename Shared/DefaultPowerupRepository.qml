import QtQuick

QtObject {
    id: repository

    readonly property var entries: _initializeDefaults()

    function allPowerups() {
        return entries
    }

    function _initializeDefaults() {
        const energy = energyModel
        const presets = []
        presets.push(_buildEntry({
                                typeKey: "enemy",
                                targetKey: "blocks",
                                colorKey: "red",
                                hp: 12,
                                blocks: [{ row: 2, column: 2 }, { row: 2, column: 3 }, { row: 3, column: 2 }],
                                typeLabel: qsTr("Assault"),
                                targetLabel: qsTr("Blocks"),
                                colorLabel: qsTr("Red")
                            }))
        presets.push(_buildEntry({
                                typeKey: "self",
                                targetKey: "players",
                                colorKey: "blue",
                                hp: 18,
                                typeLabel: qsTr("Support"),
                                targetLabel: qsTr("Player Health"),
                                colorLabel: qsTr("Blue")
                            }))
        presets.push(_buildEntry({
                                typeKey: "enemy",
                                targetKey: "heroes",
                                colorKey: "green",
                                hp: 15,
                                typeLabel: qsTr("Assault"),
                                targetLabel: qsTr("Hero Units"),
                                colorLabel: qsTr("Green")
                            }))
        presets.push(_buildEntry({
                                typeKey: "self",
                                targetKey: "blocks",
                                colorKey: "yellow",
                                hp: 10,
                                blocks: [{ row: 1, column: 1 }, { row: 1, column: 4 }],
                                typeLabel: qsTr("Support"),
                                targetLabel: qsTr("Blocks"),
                                colorLabel: qsTr("Yellow")
                            }))
        return presets
    }

    function _buildEntry(draft) {
        const colorMap = {
            red: { label: qsTr("Red"), hex: "#ef4444" },
            blue: { label: qsTr("Blue"), hex: "#3b82f6" },
            green: { label: qsTr("Green"), hex: "#22c55e" },
            yellow: { label: qsTr("Yellow"), hex: "#facc15" }
        }
        const color = colorMap[draft.colorKey] || colorMap.red
        const sanitizedBlocks = _sanitizeBlocks(draft.blocks)
        const hp = Math.max(0, Math.round(Number(draft.hp || 0)))
        const blockCount = sanitizedBlocks.length === 0 ? 1 : sanitizedBlocks.length
        return {
            id: -1,
            typeKey: draft.typeKey || "enemy",
            typeLabel: draft.typeLabel || (draft.typeKey === "self" ? qsTr("Support") : qsTr("Assault")),
            targetKey: draft.targetKey || "blocks",
            targetLabel: draft.targetLabel || qsTr("Blocks"),
            colorKey: draft.colorKey || "red",
            colorLabel: draft.colorLabel || color.label,
            colorHex: color.hex,
            hp: hp,
            blockCount: Math.max(1, blockCount),
            blocks: sanitizedBlocks,
            energy: energyModel.estimateEnergy({
                        hp: hp,
                        blockCount: Math.max(1, blockCount),
                        typeKey: draft.typeKey || "enemy",
                        targetKey: draft.targetKey || "blocks"
                    })
        }
    }

    function _sanitizeBlocks(blocks) {
        const source = Array.isArray(blocks) ? blocks : []
        const sanitized = []
        const seen = {}
        for (let i = 0; i < source.length; ++i) {
            const cell = source[i]
            if (!cell)
                continue
            const row = Math.max(0, Math.min(5, Math.floor(Number(cell.row))))
            const column = Math.max(0, Math.min(5, Math.floor(Number(cell.column))))
            const key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        return sanitized
    }

    PowerupEnergyModel {
        id: energyModel
    }
}
