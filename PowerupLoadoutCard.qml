import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property int slotIndex: -1
    property var powerup: null
    property bool active: false
    property bool interactive: true
    property string emptyTitle: qsTr("Slot %1").arg(slotIndex + 1)
    property string emptyDescription: qsTr("Tap a powerup card to fill this slot.")
    property color accentColor: powerup && powerup.colorHex ? powerup.colorHex : "#1f2937"

    signal clicked()

    implicitWidth: 260
    implicitHeight: 168

    Rectangle {
        id: background
        anchors.fill: parent
        radius: 16
        color: active ? Qt.lighter(accentColor, 1.35) : "#111827"
        border.width: active ? 2 : 1
        border.color: active ? "#38bdf8" : accentColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 32
                height: 32
                radius: 9
                color: accentColor
                border.width: 0

                Label {
                    anchors.centerIn: parent
                    text: slotIndex >= 0 ? (slotIndex + 1) : ""
                    color: "#0f172a"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: powerup && powerup.name ? powerup.name : emptyTitle
                    font.pixelSize: 20
                    font.bold: true
                    color: "#f8fafc"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Label {
                    text: powerup && powerup.effectSummary ? powerup.effectSummary : ""
                    visible: powerup && powerup.effectSummary
                    color: "#cbd5f5"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8
            visible: powerup && powerup.tags && powerup.tags.length > 0

            Repeater {
                model: powerup && powerup.tags ? powerup.tags : []

                delegate: Rectangle {
                    height: 24
                    radius: 8
                    color: "#1f2937"
                    border.width: 1
                    border.color: "#334155"

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }
        }

        Label {
            text: powerup && powerup.description ? powerup.description : emptyDescription
            color: powerup && powerup.description ? "#cbd5f5" : "#64748b"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    TapHandler {
        enabled: root.interactive
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.clicked()
    }
}
