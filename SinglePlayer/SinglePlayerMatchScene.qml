import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "./components"
import "./controllers"
import "../Shared"
import "../lib/promise.js" as Q

GameScene {
    id: scene

    property var playerLoadout: []
    property var cpuLoadout: []
    property bool matchActive: false
    property int activeDashboardIndex: -1
    property var awaitingCascade: [false, false]
    property bool cpuThinking: false
    property bool humanCanSwap: false
    property var dashboardRegistry: ({})
    property var controllerRegistry: ({})
    property var fillCycleRequests: [false, false]
    property var loadoutHydrationMap: ({})
    property var readinessPromiseMap: ({})
    property var readinessResolved: ({})
    property var readinessAggregate: null
    property var bannerCollapsePromise: null
    property bool readinessLoggingEnabled: true

    signal exitRequested()

    property bool powerupsLoaded0: false
    property bool powerupsLoaded1: false
    property bool seedConfirmed0: false
    property bool seedConfirmed1: false
    property var seedPromiseMap: ({})
    property var seedAggregate: null
    property var initiativeResults: ({})
    property var initiativePromise: null

    CpuPlayerController {
        id: cpuController
        onLoadoutPrepared: function(index, loadout) {
            cpuLoadout = loadout
            scene._applyLoadout(index, loadout)
        }
        onInitiativeRolled: function(index, rollValue) { scene._handleInitiative(index, rollValue) }
    }

    HumanPlayerController {
        id: humanController
        onLoadoutPrepared: function(index, loadout) {
            scene._applyLoadout(index, loadout)
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

    readonly property int contentMargin: Math.max(16, Math.round(Math.min(width, height) * 0.04))
    readonly property int verticalSpacing: Math.max(12, Math.round(height * 0.02))

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: contentMargin
        spacing: verticalSpacing

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Exit")
                onClicked: scene.exitRequested()
            }

            Item { Layout.fillWidth: true }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: verticalSpacing

            MatchDashboard {
                id: cpuDashboard
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                dashboardIndex: 0
                onCascadeComplete: function(idx) { scene._handleCascadeComplete(idx) }
                onTurnCompleted: function(idx) { scene._handleTurnCompleted(idx) }
                onFillCycleStarted: function(idx) { scene._handleFillCycleStarted(idx) }
            }

            MatchDashboard {
                id: humanDashboard
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                dashboardIndex: 1
                onCascadeComplete: function(idx) { scene._handleCascadeComplete(idx) }
                onTurnCompleted: function(idx) { scene._handleTurnCompleted(idx) }
                onFillCycleStarted: function(idx) { scene._handleFillCycleStarted(idx) }
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
            opacity: 1
            property bool bannerFadeActive: false

            NumberAnimation {
                id: waitingBannerFadeOut
                target: waitingBanner
                property: "opacity"
                duration: 280
                easing.type: Easing.InOutQuad
                onRunningChanged: {
                    if (!running && waitingBanner.bannerFadeActive)
                        scene._onWaitingBannerFadeComplete()
                }
            }
        }
    }

    Component.onCompleted: scene._initialize()
    onPlayerLoadoutChanged: scene._prepareHumanLoadout()

    function _initialize() {
        waitingBanner.visible = true
        waitingBanner.opacity = 1
        waitingBanner.bannerFadeActive = false
        bannerCollapsePromise = null
        powerupsLoaded0 = false
        powerupsLoaded1 = false
        seedConfirmed0 = false
        seedConfirmed1 = false
        seedPromiseMap = ({})
        seedAggregate = null
        awaitingCascade = [false, false]
        cpuThinking = false
        humanCanSwap = false
        dashboardRegistry = ({})
        controllerRegistry = ({})
        fillCycleRequests = [false, false]
        initiativeResults = ({})
        initiativePromise = null
        _resetReadinessGate()
        _registerDashboard(0, cpuDashboard)
        _registerDashboard(1, humanDashboard)
        _registerController(0, cpuController)
        _registerController(1, humanController)
        const cpuHydration = cpuController.prepareLoadout()
        _registerLoadoutPromise(0, cpuHydration)
        _prepareHumanLoadout()
    }

    function _prepareHumanLoadout() {
        const entries = Array.isArray(playerLoadout) ? playerLoadout : []
        const promise = humanController.prepareLoadout(entries)
        if (promise && typeof promise.then === "function")
            _registerLoadoutPromise(1, promise)
        return promise
    }

    function _resetReadinessGate() {
        readinessPromiseMap = ({})
        readinessResolved = ({})
        readinessAggregate = null
        loadoutHydrationMap = ({})
        bannerCollapsePromise = null
    }

    function _registerLoadoutPromise(index, promise) {
        if (!promise || typeof promise.then !== "function")
            return
        const key = String(index)
        loadoutHydrationMap[key] = promise
        readinessPromiseMap[key] = promise
        readinessResolved[key] = false
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "tracked loadout promise", index)

        promise.then(function() {
            readinessResolved[key] = true
            if (index === 0)
                powerupsLoaded0 = true
            else if (index === 1)
                powerupsLoaded1 = true
            const controller = scene._controllerFor(index)
            if (controller)
                controller.hydrationPromise = null
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "loadout promise resolved", index)
        }, function(error) {
            console.error("Loadout hydration rejected", error)
        })

        _ensureReadinessAggregate()
    }

    function _resolvedPromise(value) {
        const promise = Q.promise()
        promise.resolve(value)
        return promise
    }

    function _ensureReadinessAggregate() {
        if (readinessAggregate)
            return
        const cpuPromise = readinessPromiseMap["0"]
        const humanPromise = readinessPromiseMap["1"]
        if (!cpuPromise || !humanPromise)
            return

        const aggregate = Q.all([cpuPromise, humanPromise])
        readinessAggregate = aggregate
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "readiness aggregate created")

        const self = scene
        aggregate.then(function() {
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "readiness aggregate resolved")
            const seedPromise = self._assignSeeds()
            if (seedPromise && typeof seedPromise.then === "function")
                return seedPromise
            return _resolvedPromise(true)
        }).then(function() {
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "collapsing waiting banner")
            return self._collapseWaitingBanner()
        }).then(function() {
            self.readinessAggregate = null
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "readiness pipeline finished")
        }, function(reason) {
            console.error("Readiness aggregate rejected", reason)
            self.readinessAggregate = null
        })
    }

    function _registerDashboard(index, instance) {
        const key = String(index)
        dashboardRegistry[key] = instance
        _synchronizeAssociation(index)
    }

    function _registerController(index, instance) {
        const key = String(index)
        controllerRegistry[key] = instance
        _synchronizeAssociation(index)
    }

    function _synchronizeAssociation(index) {
        const key = String(index)
        const dashboard = dashboardRegistry[key] || null
        const controller = controllerRegistry[key] || null
        if (dashboard)
            dashboard.controller = controller
        if (controller)
            controller.linkedDashboard = dashboard
    }

    function _dashboardFor(index) {
        return dashboardRegistry[String(index)] || null
    }

    function _controllerFor(index) {
        return controllerRegistry[String(index)] || null
    }

    function _applyLoadout(index, loadout) {
        const target = _dashboardFor(index)
        if (!target)
            return
        const key = String(index)
        let hydration = loadoutHydrationMap[key] || null
        if (!hydration) {
            const controller = _controllerFor(index)
            if (controller && controller.hydrationPromise)
                hydration = controller.hydrationPromise
        }
        const result = target.applyPowerupLoadout(loadout, hydration)
        if (result && typeof result.then === "function" && result !== hydration)
            _registerLoadoutPromise(index, result)
        else if (!loadoutHydrationMap[key] && hydration && typeof hydration.then === "function")
            loadoutHydrationMap[key] = hydration

        _ensureReadinessAggregate()
    }

    function _setSwapFor(index, enabled) {
        const target = _dashboardFor(index)
        if (target)
            target.setSwappingEnabled(enabled)
    }

    function _handleFillCycleStarted(index) {
        if (index < 0 || index > 1)
            return
        fillCycleRequests[index] = true
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "fillCycleStarted", index, fillCycleRequests)
        if (fillCycleRequests[0] && fillCycleRequests[1]) {
            fillCycleRequests = [false, false]
            _activateFillingChain()
        }
    }

    function _activateFillingChain() {
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "activateFillingChain")
        const cpuBoard = _dashboardFor(0)
        const humanBoard = _dashboardFor(1)
        if (cpuBoard)
            cpuBoard.transitionToFillingChain()
        if (humanBoard)
            humanBoard.transitionToFillingChain()
    }

    function _assignSeeds() {
        if (matchActive || seedAggregate)
            return seedAggregate

        const seeds = [seedHelper.nextSeed(), seedHelper.nextSeed()]
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "assigning seeds", seeds)
        const cpuBoard = _dashboardFor(0)
        const humanBoard = _dashboardFor(1)

        const promises = []

        if (cpuBoard) {
            const cpuPromise = cpuBoard.setBlockSeed(seeds[0])
            if (cpuPromise && typeof cpuPromise.then === "function") {
                seedPromiseMap["0"] = cpuPromise
                promises.push(cpuPromise)
                cpuPromise.then(function() {
                    seedConfirmed0 = true
                }, function(error) {
                    console.error("CPU seed confirmation rejected", error)
                })
            }
        }

        if (humanBoard) {
            const humanPromise = humanBoard.setBlockSeed(seeds[1])
            if (humanPromise && typeof humanPromise.then === "function") {
                seedPromiseMap["1"] = humanPromise
                promises.push(humanPromise)
                humanPromise.then(function() {
                    seedConfirmed1 = true
                }, function(error) {
                    console.error("Human seed confirmation rejected", error)
                })
            }
        }

        if (promises.length === 2) {
            seedAggregate = Q.all(promises)
            seedAggregate.then(function() {
                if (readinessLoggingEnabled)
                    console.debug("MatchScene", "seed aggregate resolved")
                seedAggregate = null
                seedPromiseMap = ({})
                scene._initializeGame()
            }, function(reason) {
                console.error("Seed aggregate rejected", reason)
                seedAggregate = null
                seedPromiseMap = ({})
                seedConfirmed0 = false
                seedConfirmed1 = false
            })
            return seedAggregate
        }

        return null
    }

    function _collapseWaitingBanner() {
        if (bannerCollapsePromise)
            return bannerCollapsePromise
        const collapse = Q.promise()
        if (!waitingBanner.visible) {
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "banner already collapsed")
            collapse.resolve(true)
            return collapse
        }
        bannerCollapsePromise = collapse
        waitingBannerFadeOut.stop()
        waitingBanner.bannerFadeActive = true
        waitingBannerFadeOut.from = waitingBanner.opacity
        waitingBannerFadeOut.to = 0
        waitingBannerFadeOut.start()
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "banner fade started")
        return collapse
    }

    function _onWaitingBannerFadeComplete() {
        waitingBanner.bannerFadeActive = false
        waitingBanner.visible = false
        waitingBanner.opacity = 1
        if (bannerCollapsePromise) {
            bannerCollapsePromise.resolve(true)
            bannerCollapsePromise = null
        }
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "banner collapse resolved")
    }

    function _initializeGame() {
        if (matchActive)
            return
        matchActive = true
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "initializeGame")
        const initiative = _requestInitiativeRoll()
        if (initiative && typeof initiative.then === "function") {
            initiative.then(function(outcome) {
                const nextIndex = outcome && outcome.winner !== undefined ? outcome.winner : 0
                activeDashboardIndex = nextIndex
                const collapse = scene._collapseWaitingBanner()
                if (collapse && typeof collapse.then === "function") {
                    if (readinessLoggingEnabled)
                        console.debug("MatchScene", "collapse promise available")
                    collapse.then(function() {
                        if (readinessLoggingEnabled)
                            console.debug("MatchScene", "banner collapsed, starting turn", nextIndex)
                        _startTurnFor(nextIndex)
                    })
                } else {
                    if (readinessLoggingEnabled)
                        console.debug("MatchScene", "starting turn immediately", nextIndex)
                    _startTurnFor(nextIndex)
                }
            }, function(error) {
                console.error("Initiative roll rejected", error)
            })
        }
    }

    function _requestInitiativeRoll() {
        if (initiativePromise && typeof initiativePromise.then === "function")
            return initiativePromise

        initiativeResults = ({})
        initiativePromise = Q.promise()
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "requestInitiativeRoll")

        cpuController.rollInitiative()
        humanController.rollInitiative()

        return initiativePromise
    }

    function _handleInitiative(index, rollValue) {
        if (!initiativePromise)
            return

        initiativeResults[String(index)] = rollValue
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "initiative roll", index, rollValue)

        if (initiativeResults["0"] !== undefined && initiativeResults["1"] !== undefined) {
            if (initiativeResults["0"] === initiativeResults["1"]) {
                initiativeResults = ({})
                if (readinessLoggingEnabled)
                    console.debug("MatchScene", "initiative tie reroll")
                cpuController.rollInitiative()
                humanController.rollInitiative()
                return
            }

            const winner = initiativeResults["0"] > initiativeResults["1"] ? 0 : 1
            const payload = {
                winner: winner,
                rolls: {
                    0: initiativeResults["0"],
                    1: initiativeResults["1"]
                }
            }

            const promise = initiativePromise
            initiativePromise = null
            if (promise && typeof promise.resolve === "function")
                promise.resolve(payload)
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "initiative winner", winner)
        }
    }

    function _startTurnFor(index) {
        activeDashboardIndex = index
        awaitingCascade = [false, false]
        awaitingCascade[index] = true
        fillCycleRequests = [false, false]
        humanCanSwap = false
        _setSwapFor(0, false)
        _setSwapFor(1, false)
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "startTurn", index)
        const activeBoard = _dashboardFor(index)
        const passiveBoard = _dashboardFor(index === 0 ? 1 : 0)
        if (index === 0) {
            cpuThinking = false
            if (activeBoard)
                activeBoard.beginTurn()
            if (passiveBoard)
                passiveBoard.observeTurn()
        } else {
            if (passiveBoard)
                passiveBoard.observeTurn()
            if (activeBoard)
                activeBoard.beginTurn()
        }
    }

    function _handleCascadeComplete(index) {
        if (index !== activeDashboardIndex)
            return
        if (awaitingCascade[index]) {
            awaitingCascade[index] = false
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "cascade complete", index)
            _notifyTurnReady(index)
            return
        }
        if (index === 0) {
            const board = _dashboardFor(0)
            const grid = board ? board.gridElement : null
            if (grid && grid.activeTurn && grid.swapsRemaining > 0)
                _triggerCpuMove()
        }
    }

    function _handleTurnCompleted(index) {
        if (index !== activeDashboardIndex)
            return
        const nextIndex = index === 0 ? 1 : 0
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "turn completed", index, "->", nextIndex)
        _startTurnFor(nextIndex)
    }

    function _notifyTurnReady(index) {
        if (index === 0) {
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "CPU ready")
            _triggerCpuMove()
        } else {
            humanCanSwap = true
            _setSwapFor(1, true)
            if (readinessLoggingEnabled)
                console.debug("MatchScene", "Human ready")
        }
    }

    function _triggerCpuMove() {
        if (cpuThinking)
            return
        if (readinessLoggingEnabled)
            console.debug("MatchScene", "triggerCpuMove")
        const controller = _controllerFor(0) || cpuController
        const board = _dashboardFor(0)
        const grid = board ? board.gridElement : null
        if (!grid || !grid.activeTurn || grid.swapsRemaining <= 0 || grid.gridState !== "match")
            return
        const move = controller ? controller.selectBestSwap(grid) : null
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
