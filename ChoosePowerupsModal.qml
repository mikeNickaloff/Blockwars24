import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: modal

    property var defaultPowerups: []

    signal powerupsChosen(var powerups)

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        radius: 16
        color: "#0f172a"
        border.color: "#1e293b"
        border.width: 1
    }

    contentItem: ColumnLayout {
        width: 360
        spacing: 16


        Label {
            text: qsTr("Choose Powerups")
            font.pixelSize: 20
            font.bold: true
            color: "#f8fafc"
        }

        ListView {
            id: powerupList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(320, contentHeight)
            clip: true
            spacing: 8
            model: defaultPowerups || []

            delegate: Button {
                readonly property var option: modelData
                text: (option && option.typeLabel) ? option.typeLabel : qsTr("Powerup")
                onClicked: modal._choose(option)
            }
        }

        Button {
            text: qsTr("Close")
            Layout.alignment: Qt.AlignHCenter
            onClicked: modal.close()
        }
    }

    function _choose(option) {
        modal.close()
        powerupsChosen(option)
    }
}
