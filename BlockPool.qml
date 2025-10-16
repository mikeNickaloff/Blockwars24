import QtQuick

Item {
    id: pool

    property var colorPalette: [
        "#3b82f6",
        "#ef4444",
        "#f97316",
        "#22c55e",
        "#a855f7",
        "#eab308"
    ]

    property int blockPoolIndex: 0
    property int _cursor: 0

    function getNextColor() {
        if (!colorPalette || colorPalette.length === 0)
            return "#94a3b8"
        const color = colorPalette[_cursor % colorPalette.length]
        _cursor = (_cursor + 1) % colorPalette.length
        return color
    }

    function randomizeIndex() {
        const newIndex = Math.floor(Math.random() * 100000)
        setBlockPoolIndex(newIndex)
        return blockPoolIndex
    }

    function setBlockPoolIndex(index) {
        const normalized = Math.max(0, Math.floor(index))
        blockPoolIndex = normalized
        _cursor = normalized % Math.max(1, colorPalette.length)
        return blockPoolIndex
    }

    function getBlockPoolIndex() {
        return blockPoolIndex
    }
}
