import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var stackView
    property var editorStore
    property var mainPage
    property var configuration: ({})
    property bool editMode: false
    property int existingId: -1
    property int initialHp: 10

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
            text: configuration.targetKey === "heroes" ? qsTr("Adjust Hero Power") : qsTr("Adjust Player Power")
            font.pixelSize: 32
            font.bold: true
            color: "#e2e8f0"
        }

        Label {
            text: qsTr("Use the slider to set the amount of HP to %1 when this powerup activates.")
                    .arg(configuration.typeKey === "self" ? qsTr("restore") : qsTr("remove"))
            wrapMode: Text.WordWrap
            color: "#cbd5f5"
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: qsTr("HP Adjustment: %1").arg(Math.round(amountSlider.value))
                    color: "#f8fafc"
                }
            }

            Slider {
                id: amountSlider
                from: 0
                to: 100
                stepSize: 1
                value: clampValue(root.initialHp, from, to)
                Layout.fillWidth: true
            }

            Button {
                text: root.editMode ? qsTr("Save") : qsTr("Finish")
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 20
                padding: 14
                onClicked: root.persist()
            }
        }
    }

    onInitialHpChanged: amountSlider.value = clampValue(root.initialHp, amountSlider.from, amountSlider.to)

    function persist() {
        if (!editorStore) {
            stackView.pop(mainPage)
            return
        }

        var payload = {
            typeKey: configuration.typeKey,
            typeLabel: configuration.typeLabel,
            targetKey: configuration.targetKey,
            targetLabel: configuration.targetLabel,
            colorKey: configuration.colorKey,
            colorLabel: configuration.colorLabel,
            colorHex: configuration.colorHex,
            hp: Math.round(amountSlider.value),
            blocks: []
        }

        if (root.editMode && root.existingId >= 0)
            editorStore.updatePowerup(root.existingId, payload)
        else
            editorStore.addPowerup(payload)

        stackView.pop(mainPage)
    }

    function clampValue(value, minValue, maxValue) {
        var number = Number(value)
        if (isNaN(number))
            number = minValue
        return Math.max(minValue, Math.min(maxValue, number))
    }
}
