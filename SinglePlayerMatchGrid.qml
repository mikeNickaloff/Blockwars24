import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int rows: 6
    property int columns: 6
    property real cellSize: 56
    property real cellSpacing: 8
    property color cellColor: "#1f2937"
    property color cellHighlight: "#334155"

    implicitWidth: (columns * cellSize) + ((columns + 1) * cellSpacing)
    implicitHeight: (rows * cellSize) + ((rows + 1) * cellSpacing)

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
                    width: root.cellSize
                    height: root.cellSize
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
