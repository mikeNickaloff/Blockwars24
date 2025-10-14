import QtQuick
import QtQuick.Particles

Item {
    id: root
    anchors.fill: parent
    visible: false
    property url sparkSource: "qrc:///images/particles/spark.png"
    property url flashSource: "qrc:///images/particles/flash.png"

    ParticleSystem { id: particleSystem }

    ImageParticle {
        id: sparkPainter
        system: particleSystem
        source: sparkSource
        groups: ["sparks"]
        entryEffect: ImageParticle.None

        alpha: 0.9
        colorVariation: 0.2
    }
    ImageParticle {
        id: flashPainter
        system: particleSystem
        source: flashSource
        groups: ["flash"]
        entryEffect: ImageParticle.None

        alpha: 0.9
    }

    Emitter {
        id: flashEmitter
        system: particleSystem
        group: "flash"
        emitRate: 0
        lifeSpan: 160
        size: 72
        sizeVariation: 24
        velocity: AngleDirection { angle: 0; magnitude: 0 }
        anchors.centerIn: parent
    }

    Emitter {
        id: sparkEmitter
        system: particleSystem
        group: "sparks"
        emitRate: 0
        lifeSpan: 600
        lifeSpanVariation: 200
        size: 8
        sizeVariation: 6
        endSize: 2
        velocity: CumulativeDirection {
            AngleDirection { angle: 270; angleVariation: 40; magnitude: 220; magnitudeVariation: 120 }
        }
        acceleration: AngleDirection { angle: 90; magnitude: 140 } // gravity
        shape: RectangleShape { fill: true; }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    Gravity {
        system: particleSystem
        angle: 90
        magnitude: 160
    }
}
