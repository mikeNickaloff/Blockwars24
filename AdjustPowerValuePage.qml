import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root
    property var stackView
    property var powerupRepository
    property var mainPage
    property var configuration: ({})
    property bool editMode: false
    property int existingId: -1
    property int initialHp: 10

    readonly property int blockSelectionCount: configuration && configuration.blocks ? configuration.blocks.length : 0
    readonly property int computedEnergy: energyModel.estimateEnergy({
                                    hp: Math.round(amountSlider.value),
                                    blockCount: Math.max(1, blockSelectionCount),
                                    typeKey: configuration.typeKey,
                                    targetKey: configuration.targetKey
                                })

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0f172a"
    }

    PowerupEnergyModel {
        id: energyModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        Label {
            text: configuration.targetKey === "heroes"
                  ? qsTr("Adjust Hero Power")
                  : (configuration.targetKey === "blocks"
                     ? qsTr("Adjust Block Power")
                     : qsTr("Adjust Player Power"))
            font.pixelSize: 32
            font.bold: true
            color: "#e2e8f0"
        }

        Label {
            text: configuration.targetKey === "blocks"
                  ? qsTr("Use the slider to set how much HP to %1 each selected block when this powerup activates.")
                        .arg(configuration.typeKey === "self" ? qsTr("restore to") : qsTr("remove from"))
                  : qsTr("Use the slider to set the amount of HP to %1 when this powerup activates.")
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
                Label {
                    text: qsTr("Energy: %1").arg(root.computedEnergy)
                    color: "#38bdf8"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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

            Label {
                visible: configuration.targetKey === "blocks"
                text: qsTr("Blocks targeted: %1").arg(configuration.blocks && configuration.blocks.length ? configuration.blocks.length : 0)
                color: "#94a3b8"
                font.pixelSize: 12
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
        if (!powerupRepository) {
            stackView.pop(mainPage)
            return
        }

        const blockSelection = cloneBlocks(configuration.blocks)

        var payload = {
            typeKey: configuration.typeKey,
            typeLabel: configuration.typeLabel,
            targetKey: configuration.targetKey,
            targetLabel: configuration.targetLabel,
            colorKey: configuration.colorKey,
            colorLabel: configuration.colorLabel,
            colorHex: configuration.colorHex,
            hp: Math.round(amountSlider.value),
            energy: computedEnergy,
            blockCount: blockSelection.length,
            blocks: blockSelection
        }

        if (root.editMode && root.existingId >= 0)
            powerupRepository.updatePowerup(root.existingId, payload)
        else
            powerupRepository.addPowerup(payload)

        stackView.pop(mainPage)
    }

    function clampValue(value, minValue, maxValue) {
        var number = Number(value)
        if (isNaN(number))
            number = minValue
        return Math.max(minValue, Math.min(maxValue, number))
    }

    function cloneBlocks(blocks) {
        var sanitized = []
        if (!Array.isArray(blocks))
            return sanitized
        var seen = {}
        for (var i = 0; i < blocks.length; ++i) {
            var cell = blocks[i]
            if (!cell)
                continue
            var row = Math.max(0, Math.min(5, Number(cell.row)))
            var column = Math.max(0, Math.min(5, Number(cell.column)))
            var key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        return sanitized
    }
}
