import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24

Popup {
    id: modal
    property var options: []
    property int slotIndex: -1

    signal dismissed()
    signal optionChosen(int slotIndex, var option)

    modal: true
    dim: true
    anchors.centerIn: parent
    width: Math.min(parent ? parent.width * 0.7 : 720, 720)
    height: Math.min(parent ? parent.height * 0.8 : 640, 640)

    background: Rectangle {
        radius: 14
        color: "#0f172a"
        border.color: "#1e293b"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: qsTr("Select Powerup")
                font.pixelSize: 28
                font.bold: true
                color: "#f8fafc"
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Close")
                onClicked: {
                    modal.dismissed()
                    modal.close()
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: optionList
                model: options
                spacing: 12
                clip: true
                delegate: SinglePlayerPowerupOptionCard {
                    width: optionList.width
                    option: modelData
                    onOptionActivated: function(option) {
                        modal.optionChosen(slotIndex, option)
                        modal.close()
                    }
                }
            }
        }
    }

    onClosed: dismissed()
}
