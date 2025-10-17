import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Shared"
import "./"

Item {
    id: root

    required property StackView stackView
    required property PowerupRepository repository

    implicitWidth: 1024
    implicitHeight: 768
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    Rectangle {
        anchors.fill: parent
        color: "#0b1120"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 28

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Back")
                onClicked: root._navigateBack()
            }

            Label {
                text: qsTr("Powerup Editor")
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: 34
                font.bold: true
                color: "#f8fafc"
            }

            Item { Layout.preferredWidth: 24 }
        }

        Label {
            text: qsTr("Choose what you would like to do.")
            color: "#94a3b8"
            font.pixelSize: 16
            Layout.fillWidth: true
        }

        ListView {
            id: optionList
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            spacing: 12
            model: ListModel {
                ListElement { title: qsTr("Create New"); subtitle: qsTr("Design a brand-new powerup from scratch."); action: "create" }
                ListElement { title: qsTr("Edit Existing"); subtitle: qsTr("Review or tweak saved powerups."); action: "library" }
                ListElement { title: qsTr("Back to Main Menu"); subtitle: qsTr("Return to the main menu."); action: "back" }
            }

            delegate: ItemDelegate {
                width: optionList.width
                padding: 18
                onClicked: root._handleAction(action)

                background: Rectangle {
                    radius: 14
                    color: hovered ? "#14213b" : "#0f172a"
                    border.color: "#1e293b"
                    border.width: 1
                }

                contentItem: Column {
                    spacing: 6
                    Label {
                        text: title
                        font.pixelSize: 22
                        font.bold: true
                        color: "#f8fafc"
                    }
                    Label {
                        text: subtitle
                        font.pixelSize: 13
                        color: "#cbd5f5"
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        GroupBox {
            title: qsTr("Recently Created")
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: libraryPreview
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                spacing: 8
                model: repository ? repository.model : null

                delegate: Rectangle {
                    width: libraryPreview.width
                    height: 72
                    radius: 12
                    color: "#101827"
                    border.color: "#1e293b"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14

                        Rectangle {
                            width: 48
                            height: 48
                            radius: 10
                            color: colorHex
                            border.color: "#1e293b"
                            border.width: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: typeLabel + qsTr(" vs ") + targetLabel
                                color: "#e2e8f0"
                                font.pixelSize: 16
                                font.bold: true
                            }
                            Label {
                                text: qsTr("HP: %1 | Blocks: %2").arg(hp).arg(blockCount)
                                color: "#94a3b8"
                                font.pixelSize: 12
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Label {
                                text: qsTr("Energy")
                                color: "#f8fafc"
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: String(energy)
                                color: "#38bdf8"
                                font.pixelSize: 18
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("No powerups saved yet.")
                    color: "#64748b"
                    visible: !libraryPreview.model || libraryPreview.model.count === 0
                }
            }
        }
    }

    Component {
        id: createFlowComponent
        CreatePowerupFlow {
            repository: root.repository
            mode: "create"
            onFinished: root._returnToMenu()
        }
    }

    Component {
        id: editFlowComponent
        CreatePowerupFlow {
            repository: root.repository
            mode: "edit"
            onFinished: root._completeEdit()
        }
    }

    Component {
        id: libraryComponent
        PowerupLibraryPage {
            repository: root.repository
            onFinished: root._returnToMenu()
            onEditRequested: function(entry) {
                root._openEditor(entry)
            }
        }
    }

    function _handleAction(action) {
        if (!stackView)
            return
        if (action === "create")
            stackView.push(createFlowComponent)
        else if (action === "library")
            stackView.push(libraryComponent)
        else
            _navigateBack()
    }

    function _navigateBack() {
        if (!stackView)
            return
        stackView.pop()
    }

    function _returnToMenu() {
        if (!stackView)
            return
        stackView.pop()
    }

    function _openEditor(entry) {
        if (!stackView)
            return
        const existingId = entry && entry.id !== undefined ? entry.id : -1
        const hydrated = existingId >= 0 && repository && repository.entryForId ? repository.entryForId(existingId) : entry
        stackView.push(editFlowComponent, {
                           existingEntry: hydrated
                       })
    }

    function _completeEdit() {
        if (repository && repository.reload)
            repository.reload()
        if (stackView)
            stackView.pop(root)
    }
}
