import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Frame {
    id: card

    property string title: qsTr("Powerup Slot")
    property var lines: []
    property color accentColor: "#475569"
    property real energy: 0.0

    readonly property real clampedEnergy: Math.max(0, Math.min(1, energy))

    padding: 14
    background: Rectangle {
        radius: 12
        color: "#111a24"
        border.color: Qt.darker(card.accentColor, 1.4)
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            text: card.title
            font.pixelSize: 20
            font.bold: true
            color: "#f8fafc"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Repeater {
            model: card.lines ? card.lines.length : 0
            delegate: Label {
                text: card.lines[index]
                color: "#cbd5f5"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Label {
            visible: !card.lines || card.lines.length === 0
            text: qsTr("Awaiting assignment.")
            color: "#94a3b8"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.fillWidth: true
            height: 8
            radius: 4
            color: "#000000"
            border.color: "#1e293b"
            border.width: 1
            antialiasing: true

            Rectangle {
                width: parent.width * card.clampedEnergy
                height: parent.height - 2
                radius: (parent.height - 2) / 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                color: card.accentColor
                antialiasing: true
            }
        }
    }
}
