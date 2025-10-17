import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Shared"

Item {
    id: root

    required property Item flow
    required property StackView stackView
    required property var draft

    property var selectedCells: _normalizeCells(draft.blocks)
    property int selectedCount: selectedCells.length
    property int hpValue: Math.max(1, Math.round(draft.hp || 10))

    readonly property string primaryColor: draft.colorHex || "#ef4444"

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#111827"
        border.color: "#1e293b"
        border.width: 1
    }

    PowerupEnergyModel {
        id: energyModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Back")
                onClicked: stackView.pop()
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Label {
                    text: qsTr("Select Blocks")
                    font.pixelSize: 30
                    font.bold: true
                    color: "#f8fafc"
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: qsTr("Tap blocks to toggle them. Selected blocks glow in the chosen color.")
                    color: "#94a3b8"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            Item { Layout.preferredWidth: 32 }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(root.height * 0.45, 360)

            GridLayout {
                id: blockGrid
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) * 0.8
                height: width
                rows: 6
                columns: 6
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: 36
                    delegate: Rectangle {
                        required property int index
                        readonly property int row: Math.floor(index / 6)
                        readonly property int column: index % 6
                        width: Math.max(0, Math.min(blockGrid.width, blockGrid.height) / 6 - blockGrid.columnSpacing)
                        height: width
                        radius: 10
                        color: root._isSelected(row, column) ? primaryColor : "#1f2937"
                        border.color: root._isSelected(row, column) ? "#f8fafc" : "#0f172a"
                        border.width: 1

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 8
                            color: Qt.rgba(0, 0, 0, 0.15)
                            visible: !root._isSelected(row, column)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root._toggleCell(row, column)
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 24

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Label {
                    text: qsTr("HP Adjustment: %1").arg(hpValue)
                    color: "#f8fafc"
                    font.pixelSize: 16
                }

                Slider {
                    id: hpSlider
                    from: 1
                    to: 20
                    stepSize: 1
                    value: hpValue
                    onMoved: root.hpValue = Math.round(value)
                    onValueChanged: {
                        const rounded = Math.round(value)
                        if (rounded !== root.hpValue)
                            root.hpValue = rounded
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: Math.min(root.width * 0.2, 180)
                spacing: 6
                Label {
                    text: qsTr("Blocks Selected")
                    color: "#f8fafc"
                    font.pixelSize: 12
                }
                Label {
                    text: String(selectedCount)
                    font.pixelSize: 28
                    font.bold: true
                    color: "#38bdf8"
                }
                Label {
                    text: qsTr("Estimated Energy")
                    color: "#f8fafc"
                    font.pixelSize: 12
                }
                Label {
                    text: String(root._energyEstimate())
                    font.pixelSize: 24
                    font.bold: true
                    color: "#38bdf8"
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Finish")
                enabled: root._canFinish()
                padding: 16
                font.pixelSize: 18
                onClicked: root._finish()
            }
        }
    }

    function _toggleCell(row, column) {
        const key = row + ":" + column
        const map = {}
        const updated = []
        for (let i = 0; i < selectedCells.length; ++i) {
            const cell = selectedCells[i]
            const cellKey = cell.row + ":" + cell.column
            if (cellKey === key)
                continue
            map[cellKey] = true
            updated.push(cell)
        }

        if (!map[key])
            updated.push({ row: row, column: column })

        selectedCells = updated
        selectedCount = updated.length
    }

    function _isSelected(row, column) {
        for (let i = 0; i < selectedCells.length; ++i) {
            const cell = selectedCells[i]
            if (cell.row === row && cell.column === column)
                return true
        }
        return false
    }

    function _normalizeCells(cells) {
        const source = Array.isArray(cells) ? cells : []
        const normalized = []
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
            normalized.push({ row: row, column: column })
        }
        return normalized
    }

    function _energyEstimate() {
        return energyModel.estimateEnergy({
                    hp: hpValue,
                    blockCount: Math.max(1, selectedCount),
                    typeKey: draft.typeKey,
                    targetKey: draft.targetKey
                })
    }

    function _canFinish() {
        if (draft.targetKey === "blocks")
            return selectedCount > 0
        return true
    }

    function _finish() {
        const payload = {
            typeKey: draft.typeKey,
            typeLabel: draft.typeLabel,
            targetKey: draft.targetKey,
            targetLabel: draft.targetLabel,
            colorKey: draft.colorKey,
            colorLabel: draft.colorLabel,
            colorHex: draft.colorHex,
            hp: hpValue,
            blocks: selectedCells
        }
        flow.saveAndExit(payload)
    }
}
