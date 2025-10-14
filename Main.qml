import QtQuick
import Blockwars24 1.0
import QtQuick.Controls
import "."
Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    Item {
        anchors.fill: parent

     AbstractGameElement {
         id: testElem
         width: 180
         height: 180
         x: 100
         y: 100

         GameGridElement {
           anchors.fill: parent
           id: grid
         }


     }
     Component {
         id: explodeSystem
     BlockExplodeParticle {

     }
     }
     Button {
         text: "Click here"
         onClicked: function() {
             for (var i=0; i<6; i++) {
            blk = blkComp.createObject(testElem);
             grid.addBlockToColumn(blk, i)
             blk = blkComp.createObject(testElem);
             grid.addBlockToColumn(blk, i)
             blk = blkComp.createObject(testElem);
             grid.addBlockToColumn(blk, i)
             blk = blkComp.createObject(testElem);
             grid.addBlockToColumn(blk, i)
             blk = blkComp.createObject(testElem);
             grid.addBlockToColumn(blk, i)
                 blk = blkComp.createObject(testElem);
                 grid.addBlockToColumn(blk, i)
             }



         }
     }
    }
    property var blk
    property var expl
    Component {
     id: blkComp
     Block {
      blockColor: "blue"
      width: 64
      height: 64

     }
    }


    }

