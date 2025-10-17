import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "../Shared"
import "./components"

GameScene {
    id: scene

    property PowerupRepository powerupRepository
    property var stackView
    property int slotCount: 4
    signal backRequested()
    signal selectionConfirmed(var selection)

    PlayerPowerupLoadoutStore {
        id: loadoutStore
        slotCount: scene.slotCount
        onLoadoutChanged: updateReady()
    }

    function updateReady() {
        readyButton.ready = loadoutStore.ready
    }

    Component.onCompleted: {
        loadoutStore.reload()
        updateReady()
    }

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
                font.pixelSize: 28
                font.bold: true
                color: "#f8fafc"
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            ReadyForMatchButton {
                id: readyButton
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 220
                onClicked: scene._confirmSelection()
            }
        }

        Label {
            text: qsTr("Assign powerups to each slot. Custom creations appear first, followed by default presets.")
            color: "#94a3b8"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ListView {
            id: slotList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16
            clip: true
            model: loadoutStore.model

            delegate: SelectPowerupSlot {
                width: slotList.width
                slotIndex: model.slotIndex
                payload: model.payload
                filled: model.filled
                onRequestSelection: scene._openSelection(slotIndex)
                onRequestClear: loadoutStore.clearSlot(slotIndex)
            }
        }
    }

    PowerupSelectionModal {
        id: selectionModal
        x: (parent ? parent.width : width) / 2 - width / 2
        y: (parent ? parent.height : height) / 2 - height / 2
        playerRepository: powerupRepository
        onSelectionMade: scene._applySelection(slotIndex, payload)
    }

    function _openSelection(index) {
        const current = index >= 0 && index < loadoutStore.model.count ? loadoutStore.model.get(index).payload : null
        selectionModal.openForSlot(index, current)
    }

    function _applySelection(index, payload) {
        loadoutStore.setSlot(index, payload)
        updateReady()
    }

    function _confirmSelection() {
        if (!loadoutStore.ready)
            return
        selectionConfirmed(loadoutStore.loadoutSnapshot())
    }
}
