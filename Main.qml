import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./MainMenu"
import "./PowerupEditor"
import "./Shared"

ApplicationWindow {
    id: window
    width: 1024
    height: 768
    visible: true
    title: qsTr("Block Wars")

    color: "#020617"

    PowerupRepository {
        id: powerupRepository
        scope: "editor_custom_powerups"
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenuComponent
    }

    Component {
        id: mainMenuComponent
        MainMenuPage {
            onSinglePlayerRequested: stackView.push(placeholderComponent, {
                                                title: qsTr("Single Player"),
                                                message: qsTr("Single player mode is under construction."),
                                                stackView: stackView
                                            })
            onMultiplayerRequested: stackView.push(placeholderComponent, {
                                                title: qsTr("Multiplayer"),
                                                message: qsTr("Multiplayer mode is under construction."),
                                                stackView: stackView
                                            })
            onPowerupEditorRequested: stackView.push(powerupEditorComponent, {
                                                    stackView: stackView,
                                                    repository: powerupRepository
                                                })
            onOptionsRequested: stackView.push(placeholderComponent, {
                                               title: qsTr("Options"),
                                               message: qsTr("Options will arrive later."),
                                               stackView: stackView
                                           })
            onExitRequested: Qt.quit()
        }
    }

    Component {
        id: powerupEditorComponent
        PowerupEditorScene {}
    }

    Component {
        id: placeholderComponent
        PlaceholderPage {}
    }
}
