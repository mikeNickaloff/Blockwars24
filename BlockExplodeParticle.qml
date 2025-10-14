// BlockExplodeParticles.qml — Qt 6 style ParticleSystem for block explosion
import QtQuick
import QtQuick.Particles

Item {
    id: root
    anchors.fill: parent
    visible: false   // shown when used
    // tweakable sources (replace with your assets)
    property url emberSource: "qrc:///images/particles/ember_mid.png"
    property url smokeSource: "qrc:///images/particles/rocketbacklit.png"
    property url flashSource: "qrc:///images/particles/particleA.png"
    property alias system: particleSystem
    property alias boomEmitterItem: boomEmitter
    property alias emberEmitterItem: emberEmitter
    property alias smokeEmitterItem: smokeEmitter
    ParticleSystem { id: particleSystem }

    // Painters
    ImageParticle {
        id: emberPainter
        system: particleSystem
        source: emberSource
        groups: ["embers"]
        entryEffect: ImageParticle.None

        colorVariation: 0.2
    }
    ImageParticle {
        id: smokePainter
        system: particleSystem
        source: smokeSource
        groups: ["smoke"]
        entryEffect: ImageParticle.None

        color: "white"
        colorVariation: 0.1
        alpha: 0.6
    }
    ImageParticle {
        id: boomPainter
        system: particleSystem
        source: flashSource
        groups: ["boom"]
        entryEffect: ImageParticle.None

        color: "white"
        alpha: 0.9
    }

    // Emitters
    Emitter {
        id: boomEmitter
        system: particleSystem
        group: "boom"
        emitRate: 0
        lifeSpan: 120
        lifeSpanVariation: 40
        size: 96
        sizeVariation: 24
        velocity: AngleDirection { angle: 0; magnitude: 0 }
        // centered
        anchors.centerIn: parent
    }

    Emitter {
        id: emberEmitter
        system: particleSystem
        group: "embers"
        emitRate: 0
        lifeSpan: 900
        lifeSpanVariation: 300
        size: 8
        sizeVariation: 6
        endSize: 2
        velocity: CumulativeDirection {
            AngleDirection { angle: 0; angleVariation: 360; magnitude: 120; magnitudeVariation: 160 }
        }
        acceleration: AngleDirection { angle: 90; magnitude: 120 } // gravity-ish
        shape: EllipseShape { fill: true; }
        anchors.centerIn: parent
    }

    Emitter {
        id: smokeEmitter
        system: particleSystem
        group: "smoke"
        emitRate: 0
        lifeSpan: 1400
        lifeSpanVariation: 300
        size: 24
        sizeVariation: 12
        endSize: 64
        velocity: AngleDirection { angle: -90; magnitude: 40; magnitudeVariation: 40 }
        acceleration: AngleDirection { angle: -90; magnitude: 10 }
        anchors.centerIn: parent
    }

    // Gravity (global)
    Gravity {
        system: particleSystem
        angle: 90
        magnitude: 160
    }

    function burstAll(boomCount, emberCount, smokeCount) {
        if (boomCount === undefined || boomCount > 0)
            boomEmitter.pulse(boomCount !== undefined ? boomCount : 1)
        if (emberCount === undefined || emberCount > 0)
            emberEmitter.pulse(emberCount !== undefined ? emberCount : 48)
        if (smokeCount === undefined || smokeCount > 0)
            smokeEmitter.pulse(smokeCount !== undefined ? smokeCount : 24)
    }
}
