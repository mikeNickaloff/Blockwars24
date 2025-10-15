import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24

GameScene {
    id: root
    implicitWidth: 1024
    implicitHeight: 768

    property var stackView
    property Component powerupSelectionComponent
    property int powerupSlotCount: 4
    property var selectedPowerups: []
    property var editorStore

    signal exitToMenuRequested()
    signal beginMatchRequested(var selectedPowerups)

    function normalizedSelection(source) {
        const count = Math.max(0, powerupSlotCount)
        const normalized = []
        for (let i = 0; i < count; ++i)
            normalized.push(source && source[i] ? source[i] : null)
        return normalized
    }

    function updateLoadout(selection) {
        selectedPowerups = normalizedSelection(selection || selectedPowerups)
    }

    function filledSlotCount() {
        let count = 0
        for (let i = 0; i < selectedPowerups.length; ++i) {
            if (selectedPowerups[i])
                ++count
        }
        return count
    }

    function selectionHeading() {
        const filled = filledSlotCount()
        if (powerupSlotCount <= 0)
            return qsTr("No powerup slots configured")
        if (filled === 0)
            return qsTr("Prepare your loadout by assigning powerups to each slot.")
        if (filled === powerupSlotCount)
            return qsTr("All %1 powerups ready for battle").arg(powerupSlotCount)
        return qsTr("%1 of %2 powerups ready for battle").arg(filled).arg(powerupSlotCount)
    }

    function loadoutSnapshot() {
        return normalizedSelection(selectedPowerups)
    }

    function firstEditableSlot() {
        for (let i = 0; i < selectedPowerups.length; ++i) {
            if (!selectedPowerups[i])
                return i
        }
        return selectedPowerups.length > 0 ? 0 : -1
    }

    function openPowerupSelection(slotIndex) {
        if (!stackView || !powerupSelectionComponent)
            return

        const ids = []
        for (let i = 0; i < selectedPowerups.length; ++i) {
            const entry = selectedPowerups[i]
            ids.push(entry ? entry.id : null)
        }

        stackView.push(powerupSelectionComponent, {
            stackView: stackView,
            slotCount: powerupSlotCount,
            editorStore: editorStore,
            initialSelectionIds: ids,
            onBackRequested: function() {
                if (stackView)
                    stackView.pop()
            },
            onSelectionConfirmed: function(newSelection) {
                root.applySelection(newSelection)
                if (stackView)
                    stackView.pop()
            }
        })
    }

    function applySelection(selection) {
        if (!selection)
            return
        selectedPowerups = normalizedSelection(selection)
    }

    function startMatch() {
        if (filledSlotCount() < powerupSlotCount)
            return
        beginMatchRequested(loadoutSnapshot())
    }

    Component.onCompleted: updateLoadout(selectedPowerups)
    onPowerupSlotCountChanged: updateLoadout(selectedPowerups)
    onSelectedPowerupsChanged: updateLoadout(selectedPowerups)

    Rectangle {
        anchors.fill: parent
        color: "#070b16"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 28

        Label {
            text: qsTr("Single Player Loadout")
            font.pixelSize: 36
            font.bold: true
            color: "#f0f6fc"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Label {
                text: selectionHeading()
                color: "#9ca3af"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Adjust Loadout")
                enabled: powerupSlotCount > 0
                Layout.preferredWidth: 180
                onClicked: root.openPowerupSelection(root.firstEditableSlot())
            }
        }

        GridLayout {
            columns: Math.max(1, Math.min(2, powerupSlotCount))
            columnSpacing: 20
            rowSpacing: 20
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: powerupSlotCount
                delegate: SinglePlayerSelectPowerupSlot {
                    Layout.fillWidth: true
                    slotIndex: index
                    powerupOption: selectedPowerups[index]
                    onSelectRequested: function(slot) { root.openPowerupSelection(slot) }
                    onClearRequested: function(slot) {
                        const next = selectedPowerups.slice()
                        if (slot >= 0 && slot < next.length)
                            next[slot] = null
                        root.updateLoadout(next)
                    }
                }
            }
        }

        Label {
            text: qsTr("Tap a slot to refine it, or use Adjust Loadout to revisit the full catalog. Fill every slot before launching the match.")
            wrapMode: Text.WordWrap
            color: "#64748b"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: qsTr("Back to Main Menu")
                Layout.preferredWidth: 200
                onClicked: root.exitToMenuRequested()
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Start Match")
                enabled: powerupSlotCount > 0 && filledSlotCount() === powerupSlotCount
                Layout.preferredWidth: 200
                onClicked: root.startMatch()
            }
        }
    }
}
