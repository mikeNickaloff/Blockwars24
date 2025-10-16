import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var messages: []

    implicitHeight: 120

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#111827"
        border.color: "#1f2937"
    }

    ListView {
        id: messageList
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        model: messages || []
        delegate: Label {
            width: messageList.width
            text: modelData
            wrapMode: Text.WordWrap
            color: "#e2e8f0"
        }
    }
}
