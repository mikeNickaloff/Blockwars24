import QtQuick
import QtQuick.Controls
import Blockwars24 1.0
import "../../lib/promise.js" as Q

Item {
    id: grid

    property int rowCount: 6
    property int columnCount: 6
    property real cellPadding: 6
    property real cellSize: Math.min(width / columnCount, height / rowCount)
    property string gridState: "idle"
    property var gridMatrix: []
    property var matchList: []
    property int maxSwaps: 3
    property int swapsRemaining: 0
    property bool activeTurn: false
    property bool allowPointerSwaps: false
    property bool seedingFill: true
    property int fillDirection: 1 // 1 = downward toward rowCount-1, -1 = upward toward row 0
    property var _selectedBlock: null
    property var _dragContext: null
    property int spawnSeed: 1
    property bool _cascadeInFlight: false

    signal cascadeEnded()
    signal swapPerformed(bool success, int row1, int column1, int row2, int column2)
    signal turnEnded()
    signal fillCycleStarted()

    implicitWidth: 420
    implicitHeight: 420

    GameGridOrchestrator {
        id: orchestrator
        rowCount: grid.rowCount
        columnCount: grid.columnCount
        fillDirection: grid.fillDirection
    }

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

    Component.onCompleted: _initialize()

    Component {
        id: blockComponent
        Block {}
    }

    function beginTurn() {
        activeTurn = true
        swapsRemaining = maxSwaps
        seedingFill = false
        _clearSelection()
        _syncBlockInteractivity()
        beginFilling()
    }

    function configureSpawnSeed(seedValue) {
        _configureSpawnSeed(seedValue)
    }

    function setFillDirection(direction) {
        fillDirection = direction >= 0 ? 1 : -1
    }

    function observeTurn() {
        activeTurn = false
        swapsRemaining = 0
        _clearSelection()
        setInteractionEnabled(false)
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
        matchList = matches
        gridState = "launch"
        _requestCascade()
        return true
    }

    function beginFilling() {
        if (gridState !== "fill")
            gridState = "fill"
        _requestCascade()
    }

    function _initialize() {
        gridMatrix = []
        for (let r = 0; r < rowCount; ++r) {
            const row = []
            for (let c = 0; c < columnCount; ++c)
                row.push(null)
            gridMatrix.push(row)
        }
        gridState = "fill"
        seedingFill = true
        _configureSpawnSeed(spawnSeed)
        Qt.callLater(function() {
            beginFilling()
        })
    }

    function _generateBlockSpec(row, column) {
        const avoid = _avoidColors(row, column)
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

    function _avoidColors(row, column) {
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
        return avoid
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
        block.tapped.connect(function(instance) {
            grid._handleBlockTapped(instance)
        })
        block.switchDragStarted.connect(function(instance) {
            grid._handleDragStarted(instance)
        })
        block.switchDragThresholdCrossed.connect(function(instance, direction) {
            grid._handleDragThresholdCrossed(instance, direction)
        })
        block.switchDragThresholdCleared.connect(function(instance) {
            grid._handleDragThresholdCleared(instance)
        })
        block.switchDragFinished.connect(function(instance, direction) {
            grid._handleDragFinished(instance, direction)
        })
        block.switchDragCanceled.connect(function(instance) {
            grid._handleDragCanceled(instance)
        })
        _positionBlock(block, row, column, animate)
        block.updateVisualState("idle")
        block.interactionEnabled = allowPointerSwaps && activeTurn
        block.allowSwitch = allowPointerSwaps && activeTurn
        return block
    }

    function _resolvedPromise(value) {
        const promise = Q.promise()
        promise.resolve(value)
        return promise
    }

    function _positionBlock(block, row, column, animate) {
        const targetX = column * cellSize + cellPadding
        const targetY = row * cellSize + cellPadding
        block.row = row
        block.column = column
        block.setGridGeometry(cellSize, cellPadding)
        block.x = targetX
        if (animate)
            return block.queueDropTo(row, column, 160)
        block.y = targetY
        block.inAnimation = false
        return _resolvedPromise(block)
    }

    function _fillColumns() {
        const instructions = orchestrator.prepareFill(_colorMatrix())
        if (!instructions.length)
            return _resolvedPromise(false)
        const promises = []
        for (let i = 0; i < instructions.length; ++i) {
            const op = instructions[i]
            const column = op.column
            const targetRow = op.targetRow
            const spawnRow = op.spawnRow
            const spec = op.spec
            if (gridMatrix[targetRow][column])
                continue
            const block = _createBlock(spawnRow, column, spec, false)
            block.interactionEnabled = allowPointerSwaps && activeTurn
            block.allowSwitch = allowPointerSwaps && activeTurn
            gridMatrix[targetRow][column] = block
            promises.push(_positionBlock(block, targetRow, column, true))
        }
        if (!promises.length)
            return _resolvedPromise(false)
        return Q.all(promises).then(function() { return true; })
    }

    function _preCompressColumns() {
        const moves = orchestrator.compactionMoves(_colorMatrix())
        if (!moves.length)
            return _resolvedPromise(false)
        const promises = []
        for (let i = 0; i < moves.length; ++i) {
            const move = moves[i]
            const fromRow = move.fromRow
            const column = move.column
            const block = gridMatrix[fromRow][column]
            if (!block)
                continue
            const toRow = move.toRow
            gridMatrix[fromRow][column] = null
            gridMatrix[toRow][column] = block
            promises.push(_positionBlock(block, toRow, column, true))
        }
        if (!promises.length)
            return _resolvedPromise(false)
        return Q.promise.all(promises).then(function() { return true; })
    }

    function _detectMatches() {
        const matches = orchestrator.detectMatches(_colorMatrix())
        const blocks = []
        for (let i = 0; i < matches.length; ++i) {
            const match = matches[i]
            const r = match.row
            const c = match.column
            const block = _blockAt(r, c)
            if (block && blocks.indexOf(block) === -1)
                blocks.push(block)
        }
        return blocks
    }

    function _launchMatches() {
        if (!matchList || matchList.length === 0)
            return _resolvedPromise()
        const promises = []
        for (let i = 0; i < matchList.length; ++i) {
            const block = matchList[i]
            if (!block)
                continue
            const row = block.row
            const column = block.column
            if (row >= 0 && row < rowCount && column >= 0 && column < columnCount)
                gridMatrix[row][column] = null
            promises.push(block.launch().then(function() {
                block.destroy()
            }))
        }
        matchList = []
        if (!promises.length)
            return _resolvedPromise()
        return Q.promise.all(promises)
    }

    function _processMatches(matches) {
        _clearSelection()
        if (matches && matches.length > 0) {
            matchList = matches
            if (seedingFill) {
                return _consumeSeedMatches().then(function() {
                    gridState = "compact"
                    return _advanceStateMachine()
                })
            }
            gridState = "launch"
            return _advanceStateMachine()
        }
        matchList = []
        gridState = "idle"
        if (seedingFill)
            seedingFill = false
        cascadeEnded()
        _cascadeInFlight = false
        _onCascadeComplete()
        return _resolvedPromise(false)
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
            setInteractionEnabled(false)
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

    function setInteractionEnabled(enabled) {
        allowPointerSwaps = Boolean(enabled)
        if (!allowPointerSwaps)
            _clearSelection()
        if (!allowPointerSwaps && _dragContext)
            _cancelActiveDragContext(true)
        _syncBlockInteractivity()
    }

    function _handleBlockTapped(block) {
        if (!block || !allowPointerSwaps || !activeTurn)
            return
        if (gridState !== "match" || _hasActiveAnimations())
            return
        if (_selectedBlock === block) {
            _clearSelection()
            return
        }
        if (!_selectedBlock) {
            _selectBlock(block)
            return
        }
        const sameRow = _selectedBlock.row
        const sameColumn = _selectedBlock.column
        if (!_adjacentCells(sameRow, sameColumn, block.row, block.column)) {
            _selectBlock(block)
            return
        }
        const first = { row: sameRow, column: sameColumn }
        _clearSelection()
        requestSwap(first.row, first.column, block.row, block.column)
    }

    function _handleDragStarted(block) {
        if (!block || !allowPointerSwaps || !activeTurn)
            return
        if (gridState !== "match" || _hasActiveAnimations())
            return
        if (_dragContext && _dragContext.previewActive)
            _cancelActiveDragContext(true)
        _dragContext = {
            block: block,
            originRow: block.row,
            originColumn: block.column,
            previewActive: false,
            neighborBlock: null,
            neighborRow: -1,
            neighborColumn: -1,
            originalZ: block.z || 0,
            neighborOriginalZ: 0,
            currentDirection: ""
        }
        block.z = Math.max(_dragContext.originalZ, 1000)
        _clearSelection()
    }

    function _handleDragThresholdCrossed(block, direction) {
        if (!_dragContext || _dragContext.block !== block)
            return
        const ctx = _dragContext
        const delta = _directionDelta(direction)
        if (!delta) {
            _handleDragThresholdCleared(block)
            return
        }
        const targetRow = ctx.originRow + delta.row
        const targetColumn = ctx.originColumn + delta.column
        if (targetRow < 0 || targetRow >= rowCount || targetColumn < 0 || targetColumn >= columnCount) {
            _handleDragThresholdCleared(block)
            return
        }
        ctx.currentDirection = direction
        _activatePreviewSwap(ctx, targetRow, targetColumn, direction)
    }

    function _handleDragThresholdCleared(block) {
        if (!_dragContext || _dragContext.block !== block)
            return
        const ctx = _dragContext
        if (!ctx.previewActive)
            return
        _deactivatePreviewSwap(ctx, false)
        ctx.currentDirection = ""
    }

    function _handleDragFinished(block, direction) {
        if (!_dragContext || _dragContext.block !== block)
            return
        const ctx = _dragContext
        const finalDirection = direction || ctx.currentDirection
        let success = false
        if (ctx.previewActive && finalDirection) {
            success = _finalizePreviewSwap(ctx)
        } else {
            _deactivatePreviewSwap(ctx, true)
        }
        ctx.block.z = ctx.originalZ
        if (ctx.neighborBlock)
            ctx.neighborBlock.z = ctx.neighborOriginalZ
        if (!success)
            _positionBlock(ctx.block, ctx.originRow, ctx.originColumn, true)
        _dragContext = null
    }

    function _handleDragCanceled(block) {
        if (!_dragContext || _dragContext.block !== block)
            return
        _cancelActiveDragContext(true)
    }

    function _cancelActiveDragContext(animate) {
        if (!_dragContext)
            return
        _deactivatePreviewSwap(_dragContext, animate)
        _dragContext.block.z = _dragContext.originalZ
        _dragContext = null
    }

    function _directionDelta(direction) {
        switch (direction) {
        case "left":
            return { row: 0, column: -1 }
        case "right":
            return { row: 0, column: 1 }
        case "up":
            return { row: -1, column: 0 }
        case "down":
            return { row: 1, column: 0 }
        default:
            return null
        }
    }

    function _activatePreviewSwap(ctx, targetRow, targetColumn, direction) {
        if (targetRow < 0 || targetRow >= rowCount || targetColumn < 0 || targetColumn >= columnCount)
            return
        if (ctx.previewActive && ctx.neighborRow === targetRow && ctx.neighborColumn === targetColumn)
            return
        _deactivatePreviewSwap(ctx, false)
        const neighbor = _blockAt(targetRow, targetColumn)
        if (!neighbor)
            return
        ctx.previewActive = true
        ctx.neighborRow = targetRow
        ctx.neighborColumn = targetColumn
        ctx.neighborBlock = neighbor
        ctx.neighborOriginalZ = neighbor.z || 0
        ctx.currentDirection = direction || ctx.currentDirection
        ctx.block.z = Math.max(ctx.originalZ, 1000)
        neighbor.z = Math.max(neighbor.z || 0, ctx.block.z)
        gridMatrix[ctx.originRow][ctx.originColumn] = neighbor
        gridMatrix[targetRow][targetColumn] = ctx.block
        _positionBlock(ctx.block, targetRow, targetColumn, true)
        _positionBlock(neighbor, ctx.originRow, ctx.originColumn, true)
    }

    function _deactivatePreviewSwap(ctx, animate) {
        if (!ctx.previewActive)
            return
        const neighbor = ctx.neighborBlock
        if (neighbor) {
            gridMatrix[ctx.neighborRow][ctx.neighborColumn] = neighbor
            gridMatrix[ctx.originRow][ctx.originColumn] = ctx.block
            _positionBlock(neighbor, ctx.neighborRow, ctx.neighborColumn, animate === undefined ? false : animate)
        } else {
            gridMatrix[ctx.originRow][ctx.originColumn] = ctx.block
        }
        _positionBlock(ctx.block, ctx.originRow, ctx.originColumn, animate === undefined ? false : animate)
        if (neighbor)
            neighbor.z = ctx.neighborOriginalZ
        ctx.previewActive = false
        ctx.neighborBlock = null
        ctx.neighborRow = -1
        ctx.neighborColumn = -1
        ctx.currentDirection = ""
        ctx.block.z = ctx.originalZ
    }

    function _finalizePreviewSwap(ctx) {
        if (!ctx.previewActive || !ctx.neighborBlock)
            return false
        const fromRow = ctx.originRow
        const fromColumn = ctx.originColumn
        const toRow = ctx.neighborRow
        const toColumn = ctx.neighborColumn
        const matches = _detectMatches()
        if (!matches || !matches.length) {
            _deactivatePreviewSwap(ctx, true)
            swapPerformed(false, fromRow, fromColumn, toRow, toColumn)
            return false
        }
        ctx.block.z = ctx.originalZ
        ctx.neighborBlock.z = ctx.neighborOriginalZ
        matchList = matches
        swapPerformed(true, fromRow, fromColumn, toRow, toColumn)
        _consumeSwap()
        ctx.previewActive = false
        ctx.neighborBlock = null
        ctx.neighborRow = -1
        ctx.neighborColumn = -1
        ctx.currentDirection = ""
        gridState = "launch"
        _requestCascade()
        return true
    }

    function _selectBlock(block) {
        _clearSelection()
        _selectedBlock = block
        if (_selectedBlock)
            _selectedBlock.updateVisualState("selected")
    }

    function _clearSelection() {
        if (_selectedBlock && Qt.isQtObject(_selectedBlock))
            _selectedBlock.updateVisualState("idle")
        _selectedBlock = null
    }

    function _syncBlockInteractivity() {
        for (let r = 0; r < rowCount; ++r) {
            for (let c = 0; c < columnCount; ++c) {
                const block = gridMatrix[r][c]
                if (!block)
                    continue
                block.interactionEnabled = allowPointerSwaps && activeTurn
                block.allowSwitch = allowPointerSwaps && activeTurn
                if (!block.interactionEnabled && block.blockState === "selected")
                    block.updateVisualState("idle")
            }
        }
    }

    function _consumeSeedMatches() {
        if (!matchList || !matchList.length)
            return _resolvedPromise()
        for (let i = 0; i < matchList.length; ++i) {
            const block = matchList[i]
            if (!block)
                continue
            const row = block.row
            const column = block.column
            if (row >= 0 && row < rowCount && column >= 0 && column < columnCount)
                gridMatrix[row][column] = null
            block.destroy()
        }
        matchList = []
        return _resolvedPromise()
    }

    function _configureSpawnSeed(seedValue) {
        orchestrator.spawnSeed = (Number(seedValue) >>> 0) || 1
        orchestrator.resetPool()
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

    function _advanceStateMachine() {
        if (gridState === "fill") {
            return _fillColumns().then(function(spawned) {
                if (spawned)
                    return _advanceStateMachine()
                gridState = "compact"
                return _advanceStateMachine()
            })
        }
        if (gridState === "compact") {
            return _preCompressColumns().then(function(moved) {
                if (moved)
                    return _advanceStateMachine()
                gridState = "match"
                return _advanceStateMachine()
            })
        }
        if (gridState === "match")
            return _processMatches(_detectMatches())
        if (gridState === "launch") {
            return _launchMatches().then(function() {
                gridState = "compact"
                return _advanceStateMachine()
            })
        }
        return _resolvedPromise(false)
    }

    function _requestCascade() {
        if (_cascadeInFlight)
            return
        _cascadeInFlight = true
        fillCycleStarted()
        _advanceStateMachine().then(function() {
            _cascadeInFlight = false
        }, function() {
            _cascadeInFlight = false
        })
    }
}
