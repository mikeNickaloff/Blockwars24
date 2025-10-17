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
    property int maxSwaps: 3
    property int swapsRemaining: 0
    property bool activeTurn: false

    signal cascadeEnded()
    signal swapPerformed(bool success, int row1, int column1, int row2, int column2)
    signal turnEnded()

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
        activeTurn = true
        swapsRemaining = maxSwaps
        beginFilling()
    }

    function observeTurn() {
        activeTurn = false
        swapsRemaining = 0
    }

    function requestSwap(row1, column1, row2, column2) {
        if (!activeTurn || swapsRemaining <= 0)
            return false
        if (gridState !== "match" || _hasActiveAnimations())
            return false
        if (!_adjacentCells(row1, column1, row2, column2))
            return false
        const first = _blockAt(row1, column1)
        const second = _blockAt(row2, column2)
        if (!first || !second)
            return false
        _swapBlocks(row1, column1, row2, column2, false)
        const matches = _detectMatches()
        if (!matches.length) {
            _swapBlocks(row1, column1, row2, column2, false)
            swapPerformed(false, row1, column1, row2, column2)
            return false
        }
        swapPerformed(true, row1, column1, row2, column2)
        _consumeSwap()
        _processMatches(matches)
        return true
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
        _processMatches(matches)
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

    function _processMatches(matches) {
        if (matches && matches.length > 0) {
            matchList = matches
            gridState = "launch"
            _launchMatches()
        } else {
            gridState = "idle"
            matchList = []
            cascadeEnded()
            _onCascadeComplete()
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

    function _adjacentCells(r1, c1, r2, c2) {
        return Math.abs(r1 - r2) + Math.abs(c1 - c2) === 1
    }

    function _blockAt(row, column) {
        if (row < 0 || row >= rowCount || column < 0 || column >= columnCount)
            return null
        return gridMatrix[row][column]
    }

    function _swapBlocks(row1, column1, row2, column2, animate) {
        const first = gridMatrix[row1][column1]
        const second = gridMatrix[row2][column2]
        gridMatrix[row1][column1] = second
        gridMatrix[row2][column2] = first
        if (first)
            _positionBlock(first, row2, column2, animate)
        if (second)
            _positionBlock(second, row1, column1, animate)
    }

    function _consumeSwap() {
        if (swapsRemaining > 0)
            swapsRemaining -= 1
    }

    function _onCascadeComplete() {
        if (!activeTurn)
            return
        if (swapsRemaining <= 0) {
            activeTurn = false
            turnEnded()
        }
    }

    function evaluateSwapPotential(row1, column1, row2, column2) {
        if (!_adjacentCells(row1, column1, row2, column2))
            return 0
        const matrix = _colorMatrix()
        const temp = matrix[row1][column1]
        matrix[row1][column1] = matrix[row2][column2]
        matrix[row2][column2] = temp
        return _countMatchesInMatrix(matrix)
    }

    function endTurnEarly() {
        if (!activeTurn)
            return
        swapsRemaining = 0
        _onCascadeComplete()
    }

    function _colorMatrix() {
        const matrix = []
        for (let r = 0; r < rowCount; ++r) {
            const row = []
            for (let c = 0; c < columnCount; ++c) {
                const block = gridMatrix[r][c]
                row.push(block ? block.colorKey : "")
            }
            matrix.push(row)
        }
        return matrix
    }

    function _countMatchesInMatrix(matrix) {
        const seen = {}
        // Horizontal
        for (let r = 0; r < rowCount; ++r) {
            let run = []
            let lastKey = null
            for (let c = 0; c < columnCount; ++c) {
                const key = matrix[r][c]
                if (key && key === lastKey)
                    run.push({ row: r, column: c })
                else {
                    if (run.length >= 3)
                        _recordMatch(run, seen)
                    run = key ? [{ row: r, column: c }] : []
                    lastKey = key
                }
            }
            if (run.length >= 3)
                _recordMatch(run, seen)
        }
        // Vertical
        for (let c = 0; c < columnCount; ++c) {
            let run = []
            let lastKey = null
            for (let r = 0; r < rowCount; ++r) {
                const key = matrix[r][c]
                if (key && key === lastKey)
                    run.push({ row: r, column: c })
                else {
                    if (run.length >= 3)
                        _recordMatch(run, seen)
                    run = key ? [{ row: r, column: c }] : []
                    lastKey = key
                }
            }
            if (run.length >= 3)
                _recordMatch(run, seen)
        }
        return Object.keys(seen).length
    }

    function _recordMatch(run, store) {
        for (let i = 0; i < run.length; ++i) {
            const coord = run[i]
            const key = coord.row + ":" + coord.column
            store[key] = true
        }
    }
}
