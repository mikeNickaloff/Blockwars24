import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 1024
    implicitHeight: 768

    signal singlePlayerClicked
    signal multiplayerClicked
    signal powerupEditorClicked
    signal optionsClicked
    signal exitClicked

    Rectangle {
        anchors.fill: parent
        color: "#101421"
    }

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.1
        spacing: 32

        Label {
            id: titleLabel
            text: qsTr("Block Wars")
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 48
            font.bold: true
            color: "#f3f4f6"
        }

        Repeater {
            model: [
                { text: qsTr("Single Player"), handler: function() { root.singlePlayerClicked(); } },
                { text: qsTr("Multiplayer"), handler: function() { root.multiplayerClicked(); } },
                { text: qsTr("Powerup Editor"), handler: function() { root.powerupEditorClicked(); } },
                { text: qsTr("Options"), handler: function() { root.optionsClicked(); } },
                { text: qsTr("Exit"), handler: function() { root.exitClicked(); } }
            ]

            delegate: Button {
                readonly property var option: modelData
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(root.width * 0.4, 320)
                text: option.text
                font.pixelSize: 20
                padding: 12
                onClicked: option.handler()
            }
        }
    }
}
