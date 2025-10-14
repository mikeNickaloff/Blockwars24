// Block.qml — minimal animated-sprite wrapper using GameSpriteSheetElement
import QtQuick
import QtQuick.Controls
import Blockwars24
import "." // <-- whatever module exposes GameSpriteSheetElement




GameSpriteSheetElement {
    id: blockRoot

    /* ---------- configurable basics ---------- */
    // sprite sheet path pattern by color (edit to match your files)
    property string block_color: "blue"
    // keep a second name if other code uses camelCase
    property alias blockColor: blockRoot.block_color
    property var blockRow
    property var blockColumn

    // each frame’s size in the sheet
    property int frameW: 64
    property int frameH: 64

    // “busy” flag for non-idle sequences
    property bool inAnimation: false
    // compatibility if other code uses this name
    property bool isAnimation: false
    onInAnimationChanged: isAnimation = inAnimation




    // --- particle instances as children, so they render in our local coords ---
    BlockLaunchParticle { id: launchFX; anchors.fill: parent; visible: false }
    BlockExplodeParticle { id: explodeFX; anchors.fill: parent; visible: false }

    // Attach helper (no-op if already attached)
    function _attach(ps) {
        // attach the wrapper Item; C++ scans children for emitters
        attachParticleSystem(ps)
    }
    function _detach(ps) {
        detachParticleSystem(ps)
    }

    // Example: launch sequence — attach, burst, then hide/detach later
    function launchAnimation() {
        // sprite anim (your frames):
        _ensureSheet()
        interpolate(launchStartFrame, launchEndFrame, 500, { type: Easing.OutCubic },
            () => {
                inAnimation = true
                launchFX.visible = true
                _attach(launchFX)
                // burst once: our C++ will find the first emitter and burst it
    //            burstParticleSystem(30)
            },
            () => {
                inAnimation = false
                // give particles time to fade, then detach/hide
                Qt.callLater(() => {
                    _detach(launchFX)
                    launchFX.visible = false
                })
                idleAnimation()
            }
        )
    }

    // Example: explode — attach, burst all, then destroy self
    function explode() {
        inAnimation = true
        explodeFX.visible = true
        _attach(explodeFX)
     //  burstParticleSystem(60) // booms/smoke/embers

        tweenPropertiesTo({ opacity: 0 }, 150, "outquad",
            () => {},
            () => {
                inAnimation = false
                Qt.callLater(() => { _detach(explodeFX); })
                blockRoot.destroy()
            })
    }


    /* ---------- animation frame sets (override per art) ---------- */
    // idle loops 0..3 by default
    property int idleStartFrame: 0
    property int idleEndFrame: 3
    // health/powerup burst 4..9
    property int gainStartFrame: 4
    property int gainEndFrame: 9
    // launch 10..17
    property int launchStartFrame: 10
    property int launchEndFrame: 17

    /* ---------- internal ---------- */
    // used to keep idle looping
    property bool _idleLoopEnabled: false

    // helper: load the sheet for current color + set frame dims
    function _ensureSheet() {
        // qrc path example: qrc:/images/block_BLUE_ss.png    (adjust pattern)
        const url = "qrc:///images/block_" + block_color + "_ss.png"
        loadSpriteSheet(url)
        setFrameWidth(frameW)
        setFrameHeight(frameH)
    }

    // helper: loop an interpolate() by re-calling it at the end
    function _loopFrames(startFrame, endFrame, durationMs, easing) {
        _ensureSheet()
        interpolate(
            startFrame, endFrame, durationMs,
            easing !== undefined ? easing : "linear",
            function onStart() { /* no-op */ },
            function onEnd() {
                if (_idleLoopEnabled) _loopFrames(startFrame, endFrame, durationMs, easing)
            }
        )
    }

    /* ---------- public API: one-liners ---------- */

    // idle forever (soft loop). fps ~= frames / (durationMs/1000)
    function idleAnimation(fps) {
        _idleLoopEnabled = true
        const frames = Math.max(1, (idleEndFrame - idleStartFrame + 1))
        const useFps = Math.max(1, fps || 8)
        const duration = Math.round((frames / useFps) * 1000)
        // gentle breathing / ambient: linear works fine here
        _loopFrames(idleStartFrame, idleEndFrame, duration, "linear")
    }

    function stopIdle() {
        _idleLoopEnabled = false
    }

    // “power up / gain health” burst; when done, go back to idle
    function gainHealthAnimation() {
        _idleLoopEnabled = false
        _ensureSheet()
        interpolate(
            gainStartFrame, gainEndFrame, 420,
            { type: Easing.OutBack }, // nice pop for pickups
            function onStart() { inAnimation = true },
            function onEnd() { inAnimation = false; idleAnimation() }
        )
    }

    // simple launch sequence; tweak easing/duration to taste
   /* function launchAnimation() {
        _idleLoopEnabled = false
        _ensureSheet()
        interpolate(
            launchStartFrame, launchEndFrame, 500,
            { type: Easing.OutCubic },
            function onStart() { inAnimation = true },
            function onEnd()   { inAnimation = false; idleAnimation() }
        )
    } */

    // quick “hit” flicker using frames you choose; defaults to gain range reversed
    function hitAnimation(startFrame, endFrame, durationMs) {
        _idleLoopEnabled = false
        _ensureSheet()
        const s = (startFrame !== undefined) ? startFrame : gainEndFrame
        const e = (endFrame   !== undefined) ? endFrame   : gainStartFrame
        const d = (durationMs !== undefined) ? durationMs : 220
        interpolate(
            s, e, d,
            { type: Easing.OutQuad },
            function onStart() { inAnimation = true },
            function onEnd()   { inAnimation = false; idleAnimation() }
        )
    }

    /* ---------- optional niceties ---------- */

    // rapid one-off frame range with an explicit fps (loops N times if loopCount > 1)
    // This uses repeated interpolate() calls so you don’t need extra C++.
    function playRangeFps(startFrame, endFrame, fps, loopCount) {
        _idleLoopEnabled = false
        _ensureSheet()
        const frames = Math.max(1, (endFrame - startFrame + 1))
        const useFps = Math.max(1, fps || 12)
        const duration = Math.round((frames / useFps) * 1000)

        let loopsLeft = Math.max(1, loopCount || 1)
        function runOnce() {
            interpolate(
                startFrame, endFrame, duration, "linear",
                function onStart() { inAnimation = true },
                function onEnd()   {
                    loopsLeft--
                    if (loopsLeft > 0) runOnce()
                    else { inAnimation = false; idleAnimation() }
                }
            )
        }
        runOnce()
    }

    /* ---------- defaults ---------- */
    Component.onCompleted: {
        // start idling immediately
        idleAnimation(8)
    }
}
