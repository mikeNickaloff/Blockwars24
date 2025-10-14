import QtQuick
import Blockwars24

GameScene {
    id: grid

    property int rows: 6
    property int columns: 6
    property real cellSize: 64
    property real columnSpacing: 0
    property real rowSpacing: 0
    property real gridLeft: 0
    property real gridTop: 0
    property real fallSpeed: 0.8
    property real dropMargin: cellSize

    readonly property real dropHeight: (rows * cellSize) + (Math.max(0, rows - 1) * rowSpacing)
    readonly property real dropOriginY: gridTop - dropHeight - dropMargin

    width: (columns * cellSize) + (Math.max(0, columns - 1) * columnSpacing)
    height: (rows * cellSize) + (Math.max(0, rows - 1) * rowSpacing)

    signal blockAccepted(int column, int row, Item block)
    signal blockRejected(int column, Item block, string reason)

    property var _columnStacks: []

    function addBlockToColumn(block, column) {
        if (!block)
            return _rejectBlock(column, block, "invalid-block")

        const colIndex = Math.floor(column)
        if (isNaN(colIndex))
            return _rejectBlock(column, block, "invalid-column")

        if (colIndex < 0 || colIndex >= columns)
            return _rejectBlock(colIndex, block, "column-out-of-range")

        if (block.__gridColumn !== undefined)
            return _rejectBlock(colIndex, block, "block-already-tracked")

        const stack = _ensureColumnStack(colIndex)
        if (stack.length >= rows)
            return _rejectBlock(colIndex, block, "column-full")

        if (!addElement(block))
            return _rejectBlock(colIndex, block, "add-element-failed")

        const targetRow = rows - stack.length - 1
        const targetPos = gridPosition(colIndex, targetRow)
        const startY = dropOriginY
        const distance = targetPos.y - startY
        const duration = Math.max(1, distance / Math.max(0.001, fallSpeed))

        const previousPropertyList = block.propertyList ? block.propertyList.slice ? block.propertyList.slice(0) : block.propertyList : []

        block.column = colIndex
        block.row = targetRow
        block.z = rows - targetRow
        block.propertyList = ["x", "y"]

        if (block.dropBehaviorEnabled !== undefined)
            block.dropBehaviorEnabled = false

        block.x = targetPos.x
        block.y = startY

        const startCallback = function(elem) {
            elem.inAnimation = true
            elem.animationStart()
        }

        const endCallback = function(elem) {
            elem.inAnimation = false
            elem.animationDone()
            if (elem.dropBehaviorEnabled !== undefined)
                elem.dropBehaviorEnabled = true
            elem.propertyList = previousPropertyList
            elem.y = targetPos.y
        }

        const animated = block.tweenPropertiesTo({
                                                    x: targetPos.x,
                                                    y: targetPos.y
                                                }, duration, { type: Easing.InOutQuad }, startCallback, endCallback)

        if (!animated) {
            if (block.dropBehaviorEnabled !== undefined)
                block.dropBehaviorEnabled = true
            block.propertyList = previousPropertyList
            removeElement(block)
            return _rejectBlock(colIndex, block, "animation-failed")
        }

        _registerBlock(colIndex, targetRow, block)
        blockAccepted(colIndex, targetRow, block)
        return true
    }

    function removeBlock(block) {
        if (!block)
            return false
        _deregisterBlock(block)
        return removeElement(block)
    }

    function columnOccupancy(column) {
        const colIndex = Math.floor(column)
        if (isNaN(colIndex) || colIndex < 0 || colIndex >= columns)
            return 0
        const stack = _ensureColumnStack(colIndex)
        return stack.length
    }

    function gridPosition(column, row) {
        return {
            x: gridLeft + (column * (cellSize + columnSpacing)),
            y: gridTop + (row * (cellSize + rowSpacing))
        }
    }

    function _ensureColumnStack(column) {
        if (!_columnStacks || _columnStacks.length !== columns)
            _columnStacks = Array.from({ length: columns }, () => [])
        if (!_columnStacks[column])
            _columnStacks[column] = []
        return _columnStacks[column]
    }

    function _registerBlock(column, row, block) {
        const stack = _ensureColumnStack(column)
        stack.push({ block: block, row: row })
        block.column = column
        block.row = row
        const cleanup = function() {
            _deregisterBlock(block)
        }
        //block.__gridCleanup = cleanup
        block.blockDestroyed.connect(cleanup)
    }

    function _deregisterBlock(block) {
        const column = block.__gridColumn
        if (column === undefined)
            return
        const stack = _ensureColumnStack(column)
        for (let i = stack.length - 1; i >= 0; --i) {
            if (stack[i].block === block)
                stack.splice(i, 1)
        }
        if (block.__gridCleanup) {
            block.destroyed.disconnect(block.__gridCleanup)
            delete block.__gridCleanup
        }
        delete block.__gridColumn
        delete block.__gridRow
    }

    function _rejectBlock(column, block, reason) {
        blockRejected(column, block, reason)
        return false
    }
}

