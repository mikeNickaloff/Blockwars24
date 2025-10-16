import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "."

GameScene {
    id: scene

    property var editorStore
    property int slotCount: 4

    signal backRequested
    signal selectionConfirmed(var selection)

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#020617"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Back")
                onClicked: scene.backRequested()
            }

            Label {
                text: qsTr("Select Powerups")
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: 28
                font.bold: true
                color: "#f8fafc"
            }
        }

        Repeater {
            model: slotCount
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                radius: 12
                color: "#111827"
                border.color: "#1e293b"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Slot %1").arg(index + 1)
                    color: "#e2e8f0"
                }
            }
        }

        Button {
            text: qsTr("Confirm Selection")
            Layout.alignment: Qt.AlignHCenter
            onClicked: scene.selectionConfirmed(scene._resolveSelection())
        }
    }

    function _resolveSelection() {
        if (editorStore && editorStore.allPowerups)
            return editorStore.allPowerups()
        return []
    }
}
