// MainMenu.qml
// This file defines a simple main menu for the Block Wars game. It presents
// a title and five buttons. Each button emits a signal that can be
// connected externally to handle navigation or other logic.

import QtQuick
import QtQuick.Controls

Item {
    id: root
    // This item fills its parent when used in an ApplicationWindow or similar.
    anchors.fill: parent

    // Signals emitted when each menu button is clicked.  External components
    // should connect to these to trigger navigation.
    signal singlePlayerClicked
    signal multiplayerClicked
    signal powerupEditorClicked
    signal optionsClicked
    signal exitClicked

    // A column that vertically arranges the title and buttons.  We center
    // the column horizontally and offset it slightly down from the top to
    // approximate the title occupying the top 20 % of the window.
    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        // Position the column roughly one fifth down from the top of the view.
        anchors.top: parent.top
        anchors.topMargin: height * 0.1
        spacing: 24

        // Game title
        Text {
            id: title
            text: qsTr("Block Wars")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 36
            font.bold: true
            // Give the title a bit more spacing below
            anchors.bottomMargin: 16
        }

        // Single player button
        Button {
            id: singlePlayerButton
            text: qsTr("Single Player")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.singlePlayerClicked()
        }

        // Multiplayer button
        Button {
            id: multiplayerButton
            text: qsTr("Multiplayer")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.multiplayerClicked()
        }

        // Powerup Editor button
        Button {
            id: powerupEditorButton
            text: qsTr("Powerup Editor")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.powerupEditorClicked()
        }

        // Options button
        Button {
            id: optionsButton
            text: qsTr("Options")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.optionsClicked()
        }

        // Exit button
        Button {
            id: exitButton
            text: qsTr("Exit")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.exitClicked()
        }
    }
}