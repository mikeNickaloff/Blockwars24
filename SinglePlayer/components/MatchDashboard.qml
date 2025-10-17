import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../grid"

Item {
    id: dashboard

    required property int dashboardIndex
    property var loadout: []
    property int blockSeed: -1
    property bool observing: false

    signal powerupDataLoaded(int dashboardIndex)
    signal seedConfirmed(int dashboardIndex, int seed)
    signal cascadeComplete(int dashboardIndex)
    signal turnCompleted(int dashboardIndex)

    function applyPowerupLoadout(entries) {
        loadout = Array.isArray(entries) ? entries : []
        powerupColumn.model = loadout
        Qt.callLater(function() {
            dashboard.powerupDataLoaded(dashboard.dashboardIndex)
        })
    }

    function setBlockSeed(seedValue) {
        blockSeed = Number(seedValue)
        Qt.callLater(function() {
            dashboard.seedConfirmed(dashboard.dashboardIndex, blockSeed)
        })
    }

    function beginTurn() {
        statusLabel.text = qsTr("Active")
        observing = false
        matchGrid.beginTurn()
    }

    function observeTurn() {
        statusLabel.text = qsTr("Observing")
        observing = true
        matchGrid.observeTurn()
    }

    implicitHeight: 360

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: dashboardIndex === 0 ? "#111b2e" : "#0b162a"
        border.color: "#1e293b"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        MatchMomentumBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 18
            orientation: dashboardIndex === 0 ? Qt.TopEdge : Qt.BottomEdge
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 24

            GameGridElement {
                id: matchGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                onCascadeEnded: dashboard.cascadeComplete(dashboard.dashboardIndex)
                onTurnEnded: dashboard.turnCompleted(dashboard.dashboardIndex)
            }

            PowerupColumn {
                id: powerupColumn
                Layout.preferredWidth: 240
                Layout.maximumWidth: 280
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
}
