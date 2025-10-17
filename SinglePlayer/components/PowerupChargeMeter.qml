import QtQuick
import QtQuick.Controls

Item {
    id: meter

    property real progress: 0
    property real requiredEnergy: 1
    property color accentColor: "#38bdf8"

    implicitHeight: 18

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#1f2937"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        radius: parent.height / 2
        width: Math.max(0, Math.min(parent.width, parent.width * (requiredEnergy > 0 ? progress / requiredEnergy : 0)))
        color: accentColor
        opacity: 0.8
    }
}
