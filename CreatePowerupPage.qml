import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root

    property var stackView
    property var powerupRepository
    property var mainPage
    property bool editMode: false
    property int existingId: -1
    property var existingData: ({})

    property var selectedType: ({})
    property var selectedTarget: ({})
    property var selectedColor: ({})
    property var selectedBlocks: []
    readonly property int selectedBlockCount: selectedBlocks ? selectedBlocks.length : 0
    property int selectedEnergy: 12
    property int _provisionalHp: 12

    readonly property var typeOptions: [
        {
            key: "self",
            label: qsTr("Support"),
            subtitle: qsTr("Bolster your own forces with restorative energy."),
            description: qsTr("Focuses on healing and empowering friendly targets."),
            iconColor: "#34d399"
        },
        {
            key: "enemy",
            label: qsTr("Assault"),
            subtitle: qsTr("Unleash a tactical strike against foes."),
            description: qsTr("Inflicts damage or penalties on enemy targets."),
            iconColor: "#f87171"
        }
    ]

    readonly property var targetOptions: [
        {
            key: "players",
            label: qsTr("Players"),
            subtitle: qsTr("Channel power directly into the player health pools."),
            hint: qsTr("Great for ultimate swings in health totals."),
            iconColor: "#60a5fa"
        },
        {
            key: "heroes",
            label: qsTr("Heroes"),
            subtitle: qsTr("Specialize the powerup toward hero units on the board."),
            hint: qsTr("Ideal for focused buffs and tactical strikes."),
            iconColor: "#fbbf24"
        },
        {
            key: "blocks",
            label: qsTr("Blocks"),
            subtitle: qsTr("Select individual blocks as targets."),
            hint: qsTr("Perfect for precise maneuvers across the grid."),
            iconColor: "#a855f7"
        }
    ]

    readonly property var colorOptions: [
        { key: "red", label: qsTr("Red"), hex: "#ef4444" },
        { key: "blue", label: qsTr("Blue"), hex: "#3b82f6" },
        { key: "green", label: qsTr("Green"), hex: "#22c55e" },
        { key: "yellow", label: qsTr("Yellow"), hex: "#facc15" }
    ]

    PowerupEnergyModel {
        id: energyModel
    }

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0f172a"
    }

    ScrollView {
        id: scroller
        anchors.fill: parent
        anchors.margins: 32
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: contentLayout
            width: scroller.availableWidth
            spacing: 28

            Label {
                text: qsTr("Create Powerup")
                font.pixelSize: 36
                font.bold: true
                color: "#f8fafc"
            }

            GroupBox {
                title: qsTr("Choose Powerup Role")
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Repeater {
                        model: typeOptions
                        delegate: AbstractButton {
                            id: typeButton
                            Layout.fillWidth: true
                            padding: 16
                            checkable: true
                            checked: root.selectedType.key === modelData.key
                            onClicked: root._setType(modelData)

                            background: Rectangle {
                                radius: 12
                                color: typeButton.checked ? "#1d4ed8" : (typeButton.hovered ? "#14213b" : "#0f172a")
                                border.color: "#1e293b"
                                border.width: 1
                            }

                            contentItem: RowLayout {
                                spacing: 16
                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 12
                                    color: modelData.iconColor
                                    opacity: 0.85
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Label {
                                        text: modelData.label
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#f8fafc"
                                    }
                                    Label {
                                        text: modelData.subtitle
                                        font.pixelSize: 14
                                        color: "#cbd5f5"
                                        wrapMode: Text.WordWrap
                                    }
                                    Label {
                                        text: modelData.description
                                        font.pixelSize: 12
                                        color: "#94a3b8"
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("Pick a Target Focus")
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Repeater {
                        model: targetOptions
                        delegate: AbstractButton {
                            id: targetButton
                            Layout.fillWidth: true
                            padding: 16
                            checkable: true
                            checked: root.selectedTarget.key === modelData.key
                            onClicked: root._setTarget(modelData)

                            background: Rectangle {
                                radius: 12
                                color: targetButton.checked ? "#2563eb" : (targetButton.hovered ? "#14213b" : "#0f172a")
                                border.color: "#1e293b"
                                border.width: 1
                            }

                            contentItem: RowLayout {
                                spacing: 16
                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 12
                                    color: modelData.iconColor
                                    opacity: 0.85
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Label {
                                        text: modelData.label
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#f8fafc"
                                    }
                                    Label {
                                        text: modelData.subtitle
                                        font.pixelSize: 14
                                        color: "#cbd5f5"
                                        wrapMode: Text.WordWrap
                                    }
                                    Label {
                                        text: modelData.hint
                                        font.pixelSize: 12
                                        color: "#94a3b8"
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.selectedTarget.key === "blocks"
                        spacing: 12

                        Label {
                            text: qsTr("Choose the exact blocks affected when this powerup fires.")
                            wrapMode: Text.WordWrap
                            color: "#cbd5f5"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }

                        PowerupBlockSelectionGrid {
                            id: blockSelector
                            Layout.alignment: Qt.AlignHCenter
                            onSelectionUpdate: function(cells) {
                                root._applySelectedBlocks(cells)
                            }
                        }

                        Label {
                            text: qsTr("Blocks Selected: %1").arg(root.selectedBlockCount)
                            color: "#f8fafc"
                            font.pixelSize: 14
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("Choose an Elemental Color")
                Layout.fillWidth: true

                Flow {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Repeater {
                        model: colorOptions
                        delegate: AbstractButton {
                            id: colorButton
                            implicitWidth: 140
                            implicitHeight: 64
                            checkable: true
                            checked: root.selectedColor.key === modelData.key
                            onClicked: root._setColor(modelData)

                            background: Rectangle {
                                radius: 12
                                color: colorButton.checked ? modelData.hex : "#0f172a"
                                border.color: colorButton.checked ? "#f8fafc" : "#1e293b"
                                border.width: 1
                            }

                            contentItem: Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Label {
                                    text: modelData.label
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: colorButton.checked ? "#0f172a" : "#f8fafc"
                                }
                                Label {
                                    text: modelData.hex
                                    font.pixelSize: 12
                                    color: colorButton.checked ? "#0f172a" : "#cbd5f5"
                                }
                            }
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("Energy Requirements")
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Label {
                        text: qsTr("Estimated Energy: %1").arg(root.selectedEnergy)
                        color: "#f8fafc"
                        font.pixelSize: 16
                    }

                    ProgressBar {
                        from: 0
                        to: energyModel.maximumEnergy
                        value: root.selectedEnergy
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("Energy adjusts automatically based on the powerup's impact. Increase the effect in the next step to raise the energy demand.")
                        wrapMode: Text.WordWrap
                        color: "#94a3b8"
                        font.pixelSize: 12
                    }
                }
            }

            GroupBox {
                title: qsTr("Summary")
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Label {
                        text: root._summaryLine(qsTr("Role"), root.selectedType.label)
                        color: "#f8fafc"
                        font.pixelSize: 14
                    }

                    Label {
                        text: root._summaryLine(qsTr("Target"), root.selectedTarget.label)
                        color: "#f8fafc"
                        font.pixelSize: 14
                    }

                    Label {
                        text: root._summaryLine(qsTr("Color"), root.selectedColor.label)
                        color: "#f8fafc"
                        font.pixelSize: 14
                    }

                    Label {
                        text: root._summaryLine(qsTr("Energy"), root.selectedEnergy)
                        color: "#f8fafc"
                        font.pixelSize: 14
                    }

                    Label {
                        visible: root.selectedTarget.key === "blocks"
                        text: root._summaryLine(qsTr("Blocks"), root.selectedBlockCount)
                        color: "#f8fafc"
                        font.pixelSize: 14
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: qsTr("Cancel")
                    Layout.alignment: Qt.AlignLeft
                    onClicked: root._cancel()
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: qsTr("Continue")
                    enabled: root._readyToContinue()
                    Layout.alignment: Qt.AlignRight
                    onClicked: root._advance()
                }
            }
        }
    }

    Component.onCompleted: _initializeSelections()
    onExistingDataChanged: _initializeSelections()

    function _initializeSelections() {
        selectedType = _cloneOption(_resolveOption(typeOptions, existingData.typeKey, typeOptions[0]))
        selectedTarget = _cloneOption(_resolveOption(targetOptions, existingData.targetKey, targetOptions[0]))
        selectedColor = _cloneOption(_resolveOption(colorOptions, existingData.colorKey, colorOptions[0]))
        _provisionalHp = existingData && existingData.hp !== undefined ? Math.round(existingData.hp) : 12
        selectedEnergy = energyModel.estimateEnergy({
            hp: _provisionalHp,
            blockCount: Math.max(1, selectedBlockCount || 1),
            typeKey: selectedType.key,
            targetKey: selectedTarget.key
        })
        _applySelectedBlocks(existingData && existingData.blocks ? existingData.blocks : [])
    }

    function _cloneOption(option) {
        return option ? Object.assign({}, option) : ({})
    }

    function _resolveOption(options, key, fallback) {
        if (!options || options.length === 0)
            return fallback
        if (!key)
            return fallback
        for (let i = 0; i < options.length; ++i) {
            if (options[i].key === key)
                return options[i]
        }
        return fallback
    }

    function _setType(option) {
        selectedType = _cloneOption(option)
        _refreshEnergy()
    }

    function _setTarget(option) {
        selectedTarget = _cloneOption(option)
        if (selectedTarget.key !== "blocks")
            _applySelectedBlocks([])
        else if ((!selectedBlocks || selectedBlocks.length === 0) && existingData && existingData.blocks)
            _applySelectedBlocks(existingData.blocks)
        else
            _refreshEnergy()
    }

    function _setColor(option) {
        selectedColor = _cloneOption(option)
    }

    function _applySelectedBlocks(blocks) {
        const sanitized = _sanitizeBlocks(blocks)
        selectedBlocks = sanitized
        if (typeof blockSelector !== "undefined" && blockSelector)
            blockSelector.setSelectedCells(sanitized)
        _refreshEnergy()
    }

    function _cloneBlocks(blocks) {
        const sanitized = _sanitizeBlocks(blocks)
        const copy = []
        for (let i = 0; i < sanitized.length; ++i)
            copy.push({ row: sanitized[i].row, column: sanitized[i].column })
        return copy
    }

    function _refreshEnergy() {
        const count = selectedTarget && selectedTarget.key === "blocks" ? Math.max(1, selectedBlockCount) : 1
        selectedEnergy = energyModel.estimateEnergy({
            hp: _provisionalHp,
            blockCount: count,
            typeKey: selectedType.key,
            targetKey: selectedTarget.key
        })
    }

    function _sanitizeBlocks(blocks) {
        const source = Array.isArray(blocks) ? blocks : []
        const seen = {}
        const sanitized = []
        for (let i = 0; i < source.length; ++i) {
            const block = source[i]
            if (!block)
                continue
            const row = Math.max(0, Math.min(5, Number(block.row)))
            const column = Math.max(0, Math.min(5, Number(block.column)))
            const key = row + ":" + column
            if (seen[key])
                continue
            seen[key] = true
            sanitized.push({ row: row, column: column })
        }
        return sanitized
    }

    function _clamp(value, minimum, maximum) {
        const number = Number(value)
        const fallback = isNaN(number) ? minimum : number
        return Math.max(minimum, Math.min(maximum, fallback))
    }

    function _summaryLine(title, value) {
        if (value === undefined || value === null || value === "")
            return title + ": " + qsTr("Not set")
        return title + ": " + value
    }

    function _readyToContinue() {
        if (!selectedType.key || !selectedTarget.key || !selectedColor.key)
            return false
        if (selectedTarget.key === "blocks")
            return selectedBlockCount > 0
        return true
    }

    function _cancel() {
        if (stackView)
            stackView.pop(mainPage)
    }

    function _advance() {
        if (!stackView)
            return
        const configuration = {
            typeKey: selectedType.key,
            typeLabel: selectedType.label,
            targetKey: selectedTarget.key,
            targetLabel: selectedTarget.label,
            colorKey: selectedColor.key,
            colorLabel: selectedColor.label,
            colorHex: selectedColor.hex,
            blockCount: selectedBlockCount,
            energy: selectedEnergy,
            blocks: selectedBlocks && selectedBlocks.length ? _cloneBlocks(selectedBlocks) : []
        }
        stackView.push(adjustComponent, {
                            stackView: stackView,
                            powerupRepository: powerupRepository,
                            mainPage: mainPage || root,
                            editMode: editMode,
                            existingId: existingId,
                            configuration: configuration,
                            initialHp: existingData && existingData.hp ? existingData.hp : 10
                        })
    }

    Component {
        id: adjustComponent
        AdjustPowerValuePage {}
    }
}
