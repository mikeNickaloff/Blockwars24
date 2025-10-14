import QtQuick
import QtQuick.Controls

Item {
    id: root
    property bool selected: false
    property color highlightColor: "#4ade80"
    property color idleColor: "#6b7280"

    implicitWidth: 48
    implicitHeight: 48

    Rectangle {
        id: base
        anchors.fill: parent
        radius: 6
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.selected ? Qt.lighter(root.highlightColor, 1.25) : Qt.lighter(root.idleColor, 1.25) }
            GradientStop { position: 1.0; color: root.selected ? Qt.darker(root.highlightColor, 1.2) : Qt.darker(root.idleColor, 1.2) }
        }
        border.color: root.selected ? Qt.darker(root.highlightColor, 1.6) : "#111827"
        border.width: 2
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * 0.18
        color: "#00000020"
        radius: base.radius
    }

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.7
        height: parent.height * 0.1
        color: "#ffffff40"
        radius: base.radius
    }
}
