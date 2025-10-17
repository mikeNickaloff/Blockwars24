import QtQuick
import QtQuick.Controls

Item {
    id: bar

    property var orientation: Qt.TopEdge
    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined
    height: implicitHeight
    implicitHeight: 18

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: orientation === Qt.TopEdge ? "#1e40af" : "#1f2937"
        border.color: "#3b82f6"
        border.width: 1
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.32
        height: parent.height * 0.65
        radius: height / 2
        color: "#38bdf8"
        opacity: 0.4
    }
}
