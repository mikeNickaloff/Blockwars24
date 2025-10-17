import QtQuick
import QtQuick.Controls

Item {
    id: grid

    property int rowCount: 6
    property int columnCount: 6
    property real cellPadding: 6
    property real cellSize: Math.min(width / columnCount, height / rowCount)
    property string gridState: "idle"
    property var gridMatrix: []
    property var matchList: []
    property int activeLaunches: 0

    signal cascadeEnded()

    implicitWidth: 420
    implicitHeight: 420

    readonly property var colorPalette: [
        { key: "red", hex: "#ef4444", label: qsTr("Red") },
        { key: "green", hex: "#22c55e", label: qsTr("Green") },
        { key: "blue", hex: "#3b82f6", label: qsTr("Blue") },
        { key: "yellow", hex: "#facc15", label: qsTr("Yellow") }
    ]

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#0d1729"
        border.color: "#1d4ed8"
        border.width: 1
    }

    Item {
        id: gridLayer
        anchors.fill: parent
        anchors.margins: cellPadding
    }

    Timer {
        id: fillTimer
        interval: 90
        repeat: true
        running: false
        onTriggered: grid._advanceFill()
    }

    Timer {
        id: compactTimer
        interval: 110
        repeat: true
        running: false
        onTriggered: grid._advanceCompact()
    }

    Timer {
        id: matchTimer
        interval: 120
        repeat: false
        running: false
        onTriggered: grid._evaluateMatches()
    }

    Component.onCompleted: _initialize()

    Component {
        id: blockComponent
        Block {}
    }

    function beginTurn() {
        beginFilling()
    }

    function observeTurn() {
        // observer mode currently passive; placeholder for future behavior
    }

    function beginFilling() {
        if (gridState === "fill")
            return
        gridState = "fill"
        fillTimer.start()
    }

    function _initialize() {
        gridMatrix = []
        for (let r = 0; r < rowCount; ++r) {
            const row = []
            for (let c = 0; c < columnCount; ++c)
                row.push(null)
            gridMatrix.push(row)
        }
        _populateInitialGrid()
        gridState = "idle"
        matchTimer.start()
    }

    function _populateInitialGrid() {
        for (let r = 0; r < rowCount; ++r) {
            for (let c = 0; c < columnCount; ++c) {
                const spec = _generateBlockSpec(r, c)
                const block = _createBlock(r, c, spec, false)
                gridMatrix[r][c] = block
            }
        }
    }

    function _generateBlockSpec(row, column) {
        const avoid = []
        if (column >= 2) {
            const left1 = gridMatrix[row][column - 1]
            const left2 = gridMatrix[row][column - 2]
            if (left1 && left2 && left1.colorKey === left2.colorKey)
                avoid.push(left1.colorKey)
        }
        if (row >= 2) {
            const up1 = gridMatrix[row - 1][column]
            const up2 = gridMatrix[row - 2][column]
            if (up1 && up2 && up1.colorKey === up2.colorKey)
                avoid.push(up1.colorKey)
        }
        const palette = colorPalette.filter(function(entry) {
            return avoid.indexOf(entry.key) === -1
        })
        const choice = palette.length ? palette[Math.floor(Math.random() * palette.length)] : colorPalette[Math.floor(Math.random() * colorPalette.length)]
        return {
            colorKey: choice.key,
            colorHex: choice.hex,
            hp: 10
        }
    }

    function _createBlock(row, column, specification, animate) {
        const spec = specification || _generateBlockSpec(row, column)
        const block = blockComponent.createObject(gridLayer, {
                                                    row: row,
                                                    column: column,
                                                    colorKey: spec.colorKey,
                                                    colorHex: spec.colorHex,
                                                    hp: spec.hp
                                                })
        block.setGridGeometry(cellSize, cellPadding)
        block.x = column * cellSize + cellPadding
        block.y = row >= 0 ? row * cellSize + cellPadding : -cellSize
        block.launchCompleted.connect(function(instance) {
            grid._handleLaunchComplete(instance)
        })
        _positionBlock(block, row, column, animate)
        block.updateVisualState("idle")
        return block
    }

    function _positionBlock(block, row, column, animate) {
        const targetX = column * cellSize + cellPadding
        const targetY = row * cellSize + cellPadding
        block.row = row
        block.column = column
        block.setGridGeometry(cellSize, cellPadding)
        block.x = targetX
        if (animate) {
            block.inAnimation = true
            const animation = Qt.createQmlObject(
                        'import QtQuick 6.5; NumberAnimation { property: "y"; duration: 140; easing.type: Easing.OutQuad }',
                        block,
                        "dropAnimation")
            animation.to = targetY
            animation.from = block.y
            animation.running = true
            animation.finished.connect(function() {
                block.inAnimation = false
                animation.destroy()
            })
        } else {
            block.y = targetY
            block.inAnimation = false
        }
    }

    function _advanceFill() {
        if (_hasActiveAnimations())
            return
        const spawned = _fillColumns()
        if (!spawned) {
            fillTimer.stop()
            gridState = "compact"
            compactTimer.start()
        }
    }

    function _fillColumns() {
        let spawned = false
        for (let c = 0; c < columnCount; ++c) {
            for (let r = rowCount - 1; r >= 0; --r) {
                if (!gridMatrix[r][c]) {
                    const spec = _generateBlockSpec(r, c)
                    const block = _createBlock(-1, c, spec, false)
                    block.y = -cellSize
                    block.row = -1
                    block.column = c
                    _positionBlock(block, r, c, true)
                    gridMatrix[r][c] = block
                    spawned = true
                }
            }
        }
        return spawned
    }

    function _advanceCompact() {
        if (_hasActiveAnimations())
            return
        let moved = false
        for (let c = 0; c < columnCount; ++c) {
            for (let r = rowCount - 2; r >= 0; --r) {
                const block = gridMatrix[r][c]
                if (!block)
                    continue
                let nextRow = r
                while (nextRow + 1 < rowCount && !gridMatrix[nextRow + 1][c])
                    nextRow += 1
                if (nextRow !== r) {
                    gridMatrix[r][c] = null
                    gridMatrix[nextRow][c] = block
                    _positionBlock(block, nextRow, c, true)
                    moved = true
                }
            }
        }
        if (!moved) {
            compactTimer.stop()
            gridState = "match"
            matchTimer.start()
        }
    }

    function _evaluateMatches() {
        if (_hasActiveAnimations()) {
            matchTimer.start()
            return
        }
        const matches = _detectMatches()
        if (matches.length > 0) {
            matchList = matches
            gridState = "launch"
            _launchMatches()
        } else {
            gridState = "idle"
            matchList = []
            cascadeEnded()
        }
    }

    function _detectMatches() {
        const matched = {}
        // Horizontal runs
        for (let r = 0; r < rowCount; ++r) {
            let run = []
            let lastKey = null
            for (let c = 0; c < columnCount; ++c) {
                const block = gridMatrix[r][c]
                const key = block ? block.colorKey : null
                if (key && key === lastKey) {
                    run.push(block)
                } else {
                    if (run.length >= 3)
                        _registerRun(run, matched)
                    run = block ? [block] : []
                    lastKey = key
                }
            }
            if (run.length >= 3)
                _registerRun(run, matched)
        }
        // Vertical runs
        for (let c = 0; c < columnCount; ++c) {
            let run = []
            let lastKey = null
            for (let r = 0; r < rowCount; ++r) {
                const block = gridMatrix[r][c]
                const key = block ? block.colorKey : null
                if (key && key === lastKey) {
                    run.push(block)
                } else {
                    if (run.length >= 3)
                        _registerRun(run, matched)
                    run = block ? [block] : []
                    lastKey = key
                }
            }
            if (run.length >= 3)
                _registerRun(run, matched)
        }
        return Object.values(matched)
    }

    function _registerRun(run, store) {
        for (let i = 0; i < run.length; ++i) {
            const block = run[i]
            if (!block)
                continue
            const key = block.row + ":" + block.column
            store[key] = block
        }
    }

    function _launchMatches() {
        if (!matchList || matchList.length === 0) {
            gridState = "compact"
            compactTimer.start()
            return
        }
        activeLaunches = 0
        for (let i = 0; i < matchList.length; ++i) {
            const block = matchList[i]
            if (!block)
                continue
            activeLaunches += 1
            block.updateVisualState("launching")
            block.launch()
        }
    }

    function _handleLaunchComplete(block) {
        const row = block.row
        const column = block.column
        if (row >= 0 && row < rowCount && column >= 0 && column < columnCount)
            gridMatrix[row][column] = null
        block.destroy()
        activeLaunches = Math.max(0, activeLaunches - 1)
        if (activeLaunches === 0) {
            matchList = []
            gridState = "compact"
            compactTimer.start()
        }
    }

    function _hasActiveAnimations() {
        for (let r = 0; r < rowCount; ++r) {
            for (let c = 0; c < columnCount; ++c) {
                const block = gridMatrix[r][c]
                if (block && block.inAnimation)
                    return true
            }
        }
        return false
    }
}
