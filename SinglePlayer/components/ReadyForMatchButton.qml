import QtQuick
import QtQuick.Controls

Button {
    id: button

    property bool ready: false

    text: ready ? qsTr("Begin Match") : qsTr("Select Powerups")
    enabled: ready
    padding: 18
    font.pixelSize: 18

    background: Rectangle {
        radius: 12
        color: enabled ? "#15803d" : "#374151"
        border.color: enabled ? "#22c55e" : "#4b5563"
        border.width: 1
    }

    contentItem: Label {
        text: button.text
        anchors.centerIn: parent
        color: "#f8fafc"
        font.pixelSize: button.font.pixelSize
        font.bold: true
    }
}
