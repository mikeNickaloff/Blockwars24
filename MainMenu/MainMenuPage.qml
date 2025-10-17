import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal singlePlayerRequested()
    signal multiplayerRequested()
    signal powerupEditorRequested()
    signal optionsRequested()
    signal exitRequested()

    property color backgroundColor: "#020617"

    implicitWidth: 1024
    implicitHeight: 768
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 48
        spacing: 32

        Item {
            id: titleRegion
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(root.height * 0.2, 140)

            Label {
                text: qsTr("Block Wars")
                anchors.centerIn: parent
                font.pixelSize: Math.round(root.height * 0.08)
                font.bold: true
                color: "#e2e8f0"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 18

            Repeater {
                model: [
                    { title: qsTr("Single Player"), handler: root.singlePlayerRequested },
                    { title: qsTr("Multiplayer"), handler: root.multiplayerRequested },
                    { title: qsTr("Powerup Editor"), handler: root.powerupEditorRequested },
                    { title: qsTr("Options"), handler: root.optionsRequested },
                    { title: qsTr("Exit"), handler: root.exitRequested }
                ]

                delegate: Button {
                    text: modelData.title
                    Layout.preferredWidth: Math.min(root.width * 0.4, 320)
                    Layout.alignment: Qt.AlignHCenter
                    padding: 16
                    font.pixelSize: 18
                    onClicked: modelData.handler()
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
