import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."
import Blockwars24

Item {
    id: root
    // no implicit height or width due to stackView parent
    property var stackView
    property var playerPowerupDataStore: PowerupDataStore {

        table: "playerPowerups"
    }

    PowerupDataStore {
        id: playerDefaultPowerupDataStore
        table: "playerDefaultPowerups"
    }
    PowerupDataStore {
        id: computerPowerupDataStore
        table: "computerPowerups"
    }

    BlockPool {

     id: playerBlockPool
    }
    BlockPool {

     id: computerBlockPool
    }

    ChoosePowerupsModal {
        defaultPowerups: playerDefaultPowerupDataStore.getPowerupData()
        onPowerupsChosen: function(powerupData) {
            playerPowerupDataStore.setPowerupData(powerupData)
        }
    }
    Column {
        SinglePlayerMatchDashboard {
            id: topPlayerDashboard
            powerupDataStore: computerPowerupDataStore
            enemyPowerupDataStore: playerPowerupDataStore
            playerBlockPool: computerBlockPool
            enemyBlockPool: playerBlockPool
            onCommunicationSent: function(commData) { bottomPlayerDashboard.processCommunicationFromOpponent(commData) }
            isBottomGrid: false
        }
        MessageArea {

        }
        SinglePlayerMatchDashboard {
            id: bottomPlayerDashboard
            powerupDataStore: playerPowerupDataStore
            enemyPowerupDataStore: computerPowerupDataStore
            playerBlockPool: playerBlockPool
            enemyBlockPool: computerBlockPool
            onCommunicationSent: function(commData) { topPlayerDashboard.processCommunicationFromOpponent(commData) }
            isBottomGrid: true
        }
    }
}
