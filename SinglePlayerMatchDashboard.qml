import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    property bool mirrored: false
    property real chargeProgress: 0.0
    property color meterColor: "#38bdf8"
    property var powerupSlots: []

    readonly property real clampedProgress: Math.max(0, Math.min(1, chargeProgress))

    implicitWidth: 900
    implicitHeight: 320

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#0b1222"
        border.color: "#1e293b"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        Label {
            text: root.title
            font.pixelSize: 26
            font.bold: true
            color: "#e2e8f0"
            Layout.fillWidth: true
        }

        Loader {
            active: !root.mirrored
            sourceComponent: ProgressBar {
                id: topMeter
                from: 0
                to: 1
                value: root.clampedProgress
                Layout.fillWidth: true
                Layout.preferredHeight: 16
                background: Rectangle {
                    radius: 8
                    color: "#10172b"
                    border.color: "#1e293b"
                    border.width: 1
                }
                contentItem: Item {
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        height: topMeter.height - 4
                        width: topMeter.visualPosition * topMeter.width
                        radius: (height) / 2
                        color: root.meterColor
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            spacing: 24

            SinglePlayerMatchGrid {
                Layout.fillWidth: true
                Layout.preferredWidth: parent ? parent.width * 0.65 : implicitWidth
                Layout.preferredHeight: Math.max(280, implicitHeight)
                Layout.minimumWidth: 320
                Layout.minimumHeight: 280
                Layout.maximumWidth: parent ? parent.width * 0.75 : implicitWidth
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: Math.max(220, Math.min(300, parent ? parent.width * 0.32 : 240))
                Layout.minimumWidth: 200
                Layout.maximumWidth: 320
                Layout.alignment: Qt.AlignTop
                spacing: 14

                Repeater {
                    model: 4
                    delegate: SinglePlayerMatchPowerupCard {
                        title: slotData(index).title
                        lines: slotData(index).lines
                        accentColor: slotData(index).accentColor
                        energy: slotData(index).energy
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }

        Loader {
            active: root.mirrored
            sourceComponent: ProgressBar {
                id: bottomMeter
                from: 0
                to: 1
                value: root.clampedProgress
                Layout.fillWidth: true
                Layout.preferredHeight: 16
                background: Rectangle {
                    radius: 8
                    color: "#10172b"
                    border.color: "#1e293b"
                    border.width: 1
                }
                contentItem: Item {
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        height: bottomMeter.height - 4
                        width: bottomMeter.visualPosition * bottomMeter.width
                        radius: (height) / 2
                        color: root.meterColor
                    }
                }
            }
        }
    }

    function slotData(index) {
        const fallback = {
            title: qsTr("Empty Slot"),
            lines: [qsTr("No powerup assigned.")],
            accentColor: "#334155",
            energy: 0
        }
        if (!powerupSlots || powerupSlots.length <= index || index < 0)
            return fallback
        const entry = powerupSlots[index]
        if (!entry)
            return fallback
        return {
            title: entry.title !== undefined ? entry.title : fallback.title,
            lines: entry.lines !== undefined ? entry.lines : fallback.lines,
            accentColor: entry.accentColor !== undefined ? entry.accentColor : fallback.accentColor,
            energy: entry.energy !== undefined ? entry.energy : fallback.energy
        }
    }
}
