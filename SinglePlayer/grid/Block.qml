import QtQuick
import QtQuick.Controls

Item {
    id: block

    property int row: 0
    property int column: 0
    property string colorKey: "red"
    property string colorHex: "#ef4444"
    property int hp: 10
    property string blockState: "idle"
    property bool interactionEnabled: false
    property bool inAnimation: false
    property real cellExtent: 64
    property real cellPadding: 4

    signal launchCompleted(var block)

    width: cellExtent - (cellPadding * 2)
    height: width

    antialiasing: true

    scale: 1.0
    opacity: 1.0

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

    property real launchDistance: cellExtent * 0.9

    SequentialAnimation {
        id: launchAnimation
        running: false
        NumberAnimation {
            id: launchRise
            target: block
            property: "y"
            duration: 160
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: block
            property: "opacity"
            duration: 120
            to: 0
        }
        ScriptAction {
            script: block._completeLaunch()
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

    function launch() {
        if (inAnimation)
            return
        interactionEnabled = false
        inAnimation = true
        updateVisualState("launching")
        launchRise.to = block.y - launchDistance
        launchAnimation.start()
    }

    function _completeLaunch() {
        inAnimation = false
        launchCompleted(block)
    }
}
