import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root

    property var stackView
    property var editorStore
    property var mainPage

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0f172a"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        Label {
            text: qsTr("Edit Powerup")
            font.pixelSize: 32
            font.bold: true
            color: "#e2e8f0"
        }

        ListView {
            id: powerupList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12
            model: editorStore ? editorStore.createdPowerupsModel : null

            delegate: ItemDelegate {
                width: powerupList.width
                text: (modelData && modelData.colorLabel ? modelData.colorLabel : qsTr("Unknown"))
                      + qsTr(" — ")
                      + (modelData && modelData.targetLabel ? modelData.targetLabel : qsTr("Target"))
                onClicked: root._openEditor(modelData ? modelData.id : -1, modelData)
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No powerups available.")
                color: "#94a3b8"
                visible: !editorStore || editorStore.createdPowerupsModel.count === 0
            }
        }
    }

    Component {
        id: adjustComponent
        AdjustPowerValuePage {
            editMode: true
        }
    }

    function _openEditor(identifier, payload) {
        if (!stackView || !editorStore || identifier < 0)
            return
        stackView.push(adjustComponent, {
                          stackView: stackView,
                          editorStore: editorStore,
                          mainPage: mainPage || root,
                          editMode: true,
                          existingId: identifier,
                          configuration: payload || {},
                          initialHp: payload && payload.hp ? payload.hp : 0
                      })
    }
}
