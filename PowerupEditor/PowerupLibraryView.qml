import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Shared"

Item {
    id: root

    property PowerupRepository repository

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#111b2e"
        border.color: "#1e293b"
        border.width: 1
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10
        clip: true
        model: repository ? repository.model : null

        delegate: Rectangle {
            width: listView.width
            height: 96
            radius: 12
            color: "#101827"
            border.color: "#1e293b"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Rectangle {
                    width: 52
                    height: 52
                    radius: 10
                    color: colorHex
                    border.color: "#1e293b"
                    border.width: 1
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Label {
                        text: typeLabel + qsTr(" vs ") + targetLabel
                        color: "#e2e8f0"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Label {
                        text: qsTr("HP: %1 | Blocks: %2").arg(hp).arg(blockCount)
                        color: "#cbd5f5"
                        font.pixelSize: 13
                    }
                    Label {
                        visible: blocks.length > 0
                        text: qsTr("Cells: %1").arg(root._formatCells(blocks))
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
                        text: String(energy)
                        color: "#38bdf8"
                        font.pixelSize: 22
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
            visible: !model || model.count === 0
        }
    }

    function _formatCells(cells) {
        const parts = []
        for (let i = 0; i < Math.min(4, cells.length); ++i) {
            const cell = cells[i]
            parts.push("(" + cell.row + "," + cell.column + ")")
        }
        if (cells.length > 4)
            parts.push("…")
        return parts.join(" ")
    }
}
