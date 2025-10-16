import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."
import Blockwars24
GameScene {
    id: dashboardRoot
    property var powerupDataStore
    property var enemyPowerupDataStore
    property var playerBlockPool
    property var enemyBlockPool
    property bool isBottomGrid: false

    signal communicationSent(var commData)
    function sendCommunicationToOpponent(type, _data) {
        var msg = ({ type: type, data: _data})
        communicationSent(msg)
    }
    function processCommunicationFromOpponent(commData) {
        // do different things with different messages
        // commData is JSON data with various formats but all must share "type" property
        var commDataTpe = commData.type;
        if (!commDataType) {
            console.log("ERROR: received comm Data with no type",commData);
        }
        if (commDataType == "handshake") {
            sendCommunicationToOpponent("sharePowerupData", enemyPowerupDataStore.getPowerupData());
        }
        if (commDataType == "sharePowerupData") {
            enemyPowerupDataStore.setPowerupData(commData.data);
            powerupSidebar.refresh()
            sendCommunicationToOpponent("shareBlockPoolIndex", blockPool.randomizeIndex());
        }
        if (commDataType == "shareBlockPoolIndex") {
            enemyBlockPool.setBlockPoolIndex(commData.data);
            determineStartingTurn();
            blockGridRoot.setGridState("fill")

        }
    }

    function determineStartingTurn() {
       if (blockPool.getBlockPoolIndex() > enemyBlockool.getBlockPoolIndex()) {
           playerHealthHUD.remainingSwitches = 3;
       } else {
           playerHealthHUD.remainingSwitches = 0;
       }
    }

    DashboardPlayerHealthHUD {
        id: playerHealthHUD
        anchors.top: isBottomGrid ? blockGridRoot.bottom : dashboardRoot.top
        health: 1500
        remainingSwitches: 0
        playerName: "player"
        anchors.left:  blockGridRoot.left
        anchors.right:  blockGridRoot.right
    }

    DashboardPlayerPowerupSidebar {
        id: powerupSidebar
        powerupDataStore: powerupDataStore

    }
    DashboardGridElement {
        id: blockGridRoot
        powerupDataStore: powerupDataStore
        blockPool: playerBlockPool
    }
}
