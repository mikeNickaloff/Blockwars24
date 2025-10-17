import QtQuick

QtObject {
    id: repository

    readonly property var entries: [
        {
            typeKey: "self",
            typeLabel: qsTr("Support"),
            targetKey: "players",
            targetLabel: qsTr("Player"),
            colorKey: "blue",
            colorLabel: qsTr("Blue"),
            colorHex: "#3b82f6",
            hp: 12,
            energy: 10,
            blockCount: 0,
            blocks: []
        },
        {
            typeKey: "enemy",
            typeLabel: qsTr("Assault"),
            targetKey: "heroes",
            targetLabel: qsTr("Heroes"),
            colorKey: "red",
            colorLabel: qsTr("Red"),
            colorHex: "#ef4444",
            hp: 18,
            energy: 16,
            blockCount: 0,
            blocks: []
        },
        {
            typeKey: "enemy",
            typeLabel: qsTr("Sabotage"),
            targetKey: "blocks",
            targetLabel: qsTr("Blocks"),
            colorKey: "yellow",
            colorLabel: qsTr("Yellow"),
            colorHex: "#facc15",
            hp: 10,
            energy: 12,
            blockCount: 2,
            blocks: [
                { row: 2, column: 2 },
                { row: 2, column: 3 }
            ]
        }
    ]

    function allPowerups() {
        return repository._clone(entries)
    }

    function _clone(list) {
        const source = Array.isArray(list) ? list : []
        const clone = []
        for (let i = 0; i < source.length; ++i)
            clone.push(repository._cloneEntry(source[i]))
        return clone
    }

    function _cloneEntry(payload) {
        const base = Object.assign({}, payload || {})
        const blocks = Array.isArray(base.blocks) ? base.blocks : []
        const sanitized = []
        const seen = {}
        for (let i = 0; i < blocks.length; ++i) {
            const cell = blocks[i]
            if (!cell)
                continue
            const row = Math.max(0, Math.min(5, Number(cell.row)))
            const column = Math.max(0, Math.min(5, Number(cell.column)))
            const key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        base.blocks = sanitized
        base.blockCount = sanitized.length
        return base
    }
}
