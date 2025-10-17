import QtQuick
import QtQuick.Controls

Item {
    id: gridView

    property alias grid: gridPlaceholder

    Rectangle {
        id: gridPlaceholder
        anchors.fill: parent
        radius: 16
        color: "#0f1a2e"
        border.color: "#1d4ed8"
        border.width: 1

        Label {
            anchors.centerIn: parent
            text: qsTr("Grid placeholder")
            color: "#64748b"
            font.pixelSize: 16
        }
    }
}
