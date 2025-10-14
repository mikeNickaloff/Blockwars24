import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var stackView
    property var editorStore
    property var mainPage
    property bool editMode: false
    property int existingId: -1
    property var existingData: ({})

    property var fallbackTypeOptions: [
        { key: "enemy", label: qsTr("Enemy") },
        { key: "self", label: qsTr("Self") }
    ]
    property var fallbackTargetOptions: [
        { key: "blocks", label: qsTr("Blocks") },
        { key: "heroes", label: qsTr("Hero(s)") },
        { key: "player", label: qsTr("Player Health") }
    ]
    property var fallbackColorOptions: [
        { key: "red", label: qsTr("Red"), color: "#ef4444" },
        { key: "green", label: qsTr("Green"), color: "#22c55e" },
        { key: "blue", label: qsTr("Blue"), color: "#3b82f6" },
        { key: "yellow", label: qsTr("Yellow"), color: "#eab308" }
    ]

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#111827"
    }

    Button {
        id: closeButton
        text: "✕"
        background: Rectangle {
            color: "#dc2626"
            radius: 6
        }
        font.pixelSize: 18
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 24
        anchors.rightMargin: 24
        onClicked: root.stackView.pop()
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        width: Math.min(parent.width * 0.6, 520)

        Label {
            text: root.editMode ? qsTr("Edit Powerup") : qsTr("Create Powerup")
            font.pixelSize: 32
            font.bold: true
            color: "#e2e8f0"
            Layout.alignment: Qt.AlignHCenter
        }

        GridLayout {
            Layout.fillWidth: true

            Label { text: qsTr("Type") }
            ComboBox {
                id: typeCombo
                Layout.fillWidth: true
                textRole: "label"
                valueRole: "key"
                model: root.editorStore ? root.editorStore.typeOptions : root.fallbackTypeOptions
            }

            Label { text: qsTr("Target") }
            ComboBox {
                id: targetCombo
                Layout.fillWidth: true
                textRole: "label"
                valueRole: "key"
                model: root.editorStore ? root.editorStore.targetOptions : root.fallbackTargetOptions
            }

            Label { text: qsTr("Color") }
            ComboBox {
                id: colorCombo
                Layout.fillWidth: true
                textRole: "label"
                valueRole: "key"
                model: root.editorStore ? root.editorStore.colorOptions : root.fallbackColorOptions
            }
        }

        Button {
            id: nextButton
            text: qsTr("Next")
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 20
            padding: 14
            onClicked: root.advanceToDetailPage()
        }
    }

    Component.onCompleted: Qt.callLater(root.applyExisting)
    onExistingDataChanged: Qt.callLater(root.applyExisting)

    function advanceToDetailPage() {
        var typeOption = optionFromModel(typeCombo.model, typeCombo.currentIndex)
        var targetOption = optionFromModel(targetCombo.model, targetCombo.currentIndex)
        var colorOption = optionFromModel(colorCombo.model, colorCombo.currentIndex)

        if (!targetOption)
            return

        var configuration = {
            typeKey: typeOption ? typeOption.key : "enemy",
            typeLabel: typeOption ? (typeOption.label || typeOption.text) : (typeCombo.currentText || ""),
            targetKey: targetOption.key,
            targetLabel: targetOption.label || targetOption.text || targetCombo.currentText,
            colorKey: colorOption ? colorOption.key : "red",
            colorLabel: colorOption ? (colorOption.label || colorOption.text) : (colorCombo.currentText || ""),
            colorHex: colorOption ? (colorOption.color || colorOption.hex || colorOption.swatch || fallbackColorForKey(colorOption.key)) : fallbackColorForKey("red")
        }

        var initialHp = defaultHpForTarget(configuration.targetKey)
        var initialBlocks = []
        if (root.editMode && root.existingData) {
            if (configuration.targetKey === root.existingData.targetKey)
                initialHp = root.existingData.hp || initialHp
            if (configuration.targetKey === "blocks" && root.existingData.targetKey === "blocks")
                initialBlocks = root.existingData.blocks || []
        }

        var nextComponent = configuration.targetKey === "blocks" ? selectBlocksComponent : adjustValueComponent
        var properties = {
            stackView: root.stackView,
            editorStore: root.editorStore,
            mainPage: root.mainPage,
            configuration: configuration,
            editMode: root.editMode,
            existingId: root.editingId(),
            initialHp: initialHp
        }
        if (configuration.targetKey === "blocks")
            properties.initialBlocks = initialBlocks
        root.stackView.push(nextComponent, properties)
    }

    function editingId() {
        return root.editMode ? root.existingId : -1
    }

    function optionFromModel(model, index) {
        if (!model || index < 0)
            return null
        if (model.get)
            return model.get(index)
        return model[index]
    }

    function fallbackColorForKey(key) {
        var options = root.fallbackColorOptions
        for (var i = 0; i < options.length; ++i) {
            if (options[i].key === key)
                return options[i].color
        }
        return "#94a3b8"
    }

    function defaultHpForTarget(targetKey) {
        return targetKey === "blocks" ? 5 : 10
    }

    function applyExisting() {
        if (!root.editMode || !root.existingData)
            return
        setComboSelection(typeCombo, root.existingData.typeKey, root.existingData.typeLabel)
        setComboSelection(targetCombo, root.existingData.targetKey, root.existingData.targetLabel)
        setComboSelection(colorCombo, root.existingData.colorKey, root.existingData.colorLabel)
    }

    function setComboSelection(combo, key, label) {
        if (!combo.model)
            return
        var index = findIndexByKey(combo.model, key)
        if (index < 0 && label)
            index = findIndexByLabel(combo.model, label)
        if (index >= 0)
            combo.currentIndex = index
    }

    function findIndexByKey(model, key) {
        var normalizedKey = (key || "").toString().toLowerCase()
        var index = -1
        iterateModel(model, function(entry, i) {
            if ((entry.key || "").toString().toLowerCase() === normalizedKey) {
                index = i
                return true
            }
            return false
        })
        return index
    }

    function findIndexByLabel(model, label) {
        var normalizedLabel = (label || "").toString().toLowerCase()
        var index = -1
        iterateModel(model, function(entry, i) {
            var value = (entry.label || entry.text || "").toString().toLowerCase()
            if (value === normalizedLabel) {
                index = i
                return true
            }
            return false
        })
        return index
    }

    function iterateModel(model, handler) {
        if (!model || !handler)
            return
        if (model.get && model.count !== undefined) {
            for (var i = 0; i < model.count; ++i) {
                if (handler(model.get(i), i))
                    break
            }
        } else if (model.length !== undefined) {
            for (var j = 0; j < model.length; ++j) {
                if (handler(model[j], j))
                    break
            }
        }
    }

    Component {
        id: selectBlocksComponent
        SelectBlocksPage {}
    }

    Component {
        id: adjustValueComponent
        AdjustPowerValuePage {}
    }
}
