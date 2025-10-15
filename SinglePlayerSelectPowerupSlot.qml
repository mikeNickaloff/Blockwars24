import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Frame {
    id: card
    property int slotIndex: -1
    property var powerupOption: null
    property bool filled: powerupOption !== null

    signal selectRequested(int slotIndex)
    signal clearRequested(int slotIndex)

    padding: 16
    background: Rectangle {
        radius: 12
        color: filled ? "#142034" : "#0c111f"
        border.color: filled ? "#3b82f6" : "#1f2937"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            text: filled ? powerupOption.powerup.name : qsTr("Powerup Slot %1").arg(slotIndex + 1)
            font.pixelSize: 22
            font.bold: true
            color: "#f9fafb"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Repeater {
            model: filled && powerupOption.summary ? powerupOption.summary.length : 0
            delegate: Label {
                text: powerupOption.summary[index]
                color: "#cbd5f5"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Label {
            visible: !filled
            text: qsTr("Select a powerup to occupy this slot.")
            color: "#64748b"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: filled ? qsTr("Change") : qsTr("Select Powerup")
                Layout.fillWidth: true
                onClicked: card.selectRequested(card.slotIndex)
            }

            Button {
                visible: filled
                text: qsTr("Clear")
                onClicked: card.clearRequested(card.slotIndex)
            }
        }
    }
}
