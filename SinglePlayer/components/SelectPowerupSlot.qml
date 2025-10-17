import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: slot

    property int slotIndex: -1
    property var payload: ({})
    property bool filled: false

    signal requestSelection(int slotIndex)
    signal requestClear(int slotIndex)

    width: parent ? parent.width : 480
    height: 132

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: filled ? "#111827" : "#0b1225"
        border.color: "#1e293b"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 56
                height: 56
                radius: 10
                color: filled && payload && payload.colorHex ? payload.colorHex : "#334155"
                border.color: "#1e293b"
                border.width: 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: qsTr("Slot %1").arg(slotIndex + 1)
                    font.pixelSize: 16
                    font.bold: true
                    color: "#e2e8f0"
                }

                Label {
                    text: filled ? slot._resolveTitle(payload) : qsTr("Select a powerup to fill this slot.")
                    color: "#cbd5f5"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                }

                Label {
                    visible: filled
                    text: slot._resolveSubtitle(payload)
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                Label {
                    visible: filled && payload && payload.targetKey === "blocks"
                    text: qsTr("Blocks targeted: %1").arg(payload && payload.blockCount ? payload.blockCount : 0)
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
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: filled ? String(slot._formatEnergy(payload.energy)) : "--"
                    color: "#38bdf8"
                    font.pixelSize: 18
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: filled ? qsTr("Change") : qsTr("Select")
                onClicked: slot.requestSelection(slotIndex)
            }

            Button {
                text: qsTr("Clear")
                enabled: filled
                onClicked: slot.requestClear(slotIndex)
            }

            Item { Layout.fillWidth: true }
        }
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
            return ""
        const color = entry.colorLabel || qsTr("No Color")
        const hp = entry.hp !== undefined ? entry.hp : 0
        return qsTr("Color: %1 — HP: %2").arg(color).arg(hp)
    }

    function _formatEnergy(value) {
        const number = Number(value)
        if (isNaN(number))
            return 0
        const rounded = Math.round(number * 10) / 10
        return Math.abs(rounded - Math.round(rounded)) < 0.0001 ? Math.round(rounded) : rounded.toFixed(1)
    }
}
