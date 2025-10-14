import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var stackView
    property var editorStore
    property var mainPage

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0b1120"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Choose Powerup")
                font.pixelSize: 32
                font.bold: true
                color: "#f8fafc"
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }
            Item { Layout.fillWidth: true }
            Button {
                text: qsTr("Back")
                onClicked: stackView.pop()
            }
        }

        ListView {
            id: powerupList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16
            clip: true
            model: editorStore ? editorStore.createdPowerupsModel : null
            delegate: Item {
                width: powerupList.width
                height: 120

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "#111827"
                    border.color: "#1e293b"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        PowerupGridBlock {
                            Layout.preferredWidth: 72
                            Layout.preferredHeight: 72
                            selected: true
                            highlightColor: colorHex || "#38bdf8"
                            idleColor: "#1f2937"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Label {
                                text: (typeLabel || "") + qsTr(" → ") + (targetLabel || "")
                                font.pixelSize: 18
                                font.bold: true
                                color: "#e2e8f0"
                            }
                            Label {
                                text: qsTr("Color: %1").arg(colorLabel || "-")
                                font.pixelSize: 14
                                color: "#cbd5f5"
                            }
                            Label {
                                text: qsTr("HP Adjustment: %1").arg(hp || 0)
                                font.pixelSize: 14
                                color: "#94a3b8"
                            }
                            Label {
                                visible: targetKey === "blocks"
                                text: qsTr("Blocks Selected: %1").arg(blockCount || 0)
                                font.pixelSize: 13
                                color: "#64748b"
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                            radius: 10
                            color: "#1e293b"
                            border.color: "#334155"
                            border.width: 1
                            Column {
                                anchors.centerIn: parent
                                spacing: 6
                                Label {
                                    text: qsTr("Energy")
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#f8fafc"
                                }
                                Label {
                                    text: formatEnergy(energy)
                                    font.pixelSize: 22
                                    font.bold: true
                                    color: "#38bdf8"
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.beginEdit(powerupId)
                }
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No saved powerups yet.")
                color: "#64748b"
                visible: !editorStore || editorStore.createdPowerupsModel.count === 0
            }
        }
    }

    function beginEdit(powerupId) {
        if (!editorStore)
            return
        var data = editorStore.getPowerupById(powerupId)
        if (!data)
            return
        stackView.push(editWizardComponent, {
                           stackView: stackView,
                           editorStore: editorStore,
                           mainPage: mainPage,
                           editMode: true,
                           existingId: powerupId,
                           existingData: data
                       })
    }

    function formatEnergy(value) {
        if (value === undefined || value === null)
            return "0"
        var rounded = Math.round(value * 10) / 10
        return (Math.abs(rounded - Math.round(rounded)) < 0.0001) ? String(Math.round(rounded)) : rounded.toFixed(1)
    }

    Component {
        id: editWizardComponent
        CreatePowerupPage {}
    }
}
