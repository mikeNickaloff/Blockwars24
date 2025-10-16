import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: sidebar

    property var powerupDataStore
    property var displayedPowerups: []

    implicitWidth: 220

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#111827"
        border.color: "#1e293b"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Label {
            text: qsTr("Powerups")
            font.pixelSize: 18
            font.bold: true
            color: "#f8fafc"
        }

        Repeater {
            model: displayedPowerups
            delegate: Rectangle {
                width: sidebar.width - 32
                height: 60
                radius: 8
                color: "#1e293b"
                border.color: "#334155"
                border.width: 1
                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    Label {
                        text: (modelData && modelData.typeLabel) ? modelData.typeLabel : qsTr("Powerup")
                        color: "#e2e8f0"
                        font.pixelSize: 14
                    }
                    Label {
                        text: (modelData && modelData.colorLabel) ? modelData.colorLabel : ""
                        color: "#94a3b8"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    Component.onCompleted: refresh()
    onPowerupDataStoreChanged: refresh()

    function refresh() {
        displayedPowerups = sidebar._powerupList()
    }

    function _powerupList() {
        if (!powerupDataStore)
            return []
        const getter = powerupDataStore.getPowerupData || powerupDataStore.allPowerups
        if (getter) {
            const result = getter.call(powerupDataStore)
            if (result && result.count !== undefined && typeof result.get === "function") {
                const values = []
                for (let i = 0; i < result.count; ++i)
                    values.push(result.get(i))
                return values
            }
            if (Array.isArray(result))
                return result
        }
        return []
    }
}
