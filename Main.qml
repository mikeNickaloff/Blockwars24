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
            onSinglePlayerClicked: stackView.push(selectPowerupGameSceneComponent)
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
            stackView: stackView
            editorStore: powerupEditorStore
        }
    }

    Component {
        id: selectPowerupGameSceneComponent
        SelectPowerupGameScene {
            stackView: stackView
            onBackRequested: stackView && stackView.pop()
            onSelectionComplete: function(selectedPowerups) {
                if (!stackView)
                    return
                stackView.replace(singlePlayerGameSceneComponent, {
                                       stackView: stackView,
                                       selectedPowerups: selectedPowerups
                                   })
            }
        }
    }

    Component {
        id: singlePlayerGameSceneComponent
        SinglePlayerGameScene {
            stackView: stackView
            onExitToMenuRequested: stackView && stackView.pop()
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
            onBackRequested: stackView && stackView.pop()
        }
    }

    Component {
        id: optionsPlaceholderComponent
        PlaceholderPage {
            title: qsTr("Options")
            message: qsTr("Options are under construction.")
            onBackRequested: stackView && stackView.pop()
        }
    }
}
