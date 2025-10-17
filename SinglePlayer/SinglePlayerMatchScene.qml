import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "./components"
import "./controllers"
import "../Shared"

GameScene {
    id: scene

    property var playerLoadout: []
    property var cpuLoadout: []
    property bool matchActive: false
    property int activeDashboardIndex: -1

    signal exitRequested()

    property bool powerupsLoaded0: false
    property bool powerupsLoaded1: false
    property bool seedConfirmed0: false
    property bool seedConfirmed1: false
    property var initiativeResults: ({})

    CpuPlayerController {
        id: cpuController
        onLoadoutPrepared: function(index, loadout) {
            cpuLoadout = loadout
            cpuDashboard.applyPowerupLoadout(loadout)
        }
        onInitiativeRolled: function(index, rollValue) { scene._handleInitiative(index, rollValue) }
    }

    HumanPlayerController {
        id: humanController
        onLoadoutPrepared: function(index, loadout) {
            humanDashboard.applyPowerupLoadout(loadout)
        }
        onInitiativeRolled: function(index, rollValue) { scene._handleInitiative(index, rollValue) }
    }

    QtObject {
        id: seedHelper
        function nextSeed() {
            return Math.floor(Math.random() * 500) + 1
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#020617"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Exit")
                onClicked: scene.exitRequested()
            }

            Item { Layout.fillWidth: true }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Vertical

            MatchDashboard {
                id: cpuDashboard
                Layout.fillWidth: true
                Layout.fillHeight: true
                dashboardIndex: 0
                onPowerupDataLoaded: function(idx) { scene._markPowerupLoaded(idx) }
                onSeedConfirmed: function(idx, seed) { scene._markSeedConfirmed(idx) }
            }

            MatchDashboard {
                id: humanDashboard
                Layout.fillWidth: true
                Layout.fillHeight: true
                dashboardIndex: 1
                onPowerupDataLoaded: function(idx) { scene._markPowerupLoaded(idx) }
                onSeedConfirmed: function(idx, seed) { scene._markSeedConfirmed(idx) }
            }
        }

        Label {
            id: waitingBanner
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Waiting for both dashboards to initialize…")
            color: "#38bdf8"
            font.pixelSize: 18
            visible: true
        }
    }

    Component.onCompleted: scene._initialize()
    onPlayerLoadoutChanged: scene._prepareHumanLoadout()

    function _initialize() {
        waitingBanner.visible = true
        powerupsLoaded0 = false
        powerupsLoaded1 = false
        seedConfirmed0 = false
        seedConfirmed1 = false
        cpuController.prepareLoadout()
        _prepareHumanLoadout()
    }

    function _prepareHumanLoadout() {
        if (!playerLoadout || playerLoadout.length === 0)
            return
        humanController.prepareLoadout(playerLoadout)
    }

    function _markPowerupLoaded(index) {
        if (index === 0)
            powerupsLoaded0 = true
        else if (index === 1)
            powerupsLoaded1 = true
        if (powerupsLoaded0 && powerupsLoaded1)
            _assignSeeds()
    }

    function _assignSeeds() {
        if (seedConfirmed0 || seedConfirmed1)
            return
        const seed0 = seedHelper.nextSeed()
        const seed1 = seedHelper.nextSeed()
        cpuDashboard.setBlockSeed(seed0)
        humanDashboard.setBlockSeed(seed1)
    }

    function _markSeedConfirmed(index) {
        if (index === 0)
            seedConfirmed0 = true
        else if (index === 1)
            seedConfirmed1 = true
        if (seedConfirmed0 && seedConfirmed1)
            _initializeGame()
    }

    function _initializeGame() {
        if (matchActive)
            return
        matchActive = true
        _requestInitiativeRoll()
    }

    function _requestInitiativeRoll() {
        initiativeResults = ({})
        cpuController.rollInitiative()
        humanController.rollInitiative()
    }

    function _handleInitiative(index, rollValue) {
        initiativeResults[String(index)] = rollValue
        if (initiativeResults["0"] !== undefined && initiativeResults["1"] !== undefined) {
            if (initiativeResults["0"] === initiativeResults["1"]) {
                initiativeResults = ({})
                _requestInitiativeRoll()
                return
            }
            activeDashboardIndex = initiativeResults["0"] > initiativeResults["1"] ? 0 : 1
            waitingBanner.visible = false
            if (activeDashboardIndex === 0) {
                cpuDashboard.beginTurn()
                humanDashboard.observeTurn()
            } else {
                humanDashboard.beginTurn()
                cpuDashboard.observeTurn()
            }
        }
    }
}
