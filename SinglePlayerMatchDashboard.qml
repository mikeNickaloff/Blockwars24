import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "."

GameScene {
    id: dashboardRoot

    property var powerupDataStore
    property var enemyPowerupDataStore
    property var playerBlockPool
    property var enemyBlockPool
    property bool isBottomGrid: false
    property string dashboardName: qsTr("Player")
    property int initialHealth: 1500
    property int startingSwaps: 0

    signal messageDispatched(var payload)

    readonly property alias healthHud: playerHealthHUD
    readonly property alias powerupSidebar: powerupSidebar
    readonly property alias gridElement: blockGridRoot

    property int _localPoolIndex: -1
    property int _remotePoolIndex: -1
    property bool _handshakeComplete: false
    property bool _localIndexShared: false

    QtObject {
        id: handshakeState
        property bool loadoutApplied: false
        property bool opponentLoadoutApplied: false
    }

    Rectangle {
        anchors.fill: parent
        color: "#020617"
        radius: 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        DashboardPlayerPowerupSidebar {
            id: powerupSidebar
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            powerupDataStore: powerupDataStore
        }

        ColumnLayout {
            id: dashboardColumn
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            DashboardPlayerHealthHUD {
                id: playerHealthHUD
                Layout.fillWidth: true
                health: dashboardRoot.initialHealth
                remainingSwitches: dashboardRoot.startingSwaps
                playerName: dashboardRoot.dashboardName
            }

            DashboardGridElement {
                id: blockGridRoot
                Layout.fillWidth: true
                Layout.fillHeight: true
                blockPool: dashboardRoot.playerBlockPool
                powerupDataStore: dashboardRoot.powerupDataStore
            }
        }
    }

    states: [
        State {
            name: "bottom"
            when: dashboardRoot.isBottomGrid
            PropertyChanges { target: dashboardColumn; LayoutMirroring.enabled: true }
            PropertyChanges { target: dashboardColumn; LayoutMirroring.childrenInherit: true }
        }
    ]

    Component.onCompleted: dashboardRoot._bootstrap()

    function configure(options) {
        const cfg = options || {}
        dashboardRoot.dashboardName = cfg.playerName || dashboardRoot.dashboardName
        dashboardRoot.initialHealth = cfg.health !== undefined ? cfg.health : dashboardRoot.initialHealth
        dashboardRoot.startingSwaps = cfg.startingSwaps !== undefined ? cfg.startingSwaps : dashboardRoot.startingSwaps
        playerHealthHUD.health = dashboardRoot.initialHealth
        playerHealthHUD.remainingSwitches = dashboardRoot.startingSwaps
        playerHealthHUD.playerName = dashboardRoot.dashboardName

        const loadout = Array.isArray(cfg.loadout) ? cfg.loadout : []
        if (powerupDataStore && powerupDataStore.setPowerupData) {
            powerupDataStore.setPowerupData(loadout)
            handshakeState.loadoutApplied = true
        }
        if (blockGridRoot && blockGridRoot.applyPowerupHighlights)
            blockGridRoot.applyPowerupHighlights(loadout)
        if (powerupSidebar)
            powerupSidebar.refresh()
    }

    function beginHandshake() {
        dashboardRoot._ensureLocalPoolIndex()
        dashboardRoot.messageDispatched({ type: "handshake" })
    }

    function receiveMessage(message) {
        if (!message || !message.type)
            return
        if (message.type === "handshake") {
            dashboardRoot._sharePowerupData()
            return
        }
        if (message.type === "sharePowerupData") {
            dashboardRoot._consumeOpponentLoadout(message.data)
            dashboardRoot._shareBlockPoolIndex()
            return
        }
        if (message.type === "shareBlockPoolIndex") {
            dashboardRoot._consumeOpponentPoolIndex(message.data)
            return
        }
    }

    function _sharePowerupData() {
        if (!powerupDataStore || !powerupDataStore.getPowerupData)
            return
        const payload = powerupDataStore.getPowerupData()
        dashboardRoot.messageDispatched({ type: "sharePowerupData", data: payload })
    }

    function _shareBlockPoolIndex() {
        dashboardRoot._ensureLocalPoolIndex()
        dashboardRoot._localIndexShared = true
        dashboardRoot.messageDispatched({ type: "shareBlockPoolIndex", data: dashboardRoot._localPoolIndex })
        dashboardRoot._finalizeHandshake()
    }

    function _consumeOpponentLoadout(data) {
        const opponentLoadout = Array.isArray(data) ? data : []
        if (enemyPowerupDataStore && enemyPowerupDataStore.setPowerupData)
            enemyPowerupDataStore.setPowerupData(opponentLoadout)
        handshakeState.opponentLoadoutApplied = true
        if (blockGridRoot && blockGridRoot.applyPowerupHighlights)
            blockGridRoot.applyPowerupHighlights(powerupDataStore ? powerupDataStore.getPowerupData() : [])
    }

    function _consumeOpponentPoolIndex(index) {
        if (enemyBlockPool && enemyBlockPool.setBlockPoolIndex)
            enemyBlockPool.setBlockPoolIndex(index)
        dashboardRoot._remotePoolIndex = Math.max(0, Math.floor(Number(index) || 0))
        if (dashboardRoot._localPoolIndex < 0)
            dashboardRoot._ensureLocalPoolIndex()
        if (!dashboardRoot._localIndexShared)
            dashboardRoot._shareBlockPoolIndex()
        else
            dashboardRoot._finalizeHandshake(true)
    }

    function _ensureLocalPoolIndex() {
        if (!playerBlockPool || !playerBlockPool.randomizeIndex)
            return
        if (dashboardRoot._localPoolIndex >= 0)
            return
        dashboardRoot._localPoolIndex = playerBlockPool.randomizeIndex()
        if (blockGridRoot && !blockGridRoot._boardInitialized)
            blockGridRoot.initializeBoard()
        dashboardRoot._localIndexShared = false
    }

    function _finalizeHandshake(force) {
        if (dashboardRoot._handshakeComplete)
            return
        if (!force && dashboardRoot._remotePoolIndex < 0)
            return
        if (dashboardRoot._localPoolIndex < 0)
            return
        dashboardRoot._handshakeComplete = true
        const startsFirst = dashboardRoot._localPoolIndex >= dashboardRoot._remotePoolIndex
        playerHealthHUD.remainingSwitches = startsFirst ? 3 : 0
        if (blockGridRoot)
            blockGridRoot.setGridState(startsFirst ? "match" : "waiting")
    }

    function _bootstrap() {
        if (powerupSidebar)
            powerupSidebar.refresh()
        if (blockGridRoot && blockGridRoot.initializeBoard)
            blockGridRoot.initializeBoard()
    }
}
