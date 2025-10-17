import QtQuick
import "."

Item {
    id: page

    property var stackView
    property var powerupRepository

    anchors.fill: parent

    PowerupEditorScene {
        id: scene
        anchors.fill: parent
        stackView: page.stackView
        powerupRepository: page.powerupRepository
    }
}
