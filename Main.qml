import QtQuick
import Blockwars24 1.0
import QtQuick.Controls
Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    Item {
        anchors.fill: parent

/*     AbstractGameElement {
         id: testElem
         width: 180
         height: 180
         x: 100
         y: 100
         Rectangle {
             color: "red"
             anchors.fill: parent
             GameGridElement {
                      id: grid
                       anchors.centerIn: parent
                       tileSize: 64
                       gap: 8
                       rows: 6
                       cols: 6
             }
         }


     }

     Button {
         text: "Click here"
         onClicked: function() {
            blk = blkComp.createObject(testElem);

             testElem.tweenPropertiesFrom({ x: 200, y: 200, height: 500, width: 550 }, 500, { easing: Easing.Linear }, function() { blk.launchAnimation() }, function() { blk.explode(); });

         }
     }
    }
    property var blk
    Component {
     id: blkComp
     Block {
      blockColor: "blue"
      width: 64
      height: 64

     }
    } */


    }
}
