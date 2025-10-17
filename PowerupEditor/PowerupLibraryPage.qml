import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./"

Item {
    id: root

    property alias repository: libraryView.repository
    property var onEditRequested
    signal finished()

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0f172a"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Back")
                onClicked: finished()
            }

            Label {
                text: qsTr("Saved Powerups")
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: 30
                font.bold: true
                color: "#f8fafc"
            }

            Item { Layout.preferredWidth: 32 }
        }

        PowerupLibraryView {
            id: libraryView
            Layout.fillWidth: true
            Layout.fillHeight: true
            onEditRequested: function(entry) {
                if (typeof root.onEditRequested === "function")
                    root.onEditRequested(entry)
            }
        }
    }
}
