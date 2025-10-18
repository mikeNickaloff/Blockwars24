import QtQuick
import QtQuick.Controls
import Blockwars24 1.0
import "../../lib/promise.js" as Q

AbstractGameElement {
    id: block

    // Grid bookkeeping
    property int row: 0
    property int column: 0
    property string colorKey: "red"
    property string colorHex: "#ef4444"
    property int hp: 10

    // Visual / interaction state
    property string blockState: "idle"
    property bool interactionEnabled: false
    property bool allowSwitch: false
    property bool inAnimation: false
    property real cellExtent: 64
    property real cellPadding: 4

    // Motion tuning
    property real launchDistance: cellExtent * 0.9
    property int dropDurationMs: 160
    property int launchDurationMs: 220

    // Drag bookkeeping
    property bool maybeSwitching: false
    property point maybeSwitchOrigin: Qt.point(0, 0)
    property point maybeSwitchOffset: Qt.point(0, 0)
    property string maybeSwitchDirection: ""

    signal launchCompleted(var block)
    signal tapped(var block)
    signal switchDragStarted(var block)
    signal switchDragThresholdCrossed(var block, string direction)
    signal switchDragThresholdCleared(var block)
    signal switchDragFinished(var block, string direction)
    signal switchDragCanceled(var block)

    width: cellExtent - (cellPadding * 2)
    height: width
    antialiasing: true

    Rectangle {
        anchors.fill: parent
        radius: width * 0.25
        color: colorHex
        border.color: Qt.darker(colorHex, 1.4)
        border.width: 2
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: width * 0.18
        radius: width * 0.18
        color: Qt.lighter(colorHex, 1.2)
        opacity: 0.35
    }

    BlockAnimationStateMachine {
        id: stateMachine
        target: block
    }

    Component.onCompleted: {
        block.propertyList = ["x", "y", "opacity"]
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: false
        cursorShape: Qt.PointingHandCursor

        onPressed: function(event) {
            block.maybeSwitchOrigin = Qt.point(event.x, event.y)
            block.maybeSwitchOffset = Qt.point(0, 0)
            block.maybeSwitchDirection = ""
            if (block.allowSwitch && block.interactionEnabled) {
                block.maybeSwitching = true
                block.switchDragStarted(block)
                event.accepted = true
            } else {
                block.maybeSwitching = false
                event.accepted = false
            }
        }

        onPositionChanged: function(event) {
            const dx = event.x - block.maybeSwitchOrigin.x
            const dy = event.y - block.maybeSwitchOrigin.y
            block.maybeSwitchOffset = Qt.point(dx, dy)
            if (!block.maybeSwitching)
                return

            const absX = Math.abs(dx)
            const absY = Math.abs(dy)
            const threshold = block.cellExtent * 0.5
            let direction = ""
            if (absX >= absY) {
                if (absX >= threshold)
                    direction = dx > 0 ? "right" : "left"
            } else {
                if (absY >= threshold)
                    direction = dy > 0 ? "down" : "up"
            }

            if (direction && direction !== block.maybeSwitchDirection) {
                if (block.maybeSwitchDirection)
                    block.switchDragThresholdCleared(block)
                block.maybeSwitchDirection = direction
                block.switchDragThresholdCrossed(block, direction)
            } else if (!direction && block.maybeSwitchDirection) {
                block.switchDragThresholdCleared(block)
                block.maybeSwitchDirection = ""
            }
        }

        onReleased: function(event) {
            event.accepted = true
            block._finalizeSwitchGesture()
        }

        onCanceled: function(event) {
            block._cancelSwitchGesture()
        }
    }
    function setGridGeometry(extent, padding) {
        cellExtent = extent
        cellPadding = padding
        width = cellExtent - (cellPadding * 2)
        height = width
    }

    function updateVisualState(stateName) {
        stateMachine.transitionTo(stateName)
    }

    function queueDropTo(targetRow, targetColumn, durationMs) {
        const targetX = targetColumn * cellExtent + cellPadding
        const targetY = targetRow * cellExtent + cellPadding
        const timeMs = durationMs || dropDurationMs

        const startFunc = function() {
            block.inAnimation = true
            block.row = targetRow
            block.column = targetColumn
        }

        const endFunc = function() {
            block.inAnimation = false
            block.x = targetX
            block.y = targetY
        }

        block.propertyList = ["x", "y"]
        return Q.promise(function(resolve) {
            const success = block.tweenPropertiesTo({
                                                    x: targetX,
                                                    y: targetY
                                                }, timeMs, { type: Easing.OutQuad }, startFunc, function() {
                                                    endFunc()
                                                    resolve(block)
                                                })
            if (!success) {
                startFunc()
                endFunc()
                resolve(block)
            }
        })
    }

    function queueLaunch(offset, durationMs) {
        const vector = offset || { x: 0, y: -launchDistance }
        const targetX = block.x + (vector.x || 0)
        const targetY = block.y + (vector.y || -launchDistance)
        const timeMs = durationMs || launchDurationMs

        const startFunc = function() {
            block.inAnimation = true
            block.interactionEnabled = false
            block.updateVisualState("launching")
        }

        const endFunc = function() {
            block.inAnimation = false
            block.launchCompleted(block)
        }

        block.propertyList = ["x", "y", "opacity"]
        return Q.promise(function(resolve) {
            const success = block.tweenPropertiesTo({
                                                    x: targetX,
                                                    y: targetY,
                                                    opacity: 0
                                                }, timeMs, { type: Easing.InQuad }, startFunc, function() {
                                                    endFunc()
                                                    resolve(block)
                                                })
            if (!success) {
                startFunc()
                block.x = targetX
                block.y = targetY
                block.opacity = 0
                endFunc()
                resolve(block)
            }
        })
    }

    function launch() {
        return queueLaunch()
    }

    function resetVisuals() {
        block.opacity = 1
        block.scale = 1.0
        block.updateVisualState("idle")
    }

    function _emitTap() {
        if (!interactionEnabled)
            return
        tapped(block)
    }

    function _finalizeSwitchGesture() {
        const direction = block.maybeSwitchDirection
        const offset = block.maybeSwitchOffset
        const magnitude = Math.max(Math.abs(offset.x), Math.abs(offset.y))
        if (block.maybeSwitching) {
            if (direction) {
                block.switchDragFinished(block, direction)
            } else {
                block.switchDragCanceled(block)
                if (magnitude < cellExtent * 0.1)
                    block._emitTap()
            }
        } else {
            if (magnitude < cellExtent * 0.1)
                block._emitTap()
        }
        block._resetSwitchGestureState()
    }

    function _cancelSwitchGesture() {
        if (block.maybeSwitching)
            block.switchDragCanceled(block)
        block._resetSwitchGestureState()
    }

    function _resetSwitchGestureState() {
        block.maybeSwitching = false
        block.maybeSwitchOrigin = Qt.point(0, 0)
        block.maybeSwitchOffset = Qt.point(0, 0)
        block.maybeSwitchDirection = ""
    }
}
