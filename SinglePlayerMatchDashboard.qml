import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    property bool mirrored: false
    property real chargeProgress: 0.0
    property color meterColor: "#38bdf8"
    property var powerupSlots: []
    property int dashboardIndex: -1
    property var commandBus
    property var loadoutEntries: []
    property int assignedSeed: 0

    signal dashboardCommandIssued(var dashboardIndex, var command, var payload)

    readonly property real clampedProgress: Math.max(0, Math.min(1, chargeProgress))

    implicitWidth: 900
    implicitHeight: 320

    Component.onCompleted: resetPowerupData()

    Connections {
        target: commandBus
        enabled: !!commandBus
        function onDispatchDashboardCommand(index, command, payload) {
            if (index !== root.dashboardIndex)
                return
            executeCommand(command, payload)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#0b1222"
        border.color: "#1e293b"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        Label {
            text: root.title
            font.pixelSize: 26
            font.bold: true
            color: "#e2e8f0"
            Layout.fillWidth: true
        }

        Loader {
            active: !root.mirrored
            sourceComponent: ProgressBar {
                id: topMeter
                from: 0
                to: 1
                value: root.clampedProgress
                Layout.fillWidth: true
                Layout.preferredHeight: 16
                background: Rectangle {
                    radius: 8
                    color: "#10172b"
                    border.color: "#1e293b"
                    border.width: 1
                }
                contentItem: Item {
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        height: topMeter.height - 4
                        width: topMeter.visualPosition * topMeter.width
                        radius: (height) / 2
                        color: root.meterColor
                    }
                }
            }
        }

        GridLayout {
            id: dashboardLayout
            Layout.fillWidth: true
            columnSpacing: 24
            rowSpacing: 24
            columns: root.width > 720 ? 2 : 1

            SinglePlayerMatchGrid {
                Layout.fillWidth: true
                Layout.minimumWidth: 280
                Layout.minimumHeight: 280
                Layout.preferredWidth: dashboardLayout.columns > 1 ? Math.min(520, root.width * 0.6) : root.width
                Layout.preferredHeight: Math.max(280, implicitHeight)
                Layout.columnSpan: 1
                Layout.row: 0
                Layout.column: 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: dashboardLayout.columns > 1 ? Math.max(220, root.width * 0.35) : root.width
                Layout.minimumWidth: 200
                Layout.maximumWidth: dashboardLayout.columns > 1 ? 360 : root.width
                Layout.row: dashboardLayout.columns > 1 ? 0 : 1
                Layout.column: dashboardLayout.columns > 1 ? 1 : 0
                Layout.alignment: Qt.AlignTop
                spacing: 14

                Repeater {
                    model: 4
                    delegate: SinglePlayerMatchPowerupCard {
                        title: slotData(index).title
                        lines: slotData(index).lines
                        accentColor: slotData(index).accentColor
                        energy: slotData(index).energy
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Loader {
            active: root.mirrored
            sourceComponent: ProgressBar {
                id: bottomMeter
                from: 0
                to: 1
                value: root.clampedProgress
                Layout.fillWidth: true
                Layout.preferredHeight: 16
                background: Rectangle {
                    radius: 8
                    color: "#10172b"
                    border.color: "#1e293b"
                    border.width: 1
                }
                contentItem: Item {
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        height: bottomMeter.height - 4
                        width: bottomMeter.visualPosition * bottomMeter.width
                        radius: (height) / 2
                        color: root.meterColor
                    }
                }
            }
        }
    }

    function slotData(index) {
        const fallback = {
            title: qsTr("Empty Slot"),
            lines: [qsTr("No powerup assigned.")],
            accentColor: "#334155",
            energy: 0
        }
        if (!powerupSlots || powerupSlots.length <= index || index < 0)
            return fallback
        const entry = powerupSlots[index]
        if (!entry)
            return fallback
        return {
            title: entry.title !== undefined ? entry.title : fallback.title,
            lines: entry.lines !== undefined ? entry.lines : fallback.lines,
            accentColor: entry.accentColor !== undefined ? entry.accentColor : fallback.accentColor,
            energy: entry.energy !== undefined ? entry.energy : fallback.energy
        }
    }

    function executeCommand(command, payload) {
        switch (command) {
        case "SetPowerupData":
            setPowerupData(payload)
            break
        case "ResetPowerupData":
            resetPowerupData()
            break
        default:
            break
        }
    }

    function setPowerupData(payload) {
        loadoutEntries = normalizeEntries(payload)
        powerupSlots = buildSlotSummaries(loadoutEntries)
        notifyPowerDataLoaded()
    }

    function resetPowerupData() {
        loadoutEntries = []
        powerupSlots = []
    }

    function normalizeEntries(payload) {
        const normalized = []
        const capacity = 4
        for (let i = 0; i < capacity; ++i) {
            const entry = payload && payload[i] ? payload[i] : null
            normalized.push(entry)
        }
        return normalized
    }

    function buildSlotSummaries(entries) {
        const slots = []
        const capacity = 4
        for (let i = 0; i < capacity; ++i)
            slots.push(transformEntry(entries[i]))
        return slots
    }

    function transformEntry(entry) {
        if (!entry)
            return defaultSlot()
        const powerup = entry.powerup || null
        const lines = []
        if (entry.summary && entry.summary.length)
            lines.push.apply(lines, entry.summary.slice(0, 3))
        else if (entry.description)
            lines.push(entry.description)
        if (!lines.length)
            lines.push(qsTr("Awaiting configuration."))
        return {
            title: powerup && powerup.name ? powerup.name : qsTr("Empty Slot"),
            lines: lines,
            accentColor: colorForKey(powerup ? powerup.colorKey : null),
            energy: entry.energy !== undefined ? entry.energy : 0
        }
    }

    function defaultSlot() {
        return {
            title: qsTr("Empty Slot"),
            lines: [qsTr("Awaiting configuration.")],
            accentColor: colorForKey(null),
            energy: 0
        }
    }

    function colorForKey(key) {
        switch (key) {
        case "red": return "#f87171"
        case "blue": return "#60a5fa"
        case "green": return "#4ade80"
        case "yellow": return "#facc15"
        default: return "#475569"
        }
    }

    function notifyPowerDataLoaded() {
        if (dashboardIndex < 0)
            return
        dashboardCommandIssued(dashboardIndex, "PowerDataLoaded", { slotCount: powerupSlots.length })
    }

    function setSeed(value) {
        const numeric = Math.floor(Number(value))
        const clamped = Math.max(1, Math.min(500, isNaN(numeric) ? 0 : numeric))
        assignedSeed = clamped
        if (dashboardIndex < 0)
            return
        dashboardCommandIssued(dashboardIndex, "indexSet", { seed: assignedSeed })
    }
}
