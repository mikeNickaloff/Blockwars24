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

    PowerupCatalog {
        id: powerupCatalog
        editorStore: powerupEditorStore
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenuComponent
    }

    Component {
        id: mainMenuComponent
        MainMenup {
            onSinglePlayerClicked: {
                if (!stackView)
                    return

                const optionsProvider = function() { return powerupCatalog.availableOptions() }
                const options = optionsProvider() || []

                stackView.push(singlePlayerGameSceneComponent, {
                    stackView: stackView,
                    powerupSlotCount: 4,
                    powerupOptions: options,
                    powerupOptionsProvider: optionsProvider
                })
            }
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
        }
    }

    Component {
        id: singlePlayerGameSceneComponent
        SinglePlayerGameScene {
            stackView: stackView
            powerupSelectionComponent: selectPowerupGameSceneComponent
            powerupSlotCount: 4
            powerupOptions: powerupCatalog.availableOptions()
            powerupOptionsProvider: function() { return powerupCatalog.availableOptions() }
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
