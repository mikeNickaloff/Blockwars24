import QtQuick
import QtQuick.Controls
import "."

ApplicationWindow {
    id: window
    width: 1024
    height: 768
    visible: true
    title: qsTr("Block Wars")

    PowerupEditorStore {
        id: powerupEditorStore
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenuComponent
    }

    Component {
        id: mainMenuComponent
        MainMenup {
            onSinglePlayerClicked: stackView.push(singlePlayerPlaceholderComponent)
            onMultiplayerClicked: stackView.push(multiplayerPlaceholderComponent)
            onPowerupEditorClicked: stackView.push(powerupEditorMainComponent, {
                                                   stackView: stackView,
                                                   editorStore: powerupEditorStore
                                               })
            onOptionsClicked: stackView.push(optionsPlaceholderComponent)
            onExitClicked: Qt.quit()
        }
    }

    Component {
        id: powerupEditorMainComponent
        PowerupEditorMainPage {
            id: powerupEditorPage
            stackView: window.stackView
            editorStore: powerupEditorStore
        }
    }

    Component {
        id: singlePlayerPlaceholderComponent
        PlaceholderPage {
            title: qsTr("Single Player")
            message: qsTr("Single player flow is under construction.")
            onBackRequested: stackView.pop()
        }
    }

    Component {
        id: multiplayerPlaceholderComponent
        PlaceholderPage {
            title: qsTr("Multiplayer")
            message: qsTr("Multiplayer flow is under construction.")
            onBackRequested: stackView.pop()
        }
    }

    Component {
        id: optionsPlaceholderComponent
        PlaceholderPage {
            title: qsTr("Options")
            message: qsTr("Options are under construction.")
            onBackRequested: stackView.pop()
        }
    }
}
