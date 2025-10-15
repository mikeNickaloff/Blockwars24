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
    property var playerLoadout: []
    property var cpuLoadout: []
    property var editorStore
    property string statusMessage: qsTr("Waiting for Opponent")

    property bool powerupsLoaded0: false
    property bool powerupsLoaded1: false
    property bool seedsIssued: false
    property bool seedAcknowledged0: false
    property bool seedAcknowledged1: false
    property int seedValue0: 0
    property int seedValue1: 0

    readonly property int slotCapacity: 4

    signal exitRequested()
    signal dispatchDashboardCommand(int dashboardIndex, string command, var payload)

    Settings {
        id: loadoutSettings
        category: "singleplayer_loadout"
        property var savedIds: []
    }

    SinglePlayerPowerupRepository {
        id: powerupRepository
        editorStore: root.editorStore
    }

    QtObject {
        id: cpuAgent

        property int slotCount: root.slotCapacity

        signal loadoutReady(var loadout)

        function initialize() {
            const defaults = powerupRepository.buildDefaultOptions()
            const deck = defaults ? defaults.slice() : []
            const chosen = []
            const count = Math.max(0, slotCount)
            for (let i = 0; i < count; ++i) {
                if (!deck.length)
                    break
                const index = Math.floor(Math.random() * deck.length)
                const option = deck.splice(index, 1)[0]
                if (option)
                    chosen.push(option)
            }
            while (chosen.length < count)
                chosen.push(null)
            loadoutReady(chosen)
        }
    }

    QtObject {
        id: playerAgent

        property int slotCount: root.slotCapacity

        signal loadoutReady(var loadout)

        function initialize() {
            const ids = loadoutSettings.savedIds || []
            const options = []
            const count = Math.max(0, slotCount)
            for (let i = 0; i < count; ++i) {
                const identifier = ids[i]
                const option = identifier ? powerupRepository.optionById(identifier) : null
                options.push(option)
            }
            loadoutReady(options)
        }
    }

    Connections {
        target: cpuAgent
        function onLoadoutReady(loadout) {
            applyCpuLoadout(loadout)
        }
    }

    Connections {
        target: playerAgent
        function onLoadoutReady(loadout) {
            applyPlayerLoadout(loadout)
        }
    }

    function applyCpuLoadout(entries) {
        cpuLoadout = normalizeLoadout(entries)
        dispatchDashboardCommand(0, "SetPowerupData", cpuLoadout)
    }

    function applyPlayerLoadout(entries) {
        playerLoadout = normalizeLoadout(entries)
        dispatchDashboardCommand(1, "SetPowerupData", playerLoadout)
    }

    function normalizeLoadout(source) {
        const normalized = []
        for (let i = 0; i < slotCapacity; ++i) {
            const entry = source && source[i] ? source[i] : null
            normalized.push(normalizeEntry(entry))
        }
        return normalized
    }

    function normalizeEntry(entry) {
        if (!entry)
            return { id: null, powerup: null, summary: [], description: "", energy: 0 }

        const powerup = entry.powerup ? entry.powerup : null
        const summary = entry.summary ? entry.summary.slice(0, 3) : []
        const description = entry.description || ""
        const energy = entry.energy !== undefined ? entry.energy : 0
        const identifier = entry.id !== undefined ? entry.id : null
        const normalizedPowerup = powerup ? {
            name: powerup.name || qsTr("Powerup"),
            typeKey: powerup.typeKey || "enemy",
            targetKey: powerup.targetKey || "blocks",
            colorKey: powerup.colorKey || "red",
            hp: powerup.hp !== undefined ? powerup.hp : 0,
            blocks: powerup.blocks ? powerup.blocks.slice() : []
        } : null

        return {
            id: identifier,
            powerup: normalizedPowerup,
            summary: summary,
            description: description,
            energy: energy
        }
    }

    function resetMatchState() {
        powerupsLoaded0 = false
        powerupsLoaded1 = false
        seedsIssued = false
        seedAcknowledged0 = false
        seedAcknowledged1 = false
        seedValue0 = 0
        seedValue1 = 0
        statusMessage = qsTr("Waiting for Opponent")
    }

    function startMatchSetup() {
        resetMatchState()
        cpuAgent.initialize()
        playerAgent.initialize()
    }

    function handleDashboardCommand(dashboardIndex, command, payload) {
        if (command === "PowerDataLoaded") {
            handlePowerDataLoaded(dashboardIndex)
        } else if (command === "indexSet") {
            acknowledgeSeed(dashboardIndex, payload)
        }
    }

    function handlePowerDataLoaded(dashboardIndex) {
        if (dashboardIndex === 0)
            powerupsLoaded0 = true
        else if (dashboardIndex === 1)
            powerupsLoaded1 = true
        maybeDistributeSeeds()
    }

    function maybeDistributeSeeds() {
        if (!powerupsLoaded0 || !powerupsLoaded1 || seedsIssued)
            return
        seedsIssued = true
        seedAcknowledged0 = false
        seedAcknowledged1 = false
        seedValue0 = randomSeed()
        seedValue1 = randomSeed()
        statusMessage = qsTr("Synchronizing match grids...")
        cpuDashboard.setSeed(seedValue0)
        playerDashboard.setSeed(seedValue1)
    }

    function randomSeed() {
        return Math.floor(Math.random() * 500) + 1
    }

    function acknowledgeSeed(dashboardIndex, payload) {
        const value = payload && payload.seed !== undefined ? Number(payload.seed) : 0
        if (dashboardIndex === 0) {
            seedAcknowledged0 = true
            if (value)
                seedValue0 = value
        } else if (dashboardIndex === 1) {
            seedAcknowledged1 = true
            if (value)
                seedValue1 = value
        }
        if (seedAcknowledged0 && seedAcknowledged1)
            statusMessage = qsTr("Match synchronized. Ready to begin!")
    }

    Component.onCompleted: Qt.callLater(startMatchSetup)

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

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 0
            clip: true
            contentWidth: availableWidth
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                id: matchContent
                width: parent ? parent.availableWidth : implicitWidth
                spacing: 24
                Layout.fillWidth: true

                SinglePlayerMatchDashboard {
                    id: cpuDashboard
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    title: qsTr("CPU Player Dashboard")
                    mirrored: false
                    meterColor: "#38bdf8"
                    chargeProgress: 0
                    dashboardIndex: 0
                    commandBus: root
                    onDashboardCommandIssued: function(dashboardIndex, command,payload) { handleDashboardCommand(dashboardIndex, command, payload) }
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
                    id: playerDashboard
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    title: qsTr("Player Dashboard")
                    mirrored: true
                    meterColor: "#34d399"
                    chargeProgress: 0
                    dashboardIndex: 1
                    commandBus: root
                    onDashboardCommandIssued: function(dashboardIndex, command,payload) { handleDashboardCommand(dashboardIndex, command, payload) }
                }
            }
        }
    }
}
