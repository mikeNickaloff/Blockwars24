import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24

GameScene {
    id: root

    implicitWidth: 1024
    implicitHeight: 768

    property var stackView
    property var playerLoadout: []
    property var cpuLoadout: []
    property string statusMessage: qsTr("Match preparation underway...")

    property var playerSlots: []
    property var cpuSlots: []

    signal exitRequested()

    function normalizeSlots(source) {
        const capacity = 4
        const slots = []
        for (let i = 0; i < capacity; ++i) {
            const entry = source && source[i] ? source[i] : null
            const card = entry && entry.powerup ? entry.powerup : null
            const accent = colorForKey(card ? card.colorKey : null)
            const lines = []
            if (entry && entry.summary && entry.summary.length)
                lines.push.apply(lines, entry.summary.slice(0, 3))
            else if (entry && entry.description)
                lines.push(entry.description)
            if (lines.length === 0)
                lines.push(qsTr("Awaiting configuration."))
            slots.push({
                title: card && card.name ? card.name : qsTr("Empty Slot"),
                lines: lines,
                accentColor: accent,
                energy: entry && entry.energy !== undefined ? entry.energy : 0
            })
        }
        return slots
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

    onPlayerLoadoutChanged: playerSlots = normalizeSlots(playerLoadout)
    onCpuLoadoutChanged: cpuSlots = normalizeSlots(cpuLoadout)

    Component.onCompleted: {
        cpuSlots = normalizeSlots(cpuLoadout)
        playerSlots = normalizeSlots(playerLoadout)
    }

    Rectangle {
        anchors.fill: parent
        color: "#060910"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 28

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: qsTr("Single Player Match")
                font.pixelSize: 34
                font.bold: true
                color: "#f1f5f9"
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Return to Loadout")
                onClicked: {
                    if (stackView)
                        stackView.pop()
                    exitRequested()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 24

            SinglePlayerMatchDashboard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("CPU Player Dashboard")
                mirrored: false
                meterColor: "#38bdf8"
                chargeProgress: 0
                powerupSlots: cpuSlots
            }

            Label {
                text: statusMessage
                color: "#94a3b8"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            SinglePlayerMatchDashboard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Player Dashboard")
                mirrored: true
                meterColor: "#34d399"
                chargeProgress: 0
                powerupSlots: playerSlots
            }
        }
    }
}
