import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../grid"
import "../../lib/promise.js" as Q

Item {
    id: dashboard

    required property int dashboardIndex
    property var loadout: []
    property int blockSeed: -1
    property bool observing: false
    property bool swappingEnabled: false
    property bool fillingChainPending: false
    property bool fillingChainEnabled: false
    property string phaseState: "waiting"
    property var controller: null
    property var cascadeCompletionPromise: null

    signal powerupDataLoaded(int dashboardIndex)
    signal seedConfirmed(int dashboardIndex, int seed)
    signal cascadeComplete(int dashboardIndex)
    signal turnCompleted(int dashboardIndex)
    signal fillCycleStarted(int dashboardIndex)

    function applyPowerupLoadout(entries, hydrationPromise) {
        loadout = Array.isArray(entries) ? entries : []
        powerupColumn.model = loadout

        const hydration = (hydrationPromise && typeof hydrationPromise.then === "function")
            ? hydrationPromise
            : Q.promise()

        loadoutHydrationPromise = hydration

        Qt.callLater(function() {
            if (hydration && typeof hydration.resolve === "function" && !hydration.isSettled)
                hydration.resolve({ index: dashboardIndex, loadout: loadout })
            dashboard.powerupDataLoaded(dashboard.dashboardIndex)
        })

        return hydration
    }

    function setBlockSeed(seedValue, confirmationPromise) {
        blockSeed = Number(seedValue)
        matchGrid.configureSpawnSeed(blockSeed)

        const confirmation = (confirmationPromise && typeof confirmationPromise.then === "function")
            ? confirmationPromise
            : Q.promise()

        seedConfirmationPromise = confirmation

        Qt.callLater(function() {
            if (confirmation && typeof confirmation.resolve === "function" && !confirmation.isSettled)
                confirmation.resolve({ index: dashboardIndex, seed: blockSeed })
            dashboard.seedConfirmed(dashboard.dashboardIndex, blockSeed)
        })

        return confirmation
    }

    function beginTurn() {
        observing = false
        matchGrid.beginTurn()
        setPhaseState("active")
        setSwappingEnabled(swappingEnabled)
    }

    function observeTurn() {
        observing = true
        setSwappingEnabled(false)
        matchGrid.observeTurn()
        setPhaseState("observing")
    }

    function setSwappingEnabled(enabled) {
        swappingEnabled = Boolean(enabled)
        _refreshSwapPermission()
    }

    function transitionToFillingChain() {
        fillingChainPending = false
        fillingChainEnabled = true
        setPhaseState(observing ? "observing" : "filling")
        _refreshSwapPermission()
    }

    function setPhaseState(state) {
        phaseState = state
        updateStatusLabel()
    }

    function updateStatusLabel() {
        if (fillingChainEnabled)
            statusLabel.text = observing ? qsTr("Observing (Cascade)") : qsTr("Cascading")
        else if (fillingChainPending)
            statusLabel.text = observing ? qsTr("Observing (Filling)") : qsTr("Preparing Cascade")
        else if (phaseState === "active")
            statusLabel.text = qsTr("Active")
        else if (phaseState === "observing")
            statusLabel.text = qsTr("Observing")
        else
            statusLabel.text = qsTr("Waiting")
    }

    function _refreshSwapPermission() {
        const allow = swappingEnabled && !observing && !fillingChainPending && !fillingChainEnabled
        matchGrid.setInteractionEnabled(allow)
    }

    implicitHeight: 0
    Layout.minimumHeight: 0
    Layout.preferredHeight: Math.max(320, parent ? parent.height * 0.48 : 360)

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: dashboardIndex === 0 ? "#111b2e" : "#0b162a"
        border.color: "#1e293b"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        readonly property int adaptiveMargin: Math.max(12, Math.round(Math.min(dashboard.width, dashboard.height) * 0.04))
        anchors.margins: adaptiveMargin
        spacing: Math.max(12, Math.round(dashboard.height * 0.035))

        MatchMomentumBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(12, Math.round(dashboard.height * 0.05))
            orientation: dashboardIndex === 0 ? Qt.TopEdge : Qt.BottomEdge
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Math.max(12, Math.round(dashboard.width * 0.03))

            GameGridElement {
                id: matchGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                Layout.minimumWidth: 0
                Layout.minimumHeight: 0
                fillDirection: dashboardIndex === 0 ? 1 : -1
                stateLoggingEnabled: true
                onFillCycleStarted: dashboard._handleFillCycleStarted()
                onTurnEnded: dashboard._handleTurnFinished()
            }

            PowerupColumn {
                id: powerupColumn
                readonly property real maxWidth: Math.max(160, dashboard.width * 0.22)
                Layout.preferredWidth: maxWidth
                Layout.maximumWidth: maxWidth
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                model: loadout
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                id: statusLabel
                text: qsTr("Waiting")
                color: "#f8fafc"
                font.pixelSize: 14
            }

            Item { Layout.fillWidth: true }

            Label {
                text: qsTr("Seed: %1").arg(blockSeed >= 0 ? blockSeed : "--")
                color: "#94a3b8"
                font.pixelSize: 12
            }
        }
    }

    property alias gridElement: matchGrid
    property var loadoutHydrationPromise: null
    property var seedConfirmationPromise: null

    Component.onCompleted: updateStatusLabel()

    function _handleFillCycleStarted() {
        fillingChainPending = true
        fillingChainEnabled = false
        setPhaseState(observing ? "observing" : "fillingPending")
        _refreshSwapPermission()
        fillCycleStarted(dashboardIndex)

        const pendingCascadePromise = matchGrid.awaitCascadeCompletion()
        if (pendingCascadePromise && typeof pendingCascadePromise.then === "function") {
            cascadeCompletionPromise = pendingCascadePromise
            pendingCascadePromise.then(function() {
                if (cascadeCompletionPromise !== pendingCascadePromise)
                    return
                cascadeCompletionPromise = null
                dashboard._handleCascadeFinished()
            }, function(error) {
                if (cascadeCompletionPromise === pendingCascadePromise)
                    cascadeCompletionPromise = null
                console.error("Cascade promise rejected", error)
                dashboard._handleCascadeFinished()
            })
        } else {
            cascadeCompletionPromise = null
            dashboard._handleCascadeFinished()
        }
    }

    function _handleCascadeFinished() {
        fillingChainPending = false
        fillingChainEnabled = false
        const nextPhase = observing ? "observing" : (matchGrid.activeTurn ? "active" : "waiting")
        setPhaseState(nextPhase)
        _refreshSwapPermission()
        cascadeComplete(dashboardIndex)
    }

    function _handleTurnFinished() {
        fillingChainPending = false
        fillingChainEnabled = false
        setPhaseState("waiting")
        _refreshSwapPermission()
        cascadeCompletionPromise = null
        turnCompleted(dashboardIndex)
    }
}
