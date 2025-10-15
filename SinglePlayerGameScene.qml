import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24

GameScene {
    id: root
    implicitWidth: 1024
    implicitHeight: 768

    property var stackView
    property var selectedPowerups: []

    signal exitToMenuRequested()
    signal beginMatchRequested(var selectedPowerups)

    function selectedPowerupsSnapshot() {
        if (!selectedPowerups)
            return []
        return selectedPowerups.map(function(powerup) {
            return ({ id: powerup.id, name: powerup.name, description: powerup.description })
        })
    }

    function selectionHeading() {
        const count = selectedPowerups ? selectedPowerups.length : 0
        if (count === 0)
            return qsTr("No powerups equipped")
        if (count === 1)
            return qsTr("1 powerup ready for battle")
        return qsTr("%1 powerups ready for battle").arg(count)
    }

    function startMatch() {
        beginMatchRequested(selectedPowerupsSnapshot())
    }

    Rectangle {
        anchors.fill: parent
        color: "#070b16"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        Label {
            text: qsTr("Single Player Setup")
            font.pixelSize: 36
            font.bold: true
            color: "#f0f6fc"
            Layout.fillWidth: true
        }

        Label {
            text: selectionHeading()
            color: "#9ca3af"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ScrollView {
            id: selectionScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                id: selectionColumn
                width: selectionScroll.availableWidth
                spacing: 12

                Repeater {
                    id: powerupRepeater
                    model: selectedPowerups ? selectedPowerups.length : 0

                    delegate: powerupSummaryDelegate
                }

                Label {
                    visible: powerupRepeater.count === 0
                    text: qsTr("Select at least one powerup to begin your solo campaign.")
                    color: "#6b7280"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: qsTr("Back to Main Menu")
                Layout.preferredWidth: 200
                onClicked: root.exitToMenuRequested()
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Start Match")
                enabled: selectedPowerups && selectedPowerups.length > 0
                Layout.preferredWidth: 180
                onClicked: root.startMatch()
            }
        }
    }

    Component {
        id: powerupSummaryDelegate

        Rectangle {
            id: summaryCard
            property var powerup: (root.selectedPowerups && index >= 0 && index < root.selectedPowerups.length)
                                  ? root.selectedPowerups[index]
                                  : ({})

            color: "#111827"
            border.color: "#1f2937"
            border.width: 1
            radius: 10
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6

                Label {
                    text: powerup.name || qsTr("Unnamed Powerup")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#f0f6fc"
                    Layout.fillWidth: true
                }

                Label {
                    text: powerup.description || qsTr("Configure this powerup in the editor to see its full description.")
                    wrapMode: Text.WordWrap
                    color: "#9ca3af"
                    Layout.fillWidth: true
                }
            }
        }
    }
}
