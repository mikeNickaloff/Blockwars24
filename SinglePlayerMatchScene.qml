import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "."

GameScene {
    id: scene

    property var stackView
    property var playerLoadout: []
    property var cpuLoadout: []

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#020617"
    }

    SplitView {
        id: dashboards
        anchors.fill: parent
        orientation: Qt.Vertical

        SinglePlayerMatchDashboard {
            id: cpuDashboard
            Layout.fillWidth: true
            Layout.fillHeight: true
            powerupDataStore: PowerupDataStore { table: "cpuLoadout" }
            enemyPowerupDataStore: PowerupDataStore { table: "playerLoadout" }
            playerBlockPool: BlockPool {}
            enemyBlockPool: BlockPool {}
        }

        SinglePlayerMatchDashboard {
            id: playerDashboard
            Layout.fillWidth: true
            Layout.fillHeight: true
            isBottomGrid: true
            powerupDataStore: PowerupDataStore { table: "playerLoadout" }
            enemyPowerupDataStore: PowerupDataStore { table: "cpuLoadout" }
            playerBlockPool: BlockPool {}
            enemyBlockPool: BlockPool {}
        }
    }
}
