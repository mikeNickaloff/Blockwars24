import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "."

GameScene {
    id: gridRoot

    property int rows: 6
    property int columns: 6
    property var blockPool
    property var powerupDataStore
    property string gridState: "idle"

    readonly property alias blockModel: blockModel

    property var _blockRegistry: ({})
    property bool _boardInitialized: false
    property int _localPoolIndex: -1

    ListModel {
        id: blockModel
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#070d1b"
        border.color: "#1f2937"
        border.width: 1

        SinglePlayerMatchGrid {
            id: matchGrid
            anchors.fill: parent
            rows: gridRoot.rows
            columns: gridRoot.columns
        }

        Repeater {
            model: blockModel
            delegate: Rectangle {
                required property int row
                required property int column
                required property string colorHex
                required property int hp
                required property bool highlighted

                width: matchGrid.computedCellSize
                height: matchGrid.computedCellSize
                radius: 10
                color: colorHex
                x: matchGrid.cellSpacing + column * (matchGrid.computedCellSize + matchGrid.cellSpacing)
                y: matchGrid.cellSpacing + row * (matchGrid.computedCellSize + matchGrid.cellSpacing)
                border.color: highlighted ? "#fbbf24" : "#0f172a"
                border.width: highlighted ? 2 : 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 2
                    Label {
                        text: hp
                        font.pixelSize: 12
                        color: "#f8fafc"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Label {
                        text: gridRoot.gridState
                        font.pixelSize: 8
                        color: "#e2e8f0"
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.45
                    }
                }
            }
        }

        Rectangle {
            id: stateBadge
            width: 120
            height: 28
            radius: 14
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            color: "#1e293b"
            border.color: "#334155"
            border.width: 1

            Label {
                anchors.centerIn: parent
                text: gridRoot.gridState.toUpperCase()
                font.pixelSize: 12
                color: "#38bdf8"
            }
        }
    }

    states: [
        State { name: "idle" },
        State {
            name: "fill"
            PropertyChanges { target: stateBadge; color: "#2563eb" }
        },
        State {
            name: "compact"
            PropertyChanges { target: stateBadge; color: "#22d3ee" }
        },
        State {
            name: "match"
            PropertyChanges { target: stateBadge; color: "#f97316" }
        },
        State {
            name: "launch"
            PropertyChanges { target: stateBadge; color: "#f43f5e" }
        },
        State {
            name: "waiting"
            PropertyChanges { target: stateBadge; color: "#475569" }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            ColorAnimation { target: stateBadge; property: "color"; duration: 220 }
        }
    ]

    Component.onCompleted: initializeBoard()
    onBlockPoolChanged: initializeBoard()

    function initializeBoard() {
        if (!blockPool)
            return
        blockModel.clear()
        _blockRegistry = {}
        for (let row = 0; row < rows; ++row) {
            for (let column = 0; column < columns; ++column)
                gridRoot.addBlock(row, column)
        }
        _boardInitialized = true
    }

    function addBlock(row, column) {
        const normalizedRow = gridRoot._normalizeRow(row)
        const normalizedColumn = gridRoot._normalizeColumn(column)
        if (normalizedRow < 0 || normalizedColumn < 0)
            return null
        const color = blockPool && blockPool.getNextColor ? blockPool.getNextColor() : "#475569"
        const payload = {
            row: normalizedRow,
            column: normalizedColumn,
            colorHex: color,
            hp: 10,
            highlighted: false
        }
        gridRoot._blockRegistry[gridRoot._cellKey(normalizedRow, normalizedColumn)] = payload
        gridRoot._writeModelEntry(payload)
        return payload
    }

    function setGridState(newState) {
        if (!newState || gridRoot.gridState === newState)
            return
        gridRoot.gridState = newState
        state = newState
    }

    function generateBlockData() {
        const snapshot = []
        for (let row = 0; row < rows; ++row) {
            const rowData = []
            for (let column = 0; column < columns; ++column) {
                const key = gridRoot._cellKey(row, column)
                const entry = gridRoot._blockRegistry[key]
                if (!entry) {
                    rowData.push(null)
                    continue
                }
                rowData.push({
                                color: entry.colorHex,
                                hp: entry.hp,
                                isPowerup: false,
                                powerupUuid: "",
                                blockState: gridRoot.gridState,
                                row: entry.row,
                                column: entry.column
                            })
            }
            snapshot.push(rowData)
        }
        return snapshot
    }

    function applyPowerupHighlights(powerups) {
        const highlightRegistry = {}
        const list = Array.isArray(powerups) ? powerups : []
        for (let i = 0; i < list.length; ++i) {
            const powerup = list[i]
            if (!powerup || !Array.isArray(powerup.blocks))
                continue
            for (let j = 0; j < powerup.blocks.length; ++j) {
                const cell = powerup.blocks[j]
                const row = gridRoot._normalizeRow(cell.row)
                const column = gridRoot._normalizeColumn(cell.column)
                if (row < 0 || column < 0)
                    continue
                highlightRegistry[gridRoot._cellKey(row, column)] = true
            }
        }

        for (let index = 0; index < blockModel.count; ++index) {
            const entry = blockModel.get(index)
            if (!entry)
                continue
            const key = gridRoot._cellKey(entry.row, entry.column)
            const updated = Object.assign({}, entry, { highlighted: Boolean(highlightRegistry[key]) })
            blockModel.set(index, updated)
            gridRoot._blockRegistry[key] = updated
        }
    }

    function _writeModelEntry(payload) {
        const index = gridRoot._modelIndex(payload.row, payload.column)
        if (index >= 0)
            blockModel.set(index, payload)
        else
            blockModel.append(payload)
    }

    function _modelIndex(row, column) {
        for (let i = 0; i < blockModel.count; ++i) {
            const entry = blockModel.get(i)
            if (entry && entry.row === row && entry.column === column)
                return i
        }
        return -1
    }

    function _normalizeRow(value) {
        const number = Math.floor(Number(value))
        if (isNaN(number))
            return -1
        return Math.max(0, Math.min(rows - 1, number))
    }

    function _normalizeColumn(value) {
        const number = Math.floor(Number(value))
        if (isNaN(number))
            return -1
        return Math.max(0, Math.min(columns - 1, number))
    }

    function _cellKey(row, column) {
        return row + ":" + column
    }
}
