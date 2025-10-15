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
            onSinglePlayerClicked: window.stackView.push(selectPowerupGameSceneComponent)
            onMultiplayerClicked: window.stackView.push(multiplayerPlaceholderComponent)
            onPowerupEditorClicked: window.stackView.push(powerupEditorMainComponent, {
                                                   stackView: window.stackView,
                                                   editorStore: powerupEditorStore
                                               })
            onOptionsClicked: window.stackView.push(optionsPlaceholderComponent)
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
        id: selectPowerupGameSceneComponent
        SelectPowerupGameScene {
            stackView: window.stackView
            onBackRequested: window.stackView && window.stackView.pop()
            onSelectionComplete: function(selectedPowerups) {
                if (!window.stackView)
                    return
                window.stackView.replace(singlePlayerGameSceneComponent, {
                                       stackView: window.stackView,
                                       selectedPowerups: selectedPowerups
                                   })
            }
        }
    }

    Component {
        id: singlePlayerGameSceneComponent
        SinglePlayerGameScene {
            stackView: window.stackView
            onExitToMenuRequested: window.stackView && window.stackView.pop()
            onBeginMatchRequested: function(selection) {
                console.log("Starting single player match with powerups:", JSON.stringify(selection))
            }
        }
    }

    Component {
        id: multiplayerPlaceholderComponent
        PlaceholderPage {
            title: qsTr("Multiplayer")
            message: qsTr("Multiplayer flow is under construction.")
            onBackRequested: window.stackView && window.stackView.pop()
        }
    }

    Component {
        id: optionsPlaceholderComponent
        PlaceholderPage {
            title: qsTr("Options")
            message: qsTr("Options are under construction.")
            onBackRequested: window.stackView && window.stackView.pop()
        }
    }
}
