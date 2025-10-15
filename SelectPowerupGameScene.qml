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
    property var powerupOptions: []
    property var powerupOptionsProvider: null

    signal backRequested()
    signal selectionComplete(var selectedPowerups)

    readonly property bool selectionAvailable: slotCount > 0 && filledSlotCount() === slotCount

    PowerupLoadoutHelper {
        id: loadoutHelper
    }

    function commitLoadout(source) {
        loadout = loadoutHelper.normalizeSelection(source, slotCount)
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

        if (loadout.length > 0)
            activeSlotIndex = Math.max(0, Math.min(fromIndex, loadout.length - 1))
    }

    function assignOptionToActive(option) {
        if (!option || activeSlotIndex < 0 || activeSlotIndex >= loadout.length)
            return
        const next = loadout.slice()
        next[index] = null
        commitLoadout(next)
        setActiveSlot(index)
    }

        const sanitized = loadoutHelper.createLoadoutEntry(option, activeSlotIndex)
        if (!sanitized)
            return

        const next = loadout.slice()
        for (let i = 0; i < next.length; ++i) {
            const entry = next[i]
            if (entry && entry.id === sanitized.id)
                next[i] = null
        }
        next[activeSlotIndex] = sanitized
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

        const missing = slotCount - filled
        return missing > 0
                ? qsTr("Select %1 more powerup%2 to finish your loadout.")
                      .arg(missing)
                      .arg(missing === 1 ? "" : "s")
                : qsTr("All %1 powerup slots are ready to go!").arg(slotCount)
    }

    function loadoutSnapshot() {
        return loadoutHelper.normalizeSelection(loadout, loadout.length)
    }

    function finalizeSelection() {
        selectionComplete(loadoutSnapshot())
    }

    Component.onCompleted: {
        refreshPowerupOptions()
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

    onPowerupOptionsProviderChanged: refreshPowerupOptions()
    onPowerupOptionsChanged: ensureLoadout(loadout)

    function refreshPowerupOptions() {
        if (powerupOptionsProvider) {
            const supplied = powerupOptionsProvider()
            if (supplied)
                powerupOptions = supplied
        }
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

                ColumnLayout {
                    width: optionScroll.availableWidth
                    spacing: 20

                    Label {
                        visible: root.powerupOptions.length === 0
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        color: "#cbd5f5"
                        text: qsTr("Create a custom powerup in the editor or use the defaults to build your loadout.")
                    }

                    GridLayout {
                        id: optionGrid
                        columns: optionScroll.availableWidth > 640 ? 2 : 1
                        columnSpacing: 20
                        rowSpacing: 20
                        Layout.fillWidth: true
                        visible: root.powerupOptions.length > 0

                        Repeater {
                            model: root.powerupOptions

                            delegate: powerupOptionDelegate
                        }
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
            implicitHeight: 196
            radius: 16
            color: assignedSlot !== -1 ? Qt.lighter(option.powerup.colorHex || "#1f2937", 1.25) : "#111827"
            border.width: assignedSlot === root.activeSlotIndex ? 2 : 1
            border.color: assignedSlot === root.activeSlotIndex ? "#38bdf8" : (option.powerup.colorHex || "#1f2937")

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
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 10
                        color: option.powerup.colorHex || "#1f2937"
                        border.width: 0
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Label {
                            text: option.name
                            font.pixelSize: 20
                            font.bold: true
                            color: "#f8fafc"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }

                        Label {
                            text: option.powerup.effectSummary
                            color: "#cbd5f5"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: option.tags || []

                        delegate: Rectangle {
                            radius: 8
                            color: "#1f2937"
                            border.width: 1
                            border.color: "#334155"
                            height: 24

                            Label {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 11
                                color: "#94a3b8"
                            }
                        }
                    }
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
