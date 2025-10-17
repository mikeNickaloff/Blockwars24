import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var stackView
    property var powerupRepository
    objectName: "powerupEditorMainPage"

    readonly property var menuOptions: [
        {
            title: qsTr("Create New"),
            subtitle: qsTr("Design a brand-new powerup from scratch."),
            handler: function() {
                root.stackView.push(createPowerupComponent, {
                                        stackView: root.stackView,
                                        powerupRepository: root.powerupRepository,
                                        mainPage: root,
                                        editMode: false,
                                        existingId: -1,
                                        existingData: ({})
                                    })
            }
        },
        {
            title: qsTr("Edit Existing"),
            subtitle: qsTr("Tweak a powerup you have already saved."),
            handler: function() {
                root.stackView.push(editPowerupComponent, {
                                        stackView: root.stackView,
                                        powerupRepository: root.powerupRepository,
                                        mainPage: root
                                    })
            }
        },
        {
            title: qsTr("Back to Main Menu"),
            subtitle: qsTr("Return to the title screen."),
            handler: function() {
                root.stackView.pop()
            }
        }
    ]

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0b1120"
    }

    ScrollView {
        id: editorScrollView
        anchors.fill: parent
        anchors.margins: 32
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: editorContent
            width: editorScrollView.availableWidth
            spacing: 24

            Label {
                text: qsTr("Powerup Editor")
                font.pixelSize: 36
                font.bold: true
                color: "#f8fafc"
                Layout.fillWidth: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: menuOptions
                    delegate: AbstractButton {
                        id: optionButton
                        Layout.fillWidth: true
                        hoverEnabled: true
                        padding: 20
                        onClicked: modelData.handler()

                        background: Rectangle {
                            radius: 14
                            color: optionButton.pressed ? "#1f2937" : (optionButton.hovered ? "#14213b" : "#0f172a")
                            border.color: "#1e293b"
                            border.width: 1
                        }

                        contentItem: Column {
                            width: parent.width
                            spacing: 6
                            Label {
                                text: modelData.title
                                font.pixelSize: 22
                                font.bold: true
                                color: "#f8fafc"
                                wrapMode: Text.WordWrap
                            }
                            Label {
                                text: modelData.subtitle
                                font.pixelSize: 14
                                color: "#cbd5f5"
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("Recently Created")
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(240, Math.min(480, createdList.contentHeight + 48))

                ListView {
                    id: createdList
                    anchors.fill: parent
                    clip: true
                    spacing: 12
                    model: powerupRepository ? powerupRepository.createdPowerupsModel : null
                    delegate: ItemDelegate {
                        width: createdList.width
                        background: Rectangle {
                            radius: 12
                            color: hovered ? "#152236" : "#101827"
                            border.color: "#1e293b"
                            border.width: 1
                        }
                        padding: 16
                        contentItem: RowLayout {
                            width: parent.width
                            spacing: 16
                            Rectangle {
                                width: 56
                                height: 56
                                radius: 8
                                color: colorHex || "#334155"
                                border.color: "#1e293b"
                                border.width: 1
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    text: (typeLabel || "") + qsTr(" vs ") + (targetLabel || "")
                                    color: "#e2e8f0"
                                    font.pixelSize: 16
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: qsTr("Color: %1 — HP: %2").arg(colorLabel || "-").arg(hp || 0)
                                    color: "#94a3b8"
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                Label {
                                    visible: targetKey === "blocks"
                                    text: qsTr("Blocks Selected: %1").arg(blockCount || 0)
                                    color: "#64748b"
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 120
                                Layout.alignment: Qt.AlignVCenter
                                radius: 8
                                color: "#1e293b"
                                border.color: "#334155"
                                border.width: 1
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Label {
                                        text: qsTr("Energy")
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#f8fafc"
                                    }
                                    Label {
                                        text: formatEnergy(energy)
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#38bdf8"
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: qsTr("No powerups created yet.")
                        color: "#64748b"
                        visible: !powerupRepository || powerupRepository.createdPowerupsModel.count === 0
                    }
                }
            }
        }
    }

    function formatEnergy(value) {
        if (value === undefined || value === null)
            return "0"
        var rounded = Math.round(value * 10) / 10
        return (Math.abs(rounded - Math.round(rounded)) < 0.0001) ? String(Math.round(rounded)) : rounded.toFixed(1)
    }

    Component {
        id: createPowerupComponent
        CreatePowerupPage {}
    }

    Component {
        id: editPowerupComponent
        EditPowerupListPage {}
    }
}
