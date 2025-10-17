import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root

    property var stackView
    property var powerupRepository
    property var powerupSelectionComponent
    property int powerupSlotCount: 4
    property var selectedPowerups: []
    property bool battleActive: false
    property var cpuBattleLoadout: []

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#020617"
    }

    DefaultPowerupRepository {
        id: defaultRepository
    }

    Component.onCompleted: {
        root._syncPlayerSelection()
        root._refreshCpuLoadout()
    }

    onSelectedPowerupsChanged: root._syncPlayerSelection()
    onPowerupSlotCountChanged: root._refreshCpuLoadout()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Back")
                onClicked: root._navigateBack()
            }

            Label {
                text: qsTr("Single Player Loadout")
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: 28
                font.bold: true
                color: "#f8fafc"
            }

            Button {
                text: qsTr("Choose Powerups")
                onClicked: root._openSelection()
            }
        }

        Label {
            text: qsTr("Review the powerups assigned to this match before jumping into gameplay.")
            wrapMode: Text.WordWrap
            color: "#94a3b8"
            Layout.fillWidth: true
        }

        ListView {
            id: selectedList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            model: root.selectedPowerups || []

            delegate: Rectangle {
                width: selectedList.width
                height: 88
                radius: 12
                color: "#111827"
                border.color: "#1e293b"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
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
                            font.pixelSize: 18
                            font.bold: true
                            wrapMode: Text.WordWrap
                        }

                        Label {
                            text: root._resolveSubtitle(modelData)
                            color: "#94a3b8"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }

                        Label {
                            visible: Boolean(modelData && modelData.targetKey === "blocks")
                            text: qsTr("Blocks targeted: %1").arg(modelData && modelData.blockCount ? modelData.blockCount : 0)
                            color: "#64748b"
                            font.pixelSize: 12
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Label {
                            text: qsTr("Energy")
                            font.pixelSize: 12
                            color: "#f8fafc"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: root._formatEnergy(modelData && modelData.energy)
                            font.pixelSize: 20
                            font.bold: true
                            color: "#38bdf8"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No powerups selected yet.")
                color: "#64748b"
                visible: !model || model.length === 0
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: 16
            color: "#0f172a"
            border.color: "#1e293b"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Label {
                    text: qsTr("Match Status")
                    font.pixelSize: 20
                    font.bold: true
                    color: "#f8fafc"
                }

                Label {
                    text: qsTr("Review your loadout and begin the battle when ready. The confrontation will load both dashboards and synchronize powerups automatically.")
                    wrapMode: Text.WordWrap
                    color: "#94a3b8"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Item { Layout.fillWidth: true }

                    Button {
                        text: qsTr("Begin Battle")
                        enabled: (selectedPowerups && selectedPowerups.length > 0)
                        onClicked: root._beginBattle()
                    }
                }
            }
        }
    }

    Loader {
        id: matchLoader
        anchors.fill: parent
        active: root.battleActive
        visible: active
        sourceComponent: matchComponent
        onStatusChanged: {
            if (status === Loader.Ready && item) {
                item.playerLoadout = root._normalizedSelection()
                item.cpuLoadout = root.cpuBattleLoadout
            }
        }
    }

    Component {
        id: matchComponent
        SinglePlayerMatchScene {
            playerLoadout: root._normalizedSelection()
            cpuLoadout: root.cpuBattleLoadout
            onExitRequested: root._endBattle()
        }
    }

    function _navigateBack() {
        if (stackView)
            stackView.pop()
    }

    function _openSelection() {
        if (!stackView || !powerupSelectionComponent)
            return
        stackView.push(powerupSelectionComponent, {
                              stackView: stackView,
                              powerupRepository: powerupRepository,
                              slotCount: powerupSlotCount
                          })
    }

    function _beginBattle() {
        if (battleActive)
            return
        battleActive = true
        if (matchLoader.item) {
            matchLoader.item.playerLoadout = root._normalizedSelection()
            matchLoader.item.cpuLoadout = root.cpuBattleLoadout
        }
    }

    function _endBattle() {
        if (!battleActive)
            return
        battleActive = false
    }

    function _resolveTitle(entry) {
        if (!entry)
            return qsTr("Unknown")
        const type = entry.typeLabel || qsTr("Unknown")
        const target = entry.targetLabel || qsTr("Target")
        return type + qsTr(" vs ") + target
    }

    function _resolveSubtitle(entry) {
        if (!entry)
            return qsTr("No details")
        const color = entry.colorLabel || qsTr("No Color")
        const hp = entry.hp !== undefined ? entry.hp : 0
        return qsTr("Color: %1 — HP: %2").arg(color).arg(hp)
    }

    function _formatEnergy(value) {
        if (value === undefined || value === null)
            return "0"
        const number = Number(value)
        if (isNaN(number))
            return "0"
        const rounded = Math.round(number * 10) / 10
        return Math.abs(rounded - Math.round(rounded)) < 0.0001 ? String(Math.round(rounded)) : rounded.toFixed(1)
    }

    function _normalizedSelection() {
        return root._normalizedEntries(selectedPowerups)
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
                                blocks: root._sanitizeBlocks(entry.blocks)
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

    function _syncPlayerSelection() {
        if (battleActive && matchLoader.item)
            matchLoader.item.playerLoadout = root._normalizedSelection()
    }

    function _refreshCpuLoadout() {
        const defaults = defaultRepository ? defaultRepository.allPowerups() : []
        const loadout = []
        for (let i = 0; i < Math.min(powerupSlotCount, defaults.length); ++i)
            loadout.push(defaults[i])
        cpuBattleLoadout = root._normalizedEntries(loadout)
        if (battleActive && matchLoader.item)
            matchLoader.item.cpuLoadout = cpuBattleLoadout
    }
}
