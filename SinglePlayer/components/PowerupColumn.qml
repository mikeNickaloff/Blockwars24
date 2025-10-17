import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: column

    property var model: []

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Repeater {
            model: Array.isArray(column.model) ? column.model.length : 0
            delegate: Rectangle {
                width: parent ? parent.width : 200
                height: 88
                radius: 12
                color: "#0f172a"
                border.color: "#1e293b"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: column.model[index].colorHex
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: column.model[index].typeLabel + qsTr(" vs ") + column.model[index].targetLabel
                                color: "#f8fafc"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            Label {
                                text: qsTr("HP: %1").arg(column.model[index].hp)
                                color: "#94a3b8"
                                font.pixelSize: 11
                            }
                        }
                    }

                    PowerupChargeMeter {
                        Layout.fillWidth: true
                        progress: column.model[index].energy
                        requiredEnergy: column.model[index].energy
                        accentColor: column.model[index].colorHex
                    }
                }
            }
        }
    }
}
