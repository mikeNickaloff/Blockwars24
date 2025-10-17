import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string title: qsTr("Work In Progress")
    property string message: qsTr("This section is not ready yet.")
    property StackView stackView
    signal backRequested()

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0b1120"
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        Layout.maximumWidth: 520

        Label {
            text: root.title
            font.pixelSize: 30
            font.bold: true
            color: "#f8fafc"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: root.message
            font.pixelSize: 16
            color: "#94a3b8"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: qsTr("Back")
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                root.backRequested()
                if (root.stackView)
                    root.stackView.pop()
            }
        }
    }
}
