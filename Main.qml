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




     }
     Component {
         id: explodeSystem
     BlockExplodeParticle {

     }
     }
     Button {
         text: "Click here"
         onClicked: function() {
            blk = blkComp.createObject(testElem);
             expl = explodeSystem.createObject(testElem, { visible: true })
            testElem.attachParticleSystem(expl);


             testElem.tweenPropertiesFrom({ x: 200, y: 200, height: 500, width: 550 }, 500, { easing: Easing.Linear }, function() { blk.launchAnimation(); expl.system.burst(50); }, function() { blk.explode(); });

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

