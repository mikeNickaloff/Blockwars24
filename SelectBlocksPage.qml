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
    property int gridSize: 6
    property color selectedColor: configuration.colorHex || fallbackColor(configuration.colorKey)
    property var initialBlocks: []
    property int initialHp: 5

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
            text: qsTr("Select Blocks")
            font.pixelSize: 32
            font.bold: true
            color: "#e2e8f0"
        }

        Label {
            text: qsTr("Click blocks to toggle them between inactive and %1.").arg(configuration.colorLabel || configuration.colorKey || qsTr("selected"))
            wrapMode: Text.WordWrap
            color: "#cbd5f5"
            Layout.fillWidth: true
        }

        Item {
            id: gridContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: parent.height * 0.5

            property real cellSize: Math.min(width, height) / gridSize

            Grid {
                id: blockGrid
                anchors.centerIn: parent
                rows: gridSize
                columns: gridSize
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    id: cellRepeater
                    model: cellModel
                    delegate: Item {
                        width: gridContainer.cellSize
                        height: gridContainer.cellSize
                        readonly property bool isSelected: model.selected

                        PowerupGridBlock {
                            anchors.fill: parent
                            selected: parent.isSelected
                            highlightColor: root.selectedColor
                            idleColor: "#4b5563"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: cellModel.setProperty(index, "selected", !parent.isSelected)
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: qsTr("HP Adjustment: %1").arg(Math.round(hpSlider.value))
                    color: "#f8fafc"
                }
            }

    Slider {
        id: hpSlider
        from: 1
        to: 20
        stepSize: 1
        value: clampValue(root.initialHp, from, to)
        Layout.fillWidth: true
    }

            Button {
                text: root.editMode ? qsTr("Save") : qsTr("Finish")
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 20
                padding: 14
                onClicked: root.persistSelection()
            }
        }
    }

    ListModel {
        id: cellModel
        Component.onCompleted: root.initializeGrid()
    }

    onInitialBlocksChanged: Qt.callLater(applyInitialBlocks)
    onInitialHpChanged: hpSlider.value = clampValue(root.initialHp, hpSlider.from, hpSlider.to)

    function initializeGrid() {
        cellModel.clear()
        for (var i = 0; i < gridSize * gridSize; ++i)
            cellModel.append({ selected: false })
        Qt.callLater(applyInitialBlocks)
    }

    function applyInitialBlocks() {
        if (!root.initialBlocks || root.initialBlocks.length === 0)
            return
        for (var i = 0; i < root.initialBlocks.length; ++i) {
            var block = root.initialBlocks[i]
            if (!block)
                continue
            var row = Number(block.row)
            var column = Number(block.column)
            if (isNaN(row) || isNaN(column))
                continue
            if (row < 0 || row >= gridSize || column < 0 || column >= gridSize)
                continue
            var index = row * gridSize + column
            if (index >= 0 && index < cellModel.count)
                cellModel.setProperty(index, "selected", true)
        }
    }

    function persistSelection() {
        if (!editorStore) {
            stackView.pop(mainPage)
            return
        }

        var selectedBlocks = []
        for (var i = 0; i < cellModel.count; ++i) {
            var entry = cellModel.get(i)
            if (entry.selected) {
                selectedBlocks.push({
                                       row: Math.floor(i / gridSize),
                                       column: i % gridSize
                                   })
            }
        }

        var payload = {
            typeKey: configuration.typeKey,
            typeLabel: configuration.typeLabel,
            targetKey: configuration.targetKey,
            targetLabel: configuration.targetLabel,
            colorKey: configuration.colorKey,
            colorLabel: configuration.colorLabel,
            colorHex: configuration.colorHex,
            hp: Math.round(hpSlider.value),
            blocks: selectedBlocks
        }

        if (root.editMode && root.existingId >= 0)
            editorStore.updatePowerup(root.existingId, payload)
        else
            editorStore.addPowerup(payload)

        stackView.pop(mainPage)
    }

    function fallbackColor(colorKey) {
        switch (colorKey) {
        case "red": return "#ef4444"
        case "green": return "#22c55e"
        case "blue": return "#3b82f6"
        case "yellow": return "#eab308"
        default: return "#94a3b8"
        }
    }

    function clampValue(value, minValue, maxValue) {
        var number = Number(value)
        if (isNaN(number))
            number = minValue
        return Math.max(minValue, Math.min(maxValue, number))
    }
}
