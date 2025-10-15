import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings 1.1
import Blockwars24

GameScene {
    id: root
    implicitWidth: 1024
    implicitHeight: 768

    property var stackView
    property int slotCount: 4
    property var editorStore

    property var availableOptions: []
    property var selectedIds: []
    property var selectedOptions: []
    property var initialSelectionIds: []

    signal backRequested()
    signal selectionConfirmed(var selectedOptions)

    Settings {
        id: loadoutSettings
        category: "singleplayer_loadout"
        property var savedIds: []
    }

    SinglePlayerPowerupRepository {
        id: repository
        editorStore: root.editorStore
    }

    function ensureSelectionLength() {
        const count = Math.max(0, slotCount)
        const ids = []
        const options = []
        for (let i = 0; i < count; ++i) {
            const id = selectedIds[i] || null
            const option = resolveOption(id)
            ids.push(id)
            options.push(option)
        }
        selectedIds = ids
        selectedOptions = options
    }

    function resolveOption(optionId) {
        if (!optionId)
            return null
        for (let i = 0; i < availableOptions.length; ++i) {
            const option = availableOptions[i]
            if (option && option.id === optionId)
                return option
        }
        const fallback = repository.optionById(optionId)
        if (fallback)
            return fallback
        return null
    }

    function refreshOptions() {
        availableOptions = repository.availableOptions()
        ensureSelectionLength()
    }

    function loadSavedSelection() {
        const ids = loadoutSettings.savedIds || []
        if (!ids || !ids.length) {
            ensureSelectionLength()
            return
        }
        selectedIds = ids.slice(0, slotCount)
        ensureSelectionLength()
    }

    function applyInitialSelection() {
        if (initialSelectionIds && initialSelectionIds.length) {
            selectedIds = initialSelectionIds.slice(0, slotCount)
            ensureSelectionLength()
        } else {
            loadSavedSelection()
        }
    }

    function assignOption(slotIndex, option) {
        if (slotIndex < 0 || slotIndex >= slotCount)
            return
        const ids = selectedIds.slice()
        const options = selectedOptions.slice()
        ids[slotIndex] = option ? option.id : null
        options[slotIndex] = option
        selectedIds = ids
        selectedOptions = options
        persistSelection()
    }

    function clearSlot(slotIndex) {
        assignOption(slotIndex, null)
    }

    function persistSelection() {
        loadoutSettings.savedIds = selectedIds
    }

    function readyToLaunch() {
        if (slotCount <= 0)
            return false
        for (let i = 0; i < slotCount; ++i) {
            if (!selectedOptions[i])
                return false
        }
        return true
    }

    function selectionSummary() {
        if (slotCount <= 0)
            return qsTr("No loadout slots configured.")
        let filled = 0
        for (let i = 0; i < slotCount; ++i) {
            if (selectedOptions[i])
                ++filled
        }
        if (filled === 0)
            return qsTr("Select powerups to fill your %1-card loadout.").arg(slotCount)
        if (filled < slotCount)
            return qsTr("%1 of %2 powerups selected.").arg(filled).arg(slotCount)
        return qsTr("All %1 slots are ready!").arg(slotCount)
    }

    Rectangle {
        anchors.fill: parent
        color: "#050915"
    }

    SinglePlayerPowerupSelectionModal {
        id: selectionModal
        parent: Overlay.overlay
        onOptionChosen: function(slotIndex, option) {
            assignOption(slotIndex, option)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 28

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: qsTr("Select Powerups")
                font.pixelSize: 38
                font.bold: true
                color: "#f0f4ff"
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Back")
                onClicked: backRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 32

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                Label {
                    text: selectionSummary()
                    color: "#cbd5f5"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Repeater {
                    id: slotRepeater
                    model: slotCount
                    delegate: SinglePlayerSelectPowerupSlot {
                        Layout.fillWidth: true
                        slotIndex: index
                        powerupOption: selectedOptions[index]
                        onSelectRequested: function(slot) {
                            selectionModal.slotIndex = slot
                            selectionModal.options = availableOptions
                            selectionModal.open()
                        }
                        onClearRequested: function(slot) {
                            clearSlot(slot)
                        }
                    }
                }
            }

            Rectangle {
                width: Math.max(260, parent ? parent.width * 0.28 : 260)
                radius: 18
                color: "#0b1220"
                border.color: "#1f2937"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Label {
                        text: qsTr("Ready to play?")
                        font.pixelSize: 26
                        font.bold: true
                        color: "#f8fafc"
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("Fill each slot with a powerup. Once you are happy with your loadout, hit Ready!")
                        color: "#9ca3af"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    Button {
                        text: qsTr("Ready!")
                        enabled: readyToLaunch()
                        Layout.fillWidth: true
                        background: Rectangle {
                            radius: 8
                            color: enabled ? "#16a34a" : "#374151"
                        }
                        onClicked: selectionConfirmed(selectedOptions)
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        refreshOptions()
        applyInitialSelection()
    }

    onSlotCountChanged: ensureSelectionLength()
    onEditorStoreChanged: refreshOptions()
    onInitialSelectionIdsChanged: applyInitialSelection()
}
