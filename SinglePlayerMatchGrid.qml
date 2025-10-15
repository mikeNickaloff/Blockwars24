import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int rows: 6
    property int columns: 6
    property real baseCellSize: 56
    property real minCellSize: 32
    property real cellSpacing: 8
    property color cellColor: "#1f2937"
    property color cellHighlight: "#334155"

    readonly property real computedCellSize: {
        const availableWidth = Math.max(0, width - ((columns + 1) * cellSpacing))
        const availableHeight = Math.max(0, height - ((rows + 1) * cellSpacing))
        const sizeFromWidth = columns > 0 ? availableWidth / columns : baseCellSize
        const sizeFromHeight = rows > 0 ? availableHeight / rows : baseCellSize
        const candidate = Math.min(baseCellSize, sizeFromWidth, sizeFromHeight)
        return Math.max(minCellSize, candidate)
    }

    implicitWidth: (columns * baseCellSize) + ((columns + 1) * cellSpacing)
    implicitHeight: (rows * baseCellSize) + ((rows + 1) * cellSpacing)

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#070d1b"
        border.color: "#1f2937"
        border.width: 1

        Grid {
            id: blockGrid
            anchors.fill: parent
            anchors.margins: cellSpacing
            columns: root.columns
            columnSpacing: cellSpacing
            rowSpacing: cellSpacing
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            Repeater {
                model: root.rows * root.columns
                delegate: Rectangle {
                    width: root.computedCellSize
                    height: root.computedCellSize
                    radius: 10
                    color: root.cellColor
                    border.color: "#0f172a"
                    border.width: 1

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 6
                        color: root.cellHighlight
                        opacity: 0.18
                    }
                }
            }
        }
    }
}
