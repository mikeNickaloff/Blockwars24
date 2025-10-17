import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property Item flow
    property StackView stackView
    required property var draft

    readonly property var typeOptions: [
        { key: "enemy", label: qsTr("Enemy"), description: qsTr("Focus on offensive effects."), accent: "#f97316" },
        { key: "self", label: qsTr("Self"), description: qsTr("Support your own forces."), accent: "#34d399" }
    ]

    readonly property var targetOptions: [
        { key: "blocks", label: qsTr("Blocks"), description: qsTr("Affect individual grid blocks."), accent: "#a855f7" },
        { key: "heroes", label: qsTr("Hero(s)"), description: qsTr("Channel power into hero units."), accent: "#fbbf24" },
        { key: "players", label: qsTr("Player Health"), description: qsTr("Impact the player health pools."), accent: "#60a5fa" }
    ]

    readonly property var colorOptions: [
        { key: "red", label: qsTr("Red"), hex: "#ef4444" },
        { key: "green", label: qsTr("Green"), hex: "#22c55e" },
        { key: "blue", label: qsTr("Blue"), hex: "#3b82f6" },
        { key: "yellow", label: qsTr("Yellow"), hex: "#facc15" }
    ]

    property int typeIndex: _indexForKey(typeOptions, draft.typeKey)
    property int targetIndex: _indexForKey(targetOptions, draft.targetKey)
    property int colorIndex: _indexForKey(colorOptions, draft.colorKey)

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#111827"
        border.color: "#1e293b"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 28

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: qsTr("Create Powerup")
                font.pixelSize: 32
                font.bold: true
                color: "#f8fafc"
            }

            Item { Layout.fillWidth: true }

            ToolButton {
                text: "✕"
                padding: 10
                background: Rectangle {
                    color: "#dc2626"
                    radius: 12
                }
                contentItem: Label {
                    text: parent ? parent.parent.text : "✕"
                    anchors.centerIn: parent
                    font.bold: true
                    color: "#f8fafc"
                }
                onClicked: root.flow.finished()
            }
        }

        Label {
            text: qsTr("Select the fundamentals for this powerup. These choices will drive targeting and energy calculations later.")
            wrapMode: Text.WordWrap
            color: "#94a3b8"
            Layout.fillWidth: true
        }

        GroupBox {
            title: qsTr("Type")
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                ComboBox {
                    id: typeCombo
                    Layout.fillWidth: true
                    model: typeOptions
                    textRole: "label"
                    currentIndex: Math.max(0, root.typeIndex)
                }

                Label {
                    text: typeOptions[typeCombo.currentIndex].description
                    wrapMode: Text.WordWrap
                    color: "#cbd5f5"
                    Layout.fillWidth: true
                }
            }
        }

        GroupBox {
            title: qsTr("Target")
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                ComboBox {
                    id: targetCombo
                    Layout.fillWidth: true
                    model: targetOptions
                    textRole: "label"
                    currentIndex: Math.max(0, root.targetIndex)
                }

                Label {
                    text: targetOptions[targetCombo.currentIndex].description
                    wrapMode: Text.WordWrap
                    color: "#cbd5f5"
                    Layout.fillWidth: true
                }
            }
        }

        GroupBox {
            title: qsTr("Color")
            Layout.fillWidth: true

            ComboBox {
                id: colorCombo
                Layout.fillWidth: true
                model: colorOptions
                textRole: "label"
                currentIndex: Math.max(0, root.colorIndex)
                delegate: ItemDelegate {
                    width: parent ? parent.width : implicitWidth
                    contentItem: Row {
                        spacing: 12
                        Rectangle {
                            width: 18
                            height: 18
                            radius: 6
                            color: model.hex
                        }
                        Label {
                            text: model.label
                            color: "#f8fafc"
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Next")
                enabled: typeCombo.currentIndex >= 0 && targetCombo.currentIndex >= 0 && colorCombo.currentIndex >= 0
                padding: 16
                font.pixelSize: 18
                onClicked: root._next()
            }
        }
    }

    function _indexForKey(list, key) {
        if (!Array.isArray(list))
            return 0
        for (let i = 0; i < list.length; ++i) {
            if (list[i].key === key)
                return i
        }
        return 0
    }

    function _next() {
        const type = typeOptions[typeCombo.currentIndex]
        const target = targetOptions[targetCombo.currentIndex]
        const color = colorOptions[colorCombo.currentIndex]
        const updated = {
            typeKey: type.key,
            typeLabel: type.label,
            targetKey: target.key,
            targetLabel: target.label,
            colorKey: color.key,
            colorLabel: color.label,
            colorHex: color.hex,
            hp: draft && draft.hp ? Math.max(1, Math.round(draft.hp)) : 10,
            blocks: draft && draft.blocks ? draft.blocks : []
        }
        flow.proceedToBlockStep(updated)
    }
}
