import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24

GameScene {
    id: root
    implicitWidth: 1024
    implicitHeight: 768

    property var stackView
    property int slotCount: 4
    property int activeSlotIndex: 0
    property var loadout: []
    property var initialSelection: []
    property int startSlotIndex: 0
    property var powerupOptions: [
        ({ id: "blazing_comet", name: qsTr("Blazing Comet"), description: qsTr("Launches a fiery barrage that scorches enemy blocks along a row.") }),
        ({ id: "starlight_barrier", name: qsTr("Starlight Barrier"), description: qsTr("Fortifies allied blocks with a temporary shield of radiant light.") }),
        ({ id: "tidal_surge", name: qsTr("Tidal Surge"), description: qsTr("Sweeps the lowest column, washing away weakened enemy defenses.") }),
        ({ id: "aurora_burst", name: qsTr("Aurora Burst"), description: qsTr("Charges a column with prismatic energy that heals friendly powerups.") })
    ]

    signal backRequested()
    signal selectionComplete(var selectedPowerups)

    readonly property bool selectionAvailable: filledSlotCount() > 0

    function sanitizedPowerupEntry(entry, slotIndex) {
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

    function commitLoadout(source) {
        const count = Math.max(0, slotCount)
        const normalized = []
        for (let i = 0; i < count; ++i) {
            let entry = null
            if (source && source.length > i)
                entry = source[i]
            normalized.push(entry ? sanitizedPowerupEntry(entry, i) : null)
        }
        loadout = normalized
        syncActiveSlot()
    }

    function ensureLoadout(source) {
        commitLoadout(source || loadout)
    }

    function syncActiveSlot() {
        const count = loadout.length
        if (count === 0) {
            activeSlotIndex = -1
            return
        }

        if (activeSlotIndex < 0 || activeSlotIndex >= count)
            activeSlotIndex = Math.max(0, Math.min(activeSlotIndex, count - 1))
    }

    function setActiveSlot(index) {
        if (loadout.length === 0) {
            activeSlotIndex = -1
            return
        }

        const clamped = Math.max(0, Math.min(index, loadout.length - 1))
        activeSlotIndex = clamped
    }

    function firstEmptySlot() {
        for (let i = 0; i < loadout.length; ++i) {
            if (!loadout[i])
                return i
        }
        return loadout.length > 0 ? 0 : -1
    }

    function slotIndexForOptionId(powerupId) {
        if (!powerupId)
            return -1
        for (let i = 0; i < loadout.length; ++i) {
            const entry = loadout[i]
            if (entry && entry.id === powerupId)
                return i
        }
        return -1
    }

    function filledSlotCount() {
        let count = 0
        for (let i = 0; i < loadout.length; ++i) {
            if (loadout[i])
                ++count
        }
        return count
    }

    function nextEmptySlot(startIndex) {
        if (loadout.length === 0)
            return -1

        for (let i = startIndex; i < loadout.length; ++i) {
            if (!loadout[i])
                return i
        }

        for (let i = 0; i < startIndex && i < loadout.length; ++i) {
            if (!loadout[i])
                return i
        }

        return -1
    }

    function advanceActiveSlot(fromIndex) {
        const nextIndex = nextEmptySlot(fromIndex + 1)
        if (nextIndex !== -1) {
            activeSlotIndex = nextIndex
            return
        }

        const wrapIndex = nextEmptySlot(0)
        if (wrapIndex !== -1) {
            activeSlotIndex = wrapIndex
            return
        }

        if (loadout.length > 0)
            activeSlotIndex = Math.max(0, Math.min(fromIndex, loadout.length - 1))
    }

    function assignOptionToActive(option) {
        if (!option || activeSlotIndex < 0 || activeSlotIndex >= loadout.length)
            return

        const sanitizedId = option.id || ""
        const next = loadout.slice()
        for (let i = 0; i < next.length; ++i) {
            const entry = next[i]
            if (entry && entry.id === sanitizedId)
                next[i] = null
        }
        next[activeSlotIndex] = option
        commitLoadout(next)
        advanceActiveSlot(activeSlotIndex)
    }

    function clearSlot(index) {
        if (index < 0 || index >= loadout.length)
            return
        const next = loadout.slice()
        next[index] = null
        commitLoadout(next)
        setActiveSlot(index)
    }

    function clearActiveSlot() {
        clearSlot(activeSlotIndex)
    }

    function clearAllSlots() {
        commitLoadout([])
        if (slotCount > 0)
            setActiveSlot(0)
    }

    function selectionSummaryText() {
        const filled = filledSlotCount()
        if (slotCount <= 0)
            return qsTr("No loadout slots available.")

        if (filled === 0)
            return qsTr("Choose powerups to fill your %1-card loadout.").arg(slotCount)

        if (filled === slotCount)
            return qsTr("All %1 powerup slots are ready to go!").arg(slotCount)

        return qsTr("%1 of %2 powerup slots prepared.").arg(filled).arg(slotCount)
    }

    function loadoutSnapshot() {
        const snapshot = []
        for (let i = 0; i < loadout.length; ++i)
            snapshot.push(loadout[i] ? sanitizedPowerupEntry(loadout[i], i) : null)
        return snapshot
    }

    function finalizeSelection() {
        selectionComplete(loadoutSnapshot())
    }

    Component.onCompleted: {
        commitLoadout(initialSelection)
        if (loadout.length > 0) {
            const candidate = startSlotIndex >= 0 ? startSlotIndex : firstEmptySlot()
            setActiveSlot(candidate >= 0 ? candidate : 0)
        }
    }

    onSlotCountChanged: ensureLoadout(initialSelection)
    onInitialSelectionChanged: ensureLoadout(initialSelection)
    onStartSlotIndexChanged: {
        if (startSlotIndex >= 0)
            setActiveSlot(startSlotIndex)
    }

    Rectangle {
        anchors.fill: parent
        color: "#0b1120"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        Label {
            text: qsTr("Select Powerups")
            font.pixelSize: 36
            font.bold: true
            color: "#f0f6fc"
            Layout.fillWidth: true
        }

        Label {
            text: selectionSummaryText()
            wrapMode: Text.WordWrap
            color: "#9ca3af"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 28

            ColumnLayout {
                Layout.preferredWidth: 320
                Layout.fillHeight: true
                spacing: 16

                Label {
                    text: qsTr("Loadout Slots")
                    font.pixelSize: 20
                    font.bold: true
                    color: "#f0f6fc"
                    Layout.fillWidth: true
                }

                GridLayout {
                    id: slotGrid
                    columns: Math.max(1, Math.min(2, slotCount))
                    columnSpacing: 16
                    rowSpacing: 16
                    Layout.fillWidth: true

                    Repeater {
                        model: loadout.length

                        delegate: PowerupLoadoutCard {
                            slotIndex: index
                            powerup: loadout[index]
                            active: index === root.activeSlotIndex
                            interactive: true
                            emptyDescription: qsTr("Tap a powerup card to assign it here.")
                            onClicked: root.setActiveSlot(index)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Button {
                        text: qsTr("Clear Slot")
                        enabled: activeSlotIndex >= 0 && loadout[activeSlotIndex]
                        Layout.fillWidth: true
                        onClicked: root.clearActiveSlot()
                    }

                    Button {
                        text: qsTr("Clear All")
                        enabled: filledSlotCount() > 0
                        Layout.fillWidth: true
                        onClicked: root.clearAllSlots()
                    }
                }

                Label {
                    text: qsTr("Select a slot, then tap a powerup to assign it. Reassigning a powerup moves it to the active slot.")
                    wrapMode: Text.WordWrap
                    color: "#64748b"
                    Layout.fillWidth: true
                }
            }

            ScrollView {
                id: optionScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                GridLayout {
                    id: optionGrid
                    width: optionScroll.availableWidth
                    columns: width > 640 ? 2 : 1
                    columnSpacing: 20
                    rowSpacing: 20
                    Layout.fillWidth: true

                    Repeater {
                        model: root.powerupOptions

                        delegate: powerupOptionDelegate
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: qsTr("Back")
                Layout.preferredWidth: 140
                onClicked: root.backRequested()
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Confirm Loadout")
                enabled: selectionAvailable
                Layout.preferredWidth: 200
                onClicked: root.finalizeSelection()
            }
        }
    }

    Component {
        id: powerupOptionDelegate

        Rectangle {
            id: card
            property var option: modelData || ({})
            property int assignedSlot: root.slotIndexForOptionId(option.id)

            implicitWidth: optionGrid.columns > 1 ? (optionGrid.width - optionGrid.columnSpacing) / optionGrid.columns : optionGrid.width
            implicitHeight: 168
            radius: 14
            color: assignedSlot !== -1 ? "#1f2937" : "#111827"
            border.width: assignedSlot === root.activeSlotIndex ? 2 : 1
            border.color: assignedSlot !== -1 ? (assignedSlot === root.activeSlotIndex ? "#38bdf8" : "#334155") : "#1f2937"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                Label {
                    text: option.name
                    font.pixelSize: 20
                    font.bold: true
                    color: "#f8fafc"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Label {
                    text: option.description
                    wrapMode: Text.WordWrap
                    color: "#9ca3af"
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillHeight: true
                }

                Label {
                    text: assignedSlot !== -1 ? qsTr("Assigned to Slot %1").arg(assignedSlot + 1) : qsTr("Available")
                    color: assignedSlot !== -1 ? "#38bdf8" : "#64748b"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
            }

            TapHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: root.assignOptionToActive(card.option)
            }
        }
    }
}
