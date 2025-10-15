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

    signal clicked()

    implicitWidth: 260
    implicitHeight: 168

    Rectangle {
        id: background
        anchors.fill: parent
        radius: 14
        color: active ? "#1e293b" : "#111827"
        border.width: active ? 2 : 1
        border.color: active ? "#38bdf8" : "#1f2937"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 28
                height: 28
                radius: 8
                color: active ? "#38bdf8" : "#1f2937"
                border.width: 0

                Label {
                    anchors.centerIn: parent
                    text: slotIndex >= 0 ? (slotIndex + 1) : ""
                    color: active ? "#0f172a" : "#94a3b8"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            Label {
                text: powerup && powerup.name ? powerup.name : emptyTitle
                font.pixelSize: 20
                font.bold: true
                color: "#f8fafc"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }

        Label {
            text: powerup && powerup.description ? powerup.description : emptyDescription
            color: powerup && powerup.description ? "#cbd5f5" : "#64748b"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            radius: 1
            color: active ? "#38bdf8" : "#1f2937"
        }
    }

    TapHandler {
        enabled: root.interactive
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.clicked()
    }
}
