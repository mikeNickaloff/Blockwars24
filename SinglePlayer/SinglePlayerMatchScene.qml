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
    property var awaitingCascade: [false, false]
    property bool cpuThinking: false
    property bool humanCanSwap: false

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
                onCascadeComplete: function(idx) { scene._handleCascadeComplete(idx) }
                onTurnCompleted: function(idx) { scene._handleTurnCompleted(idx) }
            }

            MatchDashboard {
                id: humanDashboard
                Layout.fillWidth: true
                Layout.fillHeight: true
                dashboardIndex: 1
                onPowerupDataLoaded: function(idx) { scene._markPowerupLoaded(idx) }
                onSeedConfirmed: function(idx, seed) { scene._markSeedConfirmed(idx) }
                onCascadeComplete: function(idx) { scene._handleCascadeComplete(idx) }
                onTurnCompleted: function(idx) { scene._handleTurnCompleted(idx) }
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
        awaitingCascade = [false, false]
        cpuThinking = false
        humanCanSwap = false
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
            _startTurnFor(activeDashboardIndex)
        }
    }

    function _startTurnFor(index) {
        activeDashboardIndex = index
        awaitingCascade = [false, false]
        awaitingCascade[index] = true
        if (index === 0) {
            cpuThinking = false
            humanCanSwap = false
            cpuDashboard.beginTurn()
            humanDashboard.observeTurn()
        } else {
            humanCanSwap = false
            cpuDashboard.observeTurn()
            humanDashboard.beginTurn()
        }
    }

    function _handleCascadeComplete(index) {
        if (index !== activeDashboardIndex)
            return
        if (awaitingCascade[index]) {
            awaitingCascade[index] = false
            _notifyTurnReady(index)
            return
        }
        if (index === 0) {
            const grid = cpuDashboard.gridElement
            if (grid.activeTurn && grid.swapsRemaining > 0)
                _triggerCpuMove()
        }
    }

    function _handleTurnCompleted(index) {
        if (index !== activeDashboardIndex)
            return
        const nextIndex = index === 0 ? 1 : 0
        _startTurnFor(nextIndex)
    }

    function _notifyTurnReady(index) {
        if (index === 0)
            _triggerCpuMove()
        else
            humanCanSwap = true
    }

    function _triggerCpuMove() {
        if (cpuThinking)
            return
        const grid = cpuDashboard.gridElement
        if (!grid.activeTurn || grid.swapsRemaining <= 0 || grid.gridState !== "match")
            return
        const move = cpuController.selectBestSwap(grid)
        if (!move) {
            grid.endTurnEarly()
            return
        }
        cpuThinking = true
        const success = grid.requestSwap(move.row1, move.column1, move.row2, move.column2)
        cpuThinking = false
        if (!success)
            grid.endTurnEarly()
    }

}
