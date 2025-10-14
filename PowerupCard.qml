// PowerupCard.qml
// A visual representation of a powerup using AbstractGameElement as the base.
// It displays information about the powerup and a small energy bar. Clicking
// on the card emits a signal for further handling.

import QtQuick
import QtQuick.Controls
import Blockwars24 1.0

AbstractGameElement {
    id: root

    // Powerup metadata
    property string type: ""
    property string target: ""
    property string color: ""
    property int hpAmount: 0
    property int blocksSelected: 0
    property double energy: 0

    // Emitted when the card is clicked
    signal clicked

    // Visual layout
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: {
            switch (root.color.toLowerCase()) {
            case "red":    return "#d9534f";
            case "green":  return "#5cb85c";
            case "blue":   return "#428bca";
            case "yellow": return "#f0ad4e";
            default:        return "#eeeeee";
            }
        }
        border.color: "#444"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 4
            Text {
                text: root.type + " " + root.target
                color: "white"
                font.pointSize: 10
                wrapMode: Text.Wrap
            }
            Text {
                text: "Color: " + root.color
                color: "white"
                font.pointSize: 9
            }
            Text {
                text: "HP: " + root.hpAmount
                color: "white"
                font.pointSize: 9
            }
            Text {
                text: "Blocks: " + root.blocksSelected
                visible: root.target === "Blocks"
                color: "white"
                font.pointSize: 9
            }
            // Energy bar
            Rectangle {
                id: barBackground
                width: parent.width
                height: 6
                radius: 3
                color: "#222"
                Rectangle {
                    id: barFill
                    width: barBackground.width * Math.min(1, root.energy / 100)
                    height: barBackground.height
                    radius: 3
                    color: {
                        switch (root.color.toLowerCase()) {
                        case "red":    return "#d9534f";
                        case "green":  return "#5cb85c";
                        case "blue":   return "#428bca";
                        case "yellow": return "#f0ad4e";
                        default:        return "#999999";
                        }
                    }
                }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}