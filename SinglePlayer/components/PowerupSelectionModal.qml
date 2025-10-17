import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Shared"

Popup {
    id: modal

    property int slotIndex: -1
    property var currentSelection: null
    property PowerupRepository playerRepository

    signal selectionMade(int slotIndex, var payload)

    modal: true
    focus: true
    width: Math.min(720, parent ? parent.width * 0.8 : 720)
    height: Math.min(520, parent ? parent.height * 0.8 : 520)
    background: Rectangle {
        radius: 16
        color: "#0f172a"
        border.color: "#1e293b"
        border.width: 1
    }

    DefaultPowerupRepository {
        id: defaultRepository
    }

    ListModel {
        id: optionModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: qsTr("Choose Powerup")
                font.pixelSize: 26
                font.bold: true
                color: "#f8fafc"
            }

            Item { Layout.fillWidth: true }

            ToolButton {
                text: "✕"
                onClicked: modal.close()
            }
        }

        ListView {
            id: optionList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: optionModel

            delegate: ItemDelegate {
                width: optionList.width
                padding: 16
                checked: model.selected
                checkable: true
                onClicked: modal._select(model.payload)

                background: Rectangle {
                    radius: 12
                    color: checked ? "#1d4ed8" : (hovered ? "#14213b" : "#101827")
                    border.color: checked ? "#60a5fa" : "#1e293b"
                    border.width: 1
                }

                contentItem: RowLayout {
                    spacing: 16
                    Rectangle {
                        width: 48
                        height: 48
                        radius: 8
                        color: model.payload.colorHex
                        border.color: "#1e293b"
                        border.width: 1
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            text: model.title
                            color: "#f8fafc"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        Label {
                            text: model.subtitle
                            color: "#cbd5f5"
                            font.pixelSize: 12
                        }
                        Label {
                            text: model.source
                            color: "#64748b"
                            font.pixelSize: 11
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
                            text: String(model.payload.energy)
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
                visible: optionModel.count === 0
                text: qsTr("No powerups available.")
                color: "#64748b"
            }
        }
    }

    function openForSlot(index, selection) {
        slotIndex = index
        currentSelection = selection || null
        _populateOptions()
        open()
    }

    function _populateOptions() {
        optionModel.clear()
        const selectedKey = currentSelection && currentSelection.typeKey ? _fingerprint(currentSelection) : ""
        if (playerRepository && playerRepository.entries) {
            const created = playerRepository.entries
            for (let i = 0; i < created.length; ++i) {
                const entry = created[i]
                optionModel.append({
                                        payload: entry,
                                        title: entry.typeLabel + qsTr(" vs ") + entry.targetLabel,
                                        subtitle: qsTr("Color: %1 — HP: %2").arg(entry.colorLabel).arg(entry.hp),
                                        source: qsTr("Created"),
                                        selected: selectedKey !== "" && _fingerprint(entry) === selectedKey
                                    })
            }
        }

        const defaults = defaultRepository.allPowerups()
        for (let j = 0; j < defaults.length; ++j) {
            const entry = defaults[j]
            optionModel.append({
                                    payload: entry,
                                    title: entry.typeLabel + qsTr(" vs ") + entry.targetLabel,
                                    subtitle: qsTr("Color: %1 — HP: %2").arg(entry.colorLabel).arg(entry.hp),
                                    source: qsTr("Default"),
                                    selected: selectedKey !== "" && _fingerprint(entry) === selectedKey
                                })
        }
    }

    function _fingerprint(entry) {
        if (!entry)
            return ""
        return [entry.typeKey, entry.targetKey, entry.colorKey, entry.hp, entry.blockCount].join(":")
    }

    function _select(entry) {
        if (!entry)
            return
        selectionMade(slotIndex, entry)
        close()
    }
}
