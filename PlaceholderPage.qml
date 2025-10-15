import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property string title: ""
    property string message: ""
    signal backRequested

    implicitWidth: 1024
    implicitHeight: 768

    Rectangle {
        anchors.fill: parent
        color: "#0d1117"
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: Math.min(parent.width * 0.6, 420)

        Label {
            text: root.title
            font.pixelSize: 32
            font.bold: true
            color: "#f0f6fc"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Label {
            text: root.message
            wrapMode: Text.WordWrap
            color: "#c9d1d9"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Back")
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.backRequested()
        }
    }
}
