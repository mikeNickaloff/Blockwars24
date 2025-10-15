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
    property var loadout: []

    signal exitToMenuRequested()
    signal beginMatchRequested(var selectedPowerups)

    function sanitizedEntry(entry, slotIndex) {
        if (!entry)
            return null

        const base = entry.powerup ? entry.powerup : entry
        const id = base.id || ""
        const name = base.name || entry.name || qsTr("Unnamed Powerup")
        const description = base.description || entry.description || qsTr("Configure this powerup in the editor to see its full description.")

        return ({
            slotIndex: slotIndex,
            id: id,
            name: name,
            description: description
        })
    }

    function normalizedSelection(source) {
        const count = Math.max(0, powerupSlotCount)
        const normalized = []
        for (let i = 0; i < count; ++i) {
            let entry = null
            if (source && source.length > i)
                entry = source[i]
            normalized.push(entry ? sanitizedEntry(entry, i) : null)
        }
        return normalized
    }

    function updateLoadout() {
        loadout = normalizedSelection(selectedPowerups)
    }

    function applySelection(selection) {
        selectedPowerups = normalizedSelection(selection)
    }

    function filledSlotCount() {
        let count = 0
        for (let i = 0; i < loadout.length; ++i) {
            if (loadout[i])
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
        const snapshot = []
        for (let i = 0; i < loadout.length; ++i)
            snapshot.push(loadout[i] ? sanitizedEntry(loadout[i], i) : null)
        return snapshot
    }

    function firstEditableSlot() {
        for (let i = 0; i < loadout.length; ++i) {
            if (!loadout[i])
                return i
        }
        return loadout.length > 0 ? 0 : -1
    }

    function openPowerupSelection(slotIndex) {
        if (!stackView || !powerupSelectionComponent)
            return

        const targetIndex = slotIndex >= 0 ? slotIndex : firstEditableSlot()
        const initialSelection = loadoutSnapshot()

        stackView.push(powerupSelectionComponent, {
            stackView: stackView,
            slotCount: powerupSlotCount,
            initialSelection: initialSelection,
            startSlotIndex: targetIndex,
            onBackRequested: function() {
                if (stackView)
                    stackView.pop()
            },
            onSelectionComplete: function(newSelection) {
                root.applySelection(newSelection)
                if (stackView)
                    stackView.pop()
            }
        })
    }

    function startMatch() {
        beginMatchRequested(loadoutSnapshot())
    }

    Component.onCompleted: updateLoadout()
    onPowerupSlotCountChanged: updateLoadout()
    onSelectedPowerupsChanged: updateLoadout()

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
            id: loadoutGrid
            columns: Math.max(1, Math.min(2, powerupSlotCount))
            columnSpacing: 20
            rowSpacing: 20
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: loadout.length

                delegate: PowerupLoadoutCard {
                    slotIndex: index
                    powerup: loadout[index]
                    active: false
                    interactive: true
                    emptyDescription: qsTr("Tap to assign a powerup to this slot.")
                    onClicked: root.openPowerupSelection(index)
                }
            }
        }

        Label {
            text: qsTr("Tap any slot to customize the equipped powerup. You can revisit the selection screen at any time before starting the match.")
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
                enabled: filledSlotCount() > 0
                Layout.preferredWidth: 200
                onClicked: root.startMatch()
            }
        }
    }
}
