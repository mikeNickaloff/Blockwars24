import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: hud

    property alias label: nameLabel.text
    property string playerName: qsTr("Player")
    property int health: 0
    property int remainingSwitches: 0

    implicitHeight: 96

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#0f172a"
        border.color: "#1e293b"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Label {
                id: nameLabel
                text: hud.playerName
                font.pixelSize: 18
                font.bold: true
                color: "#f8fafc"
            }
            Label {
                text: qsTr("Health: %1").arg(hud.health)
                color: "#38bdf8"
            }
        }

        Label {
            text: qsTr("Swaps: %1").arg(hud.remainingSwitches)
            font.pixelSize: 16
            color: "#fbbf24"
        }
    }
}
