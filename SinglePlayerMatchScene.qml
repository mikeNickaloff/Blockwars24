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

    signal exitRequested

    MatchDashboardLink {
        id: dashboardLink
    }

    Rectangle {
        anchors.fill: parent
        color: "#020617"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: qsTr("Exit Battle")
                onClicked: scene.exitRequested()
            }

            Label {
                text: qsTr("Single Player Battle")
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: 28
                font.bold: true
                color: "#f8fafc"
            }
        }

        SplitView {
            id: dashboards
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Vertical

            SinglePlayerMatchDashboard {
                id: cpuDashboard
                Layout.fillWidth: true
                Layout.fillHeight: true
                dashboardName: qsTr("CPU Commander")
                startingSwaps: 0
                powerupDataStore: PowerupDataStore { table: "cpuMatchLoadout" }
                enemyPowerupDataStore: PowerupDataStore { table: "playerMatchLoadout" }
                playerBlockPool: BlockPool {}
                enemyBlockPool: BlockPool {}
            }

            SinglePlayerMatchDashboard {
                id: playerDashboard
                Layout.fillWidth: true
                Layout.fillHeight: true
                isBottomGrid: true
                dashboardName: qsTr("Player")
                startingSwaps: 3
                powerupDataStore: PowerupDataStore { table: "playerMatchLoadout" }
                enemyPowerupDataStore: PowerupDataStore { table: "cpuMatchLoadout" }
                playerBlockPool: BlockPool {}
                enemyBlockPool: BlockPool {}
            }
        }
    }

    Component.onCompleted: scene._initialize()
    onPlayerLoadoutChanged: scene._configureDashboards()
    onCpuLoadoutChanged: scene._configureDashboards()

    function _initialize() {
        dashboardLink.bindDashboards(cpuDashboard, playerDashboard)
        scene._configureDashboards()
    }

    function _configureDashboards() {
        const cpuEntries = scene._normalizedEntries(cpuLoadout)
        const playerEntries = scene._normalizedEntries(playerLoadout)
        cpuDashboard.configure({
                                  playerName: qsTr("CPU Commander"),
                                  health: 1500,
                                  startingSwaps: 0,
                                  loadout: cpuEntries
                              })
        playerDashboard.configure({
                                     playerName: qsTr("Player"),
                                     health: 1500,
                                     startingSwaps: 3,
                                     loadout: playerEntries
                                 })
        dashboardLink.bindDashboards(cpuDashboard, playerDashboard)
        dashboardLink.startHandshake()
    }

    function _normalizedEntries(source) {
        const list = Array.isArray(source) ? source : []
        const normalized = []
        for (let i = 0; i < list.length; ++i) {
            const entry = list[i]
            if (!entry)
                continue
            normalized.push({
                                typeKey: entry.typeKey,
                                typeLabel: entry.typeLabel,
                                targetKey: entry.targetKey,
                                targetLabel: entry.targetLabel,
                                colorKey: entry.colorKey,
                                colorLabel: entry.colorLabel,
                                colorHex: entry.colorHex,
                                hp: entry.hp,
                                energy: entry.energy,
                                blocks: scene._sanitizeBlocks(entry.blocks)
                            })
        }
        return normalized
    }

    function _sanitizeBlocks(blocks) {
        const source = Array.isArray(blocks) ? blocks : []
        const sanitized = []
        const seen = {}
        for (let i = 0; i < source.length; ++i) {
            const cell = source[i]
            if (!cell)
                continue
            const row = Math.max(0, Math.min(5, Math.floor(Number(cell.row))))
            const column = Math.max(0, Math.min(5, Math.floor(Number(cell.column))))
            const key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        return sanitized
    }
}
