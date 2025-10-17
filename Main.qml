import QtQuick
import QtQuick.Controls
import "."

ApplicationWindow {
    id: window
    width: 1024
    height: 768
    visible: true
    title: qsTr("Block Wars")

    PowerupCollectionController {
        id: powerupRepository
        table: "editor_custom_powerups"
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenuComponent
    }

    Component {
        id: mainMenuComponent
        MainMenup {
            onSinglePlayerClicked: stackView.push(singlePlayerSelectPowerupsComponent, {
                                                     stackView: stackView,
                                                     powerupRepository: powerupRepository
                                                 })
            onMultiplayerClicked: stackView.push(multiplayerPlaceholderComponent)
            onPowerupEditorClicked: stackView.push(powerupEditorMainComponent, {
                                                   stackView: stackView,
                                                   powerupRepository: powerupRepository
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
            powerupRepository: powerupRepository
        }
    }

    Component {
        id: singlePlayerGameSceneComponent
        SinglePlayerGameScene {

        }
    }

    Component {
        id: singlePlayerMatchSceneComponent
        Item {
        }
    }

    Component {
        id: singlePlayerSelectPowerupsComponent
        SinglePlayerSelectPowerupsScene {
            onBackRequested: {
                if (stackView)
                    stackView.pop()
            }

            onSelectionConfirmed: function(selection) {
                if (!stackView)
                    return
                stackView.pop()
                stackView.push(singlePlayerGameSceneComponent, {
                    stackView: stackView,
                    powerupRepository: powerupRepository,
                    powerupSelectionComponent: singlePlayerSelectPowerupsComponent,
                    powerupSlotCount: slotCount,
                    selectedPowerups: selection
                })
            }
            powerupRepository: powerupRepository
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
