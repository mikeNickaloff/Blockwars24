import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property int rows: 6
    property int columns: 6
    property color cellBaseColor: "#0f172a"
    property color cellBorderColor: "#1e293b"
    property color selectedColor: "#38bdf8"
    property color selectedBorderColor: "#f8fafc"
    property bool showCoordinates: false
    property var selectedCells: []

    readonly property int cellCount: rows * columns

    signal selectionUpdate(var cells)

    implicitWidth: gridLayout.implicitWidth
    implicitHeight: gridLayout.implicitHeight

    GridLayout {
        id: gridLayout
        rows: root.rows
        columns: root.columns
        rowSpacing: 8
        columnSpacing: 8
        anchors.fill: parent

        Repeater {
            model: root.cellCount
            delegate: AbstractButton {
                id: cellButton
                property int cellRow: root._rowForIndex(index)
                property int cellColumn: root._columnForIndex(index)

                implicitWidth: 44
                implicitHeight: 44
                checkable: true
                checked: root._isCellSelected(cellRow, cellColumn)
                onClicked: root._toggleCell(cellRow, cellColumn)

                background: Rectangle {
                    radius: 8
                    border.width: 1
                    color: cellButton.checked ? root.selectedColor : root.cellBaseColor
                    border.color: cellButton.checked ? root.selectedBorderColor : root.cellBorderColor
                }

                contentItem: Text {
                    anchors.centerIn: parent
                    text: root.showCoordinates ? (qsTr("%1,%2").arg(cellButton.cellRow + 1).arg(cellButton.cellColumn + 1)) : ""
                    color: cellButton.checked ? "#02111d" : "#cbd5f5"
                    font.pixelSize: 12
                }
            }
        }
    }

    function clearSelection() {
        _commitSelection([], false)
    }

    function setSelectedCells(cells) {
        _commitSelection(cells, false)
    }

    function _toggleCell(row, column) {
        const key = _key(row, column)
        const existing = _selectionLookup[key]
        const updated = []
        if (!existing) {
            updated.push({ row: row, column: column })
            for (let i = 0; i < selectedCells.length; ++i)
                updated.push(_cloneCell(selectedCells[i]))
        } else {
            for (let i = 0; i < selectedCells.length; ++i) {
                const cell = selectedCells[i]
                if (cell && !(cell.row === row && cell.column === column))
                    updated.push(_cloneCell(cell))
            }
        }
        _commitSelection(updated, true)
    }

    function _rowForIndex(index) {
        return Math.floor(index / Math.max(1, root.columns))
    }

    function _columnForIndex(index) {
        return index % Math.max(1, root.columns)
    }

    function _commitSelection(cells, emitSignal) {
        const normalized = []
        const lookup = {}
        if (Array.isArray(cells)) {
            for (let i = 0; i < cells.length; ++i) {
                const cell = cells[i]
                const row = Math.max(0, Math.min(root.rows - 1, Number(cell.row)))
                const column = Math.max(0, Math.min(root.columns - 1, Number(cell.column)))
                const key = _key(row, column)
                if (lookup[key])
                    continue
                lookup[key] = true
                normalized.push({ row: row, column: column })
            }
        }
        const changed = !_areSelectionsEqual(selectedCells, normalized)
        _selectionLookup = lookup
        selectedCells = normalized
        if (emitSignal && changed)
            selectionUpdate(selectedCells)
        gridLayout.forceLayout()
    }

    function _areSelectionsEqual(a, b) {
        if (!a || !b)
            return a === b
        if (a.length !== b.length)
            return false
        const memo = {}
        for (let i = 0; i < a.length; ++i)
            memo[_key(a[i].row, a[i].column)] = true
        for (let j = 0; j < b.length; ++j) {
            if (!memo[_key(b[j].row, b[j].column)])
                return false
        }
        return true
    }

    function _isCellSelected(row, column) {
        return !!_selectionLookup[_key(row, column)]
    }

    function _cloneCell(cell) {
        if (!cell)
            return { row: 0, column: 0 }
        return { row: Number(cell.row), column: Number(cell.column) }
    }

    function _key(row, column) {
        return String(row) + ":" + String(column)
    }

    property var _selectionLookup: ({})
}
