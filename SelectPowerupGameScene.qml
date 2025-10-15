import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24

GameScene {
    id: root
    implicitWidth: 1024
    implicitHeight: 768

    property var stackView
    property int selectionLimit: 3
    property var selectedPowerupIds: []
    property var powerupOptions: [
        ({ id: "blazing_comet", name: qsTr("Blazing Comet"), description: qsTr("Launches a fiery barrage that scorches enemy blocks along a row.") }),
        ({ id: "starlight_barrier", name: qsTr("Starlight Barrier"), description: qsTr("Fortifies allied blocks with a temporary shield of radiant light.") }),
        ({ id: "tidal_surge", name: qsTr("Tidal Surge"), description: qsTr("Sweeps the lowest column, washing away weakened enemy defenses.") }),
        ({ id: "aurora_burst", name: qsTr("Aurora Burst"), description: qsTr("Charges a column with prismatic energy that heals friendly powerups.") })
    ]

    signal backRequested()
    signal selectionComplete(var selectedPowerups)

    readonly property bool selectionAvailable: selectedPowerupIds.length > 0

    function isSelected(powerupId) {
        return selectedPowerupIds.indexOf(powerupId) !== -1
    }

    function assignSelection(newSelection) {
        selectedPowerupIds = newSelection
    }

    function toggleSelection(powerupId) {
        if (!powerupId)
            return

        const selection = selectedPowerupIds.slice()
        const index = selection.indexOf(powerupId)
        if (index !== -1) {
            selection.splice(index, 1)
            assignSelection(selection)
            return
        }

        if (selectionLimit > 0 && selection.length >= selectionLimit)
            return

        selection.push(powerupId)
        assignSelection(selection)
    }

    function selectedPowerupDetails() {
        return powerupOptions.filter(function(option) { return isSelected(option.id) })
    }

    function selectionSummaryText() {
        if (selectionLimit <= 0) {
            if (!selectionAvailable)
                return qsTr("Choose any powerups to prepare your battle loadout.")
            return qsTr("%1 powerups selected.").arg(selectedPowerupIds.length)
        }

        if (!selectionAvailable)
            return qsTr("Choose up to %1 powerups to prepare your battle loadout.").arg(selectionLimit)
        return qsTr("%1 of %2 powerups selected.").arg(selectedPowerupIds.length).arg(selectionLimit)
    }

    function finalizeSelection() {
        selectionComplete(selectedPowerupDetails())
    }

    Rectangle {
        anchors.fill: parent
        color: "#0b1120"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        Label {
            text: qsTr("Select Powerups")
            font.pixelSize: 34
            font.bold: true
            color: "#f0f6fc"
            Layout.fillWidth: true
        }

        Label {
            text: selectionSummaryText()
            wrapMode: Text.WordWrap
            color: "#9ca3af"
            Layout.fillWidth: true
        }

        ScrollView {
            id: optionScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                id: optionColumn
                width: optionScroll.availableWidth
                spacing: 12

                Repeater {
                    model: root.powerupOptions

                    delegate: powerupOptionDelegate
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: qsTr("Back")
                Layout.preferredWidth: 140
                onClicked: root.backRequested()
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: qsTr("Confirm")
                enabled: selectionAvailable
                Layout.preferredWidth: 180
                onClicked: root.finalizeSelection()
            }
        }
    }

    Component {
        id: powerupOptionDelegate

        Rectangle {
            id: card
            property var option: modelData || ({})
            property bool selected: root.isSelected(option.id)

            color: selected ? "#1f2937" : "#111827"
            border.color: selected ? "#38bdf8" : "#1f2937"
            border.width: 1
            radius: 10
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: option.name
                        font.pixelSize: 20
                        font.bold: true
                        color: "#f0f6fc"
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 6
                        border.width: 2
                        border.color: card.selected ? "#38bdf8" : "#374151"
                        color: card.selected ? "#38bdf8" : "transparent"
                    }
                }

                Label {
                    text: option.description
                    wrapMode: Text.WordWrap
                    color: "#9ca3af"
                    Layout.fillWidth: true
                }
            }

            TapHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: root.toggleSelection(card.option.id)
            }
        }
    }
}
