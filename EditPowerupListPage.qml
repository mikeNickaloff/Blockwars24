import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root

    property var stackView
    property var editorStore
    property var mainPage

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0f172a"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        Label {
            text: qsTr("Edit Powerup")
            font.pixelSize: 32
            font.bold: true
            color: "#e2e8f0"
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Back")
                onClicked: root._goBack()
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Create New")
                onClicked: root._createNewPowerup()
            }
        }

        ListView {
            id: powerupList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12
            model: editorStore ? editorStore.createdPowerupsModel : null

            delegate: ItemDelegate {
                width: powerupList.width
                padding: 16
                background: Rectangle {
                    radius: 12
                    color: hovered ? "#152236" : "#101827"
                    border.color: "#1e293b"
                    border.width: 1
                }
                onClicked: root._openTraitsEditor(modelData ? modelData.id : -1, modelData)

                contentItem: ColumnLayout {
                    width: parent.width
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 8
                            color: modelData && modelData.colorHex ? modelData.colorHex : "#334155"
                            border.color: "#1e293b"
                            border.width: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Label {
                                text: root._resolveTitle(modelData)
                                color: "#e2e8f0"
                                font.pixelSize: 16
                                font.bold: true
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                            Label {
                                text: root._resolveSubtitle(modelData)
                                color: "#94a3b8"
                                font.pixelSize: 13
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                            Label {
                                visible: modelData && modelData.targetKey === "blocks"
                                text: qsTr("Blocks selected: %1").arg(modelData && modelData.blockCount ? modelData.blockCount : 0)
                                color: "#64748b"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Label {
                                text: qsTr("Energy")
                                font.pixelSize: 12
                                color: "#f8fafc"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: root._formatEnergy(modelData && modelData.energy)
                                font.pixelSize: 18
                                font.bold: true
                                color: "#38bdf8"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    RowLayout {
                        spacing: 12

                        Button {
                            text: qsTr("Edit Traits")
                            onClicked: root._openTraitsEditor(modelData ? modelData.id : -1, modelData)
                        }

                        Button {
                            text: qsTr("Adjust Power")
                            onClicked: root._openPowerAdjust(modelData ? modelData.id : -1, modelData)
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No powerups available.")
                color: "#94a3b8"
                visible: !editorStore || editorStore.createdPowerupsModel.count === 0
            }
        }
    }

    Component {
        id: adjustComponent
        AdjustPowerValuePage {
            editMode: true
        }
    }

    Component {
        id: editTraitsComponent
        CreatePowerupPage {
            editMode: true
        }
    }

    function _goBack() {
        if (!stackView)
            return
        if (mainPage)
            stackView.pop(mainPage)
        else
            stackView.pop()
    }

    function _createNewPowerup() {
        if (!stackView || !editorStore)
            return
        stackView.push(editTraitsComponent, {
                          stackView: stackView,
                          editorStore: editorStore,
                          mainPage: mainPage || root,
                          editMode: false,
                          existingId: -1,
                          existingData: ({})
                      })
    }

    function _openTraitsEditor(identifier, payload) {
        if (!stackView || !editorStore || identifier < 0)
            return
        stackView.push(editTraitsComponent, {
                          stackView: stackView,
                          editorStore: editorStore,
                          mainPage: mainPage || root,
                          editMode: true,
                          existingId: identifier,
                          existingData: _clonePayload(payload)
                      })
    }

    function _openPowerAdjust(identifier, payload) {
        if (!stackView || !editorStore || identifier < 0)
            return
        stackView.push(adjustComponent, {
                          stackView: stackView,
                          editorStore: editorStore,
                          mainPage: mainPage || root,
                          editMode: true,
                          existingId: identifier,
                          configuration: _clonePayload(payload),
                          initialHp: payload && payload.hp ? payload.hp : 0
                      })
    }

    function _clonePayload(payload) {
        const copy = Object.assign({}, payload || {})
        if (payload && payload.blocks && payload.blocks.length) {
            const blocks = []
            for (let i = 0; i < payload.blocks.length; ++i) {
                const cell = payload.blocks[i]
                if (!cell)
                    continue
                blocks.push({ row: Number(cell.row), column: Number(cell.column) })
            }
            copy.blocks = blocks
            copy.blockCount = blocks.length
        } else {
            copy.blocks = []
            copy.blockCount = 0
        }
        return copy
    }

    function _resolveTitle(payload) {
        const type = payload && payload.typeLabel ? payload.typeLabel : qsTr("Unknown")
        const target = payload && payload.targetLabel ? payload.targetLabel : qsTr("Target")
        return type + qsTr(" vs ") + target
    }

    function _resolveSubtitle(payload) {
        const color = payload && payload.colorLabel ? payload.colorLabel : qsTr("No Color")
        const hp = payload && payload.hp !== undefined ? payload.hp : 0
        return qsTr("Color: %1 — HP: %2").arg(color).arg(hp)
    }

    function _formatEnergy(value) {
        if (value === undefined || value === null)
            return "0"
        const rounded = Math.round(Number(value) * 10) / 10
        return Math.abs(rounded - Math.round(rounded)) < 0.0001 ? String(Math.round(rounded)) : rounded.toFixed(1)
    }
}
