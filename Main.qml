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
            onSinglePlayerClicked: stackView.push(singlePlayerSelectPowerupsComponent, {
                stackView: stackView,
                editorStore: powerupEditorStore,
                slotCount: 4
            })
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
        id: singlePlayerGameSceneComponent
        SinglePlayerGameScene {
            stackView: stackView
            powerupSelectionComponent: singlePlayerSelectPowerupsComponent
            powerupSlotCount: 4
            editorStore: powerupEditorStore
            onExitToMenuRequested: stackView && stackView.pop()
            onBeginMatchRequested: function(selection) {
                if (!stackView)
                    return
                stackView.push(singlePlayerMatchSceneComponent, {
                                    stackView: stackView,
                                    playerLoadout: selection,
                                    cpuLoadout: []
                                })
            }
        }
    }

    Component {
        id: singlePlayerMatchSceneComponent
        SinglePlayerMatchScene {
            stackView: stackView
            editorStore: powerupEditorStore
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
                    editorStore: editorStore,
                    powerupSelectionComponent: singlePlayerSelectPowerupsComponent,
                    powerupSlotCount: slotCount,
                    selectedPowerups: selection
                })
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
