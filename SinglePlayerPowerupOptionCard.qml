import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Frame {
    id: optionCard
    property var option

    signal optionActivated(var option)

    padding: 14
    background: Rectangle {
        radius: 10
        color: "#111827"
        border.color: "#1f2937"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Label {
            text: option && option.powerup ? option.powerup.name : qsTr("Powerup")
            font.pixelSize: 20
            font.bold: true
            color: "#f8fafc"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: option && option.description ? option.description : qsTr("No description provided.")
            color: "#cbd5f5"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Flow {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: option && option.summary ? option.summary.length : 0
                delegate: Rectangle {
                    id: badge
                    radius: 6
                    color: "#1e293b"
                    border.color: "#334155"
                    border.width: 1
                    implicitHeight: 28
                    implicitWidth: badgeLabel.implicitWidth + 20
                    height: implicitHeight
                    width: implicitWidth

                    Label {
                        id: badgeLabel
                        anchors.centerIn: parent
                        text: option.summary[index]
                        color: "#94a3b8"
                        font.pixelSize: 12
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Button {
            text: qsTr("Choose")
            Layout.fillWidth: true
            onClicked: optionCard.optionActivated(option)
        }
    }
}
