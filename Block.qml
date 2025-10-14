import QtQuick
import QtQuick.Controls
import Blockwars24

GameSpriteSheetElement {
    id: blockRoot
    width: 64
    height: 64
    transformOrigin: Item.Center

    property var uuid: 0
    property int column: 0
    property int row: 0
    property int grid_id: 0
    property string block_color: "blue"
    property alias blockColor: blockRoot.block_color
    property bool isAttacking: false
    property bool isMoving: true
    property bool hasBeenLaunched: false
    property int block_health: 5
    property bool inAnimation: false
    property bool isBeingAttacked: false
    property int launchDirection: 1
    property bool dropBehaviorEnabled: true

    signal animationStart()
    signal animationDone()
    signal rowUpdated(int row)

    onRowChanged: rowUpdated(row)

    Behavior on y {
        id: verticalDropBehavior
        enabled: blockRoot.dropBehaviorEnabled
        SequentialAnimation {
            ScriptAction {
                script: {
                    blockRoot.inAnimation = true
                    blockRoot.animationStart()
                }
            }
            NumberAnimation {
                duration: 60 + ((6 - blockRoot.row) * 3)
            }
            ScriptAction {
                script: {
                    blockRoot.inAnimation = false
                    blockRoot.animationDone()
                }
            }
        }
    }

    Timer {
        id: launchCompleteReportTimer
        interval: 150 + (blockRoot.row * (15 * 6)) + (blockRoot.column * 15)
        repeat: false
        running: false
        onTriggered: {
            blockRoot._emitAppAction("blockLaunchCompleted", {
                                         "row": blockRoot.row,
                                         "column": blockRoot.column,
                                         "grid_id": blockRoot.grid_id,
                                         "damage": blockRoot.block_health,
                                         "color": blockRoot.block_color
                                     })
        }
    }

    BlockLaunchParticle {
        id: launchFX
        anchors.fill: parent
        visible: false
    }

    BlockExplodeParticle {
        id: explodeFX
        anchors.fill: parent
        visible: false
    }

    property int idleStartFrame: 0
    property int idleEndFrame: 0
    property int idleFps: 8

    property int launchStartFrame: 0
    property int launchEndFrame: 4
    property int launchFrameDuration: 100

    property int gainStartFrame: 0
    property int gainEndFrame: 4
    property int gainFrameDuration: 100

    property int explodeStartFrame: 0
    property int explodeEndFrame: 4
    property int explodeFrameDuration: 50
    property int explodeLoops: 3

    property int debrisStartFrame: 0
    property int debrisEndFrame: 19
    property int debrisFrameDuration: 50

    readonly property int baseFrameWidth: 64
    readonly property int baseFrameHeight: 64

    property bool _idleLoopEnabled: false
    property int _animSerial: 0
    property real _sizeBeforeAnimW: 0
    property real _sizeBeforeAnimH: 0

    function launch() {
        if (inAnimation)
            return
        isAttacking = true
        hasBeenLaunched = true
        launchCompleteReportTimer.restart()
        launchAnimation()
    }

    function launchAnimation() {
        stopIdle()
        const animId = ++_animSerial
        const duration = _durationForRange(launchStartFrame, launchEndFrame, launchFrameDuration)
        _prepareBaseSheet()
        hasBeenLaunched = true
        inAnimation = true
        animationStart()

        launchFX.visible = true
        _useParticleSystem(launchFX)
        launchFX.burstAll(1, 30)

        interpolate(
                    launchStartFrame, launchEndFrame, duration,
                    { "type": Easing.OutCubic },
                    function() {
                        if (_animSerial !== animId)
                            return
                    },
                    function() {
                        if (_animSerial !== animId)
                            return

                        launchCompleteReportTimer.stop()
                        _releaseParticleSystem(launchFX)

                        const global = blockRoot.getGlobalPos()
                        blockRoot._emitAppAction("particleBlockLaunchedGlobal", {
                                                     "grid_id": blockRoot.grid_id,
                                                     "x": global.x,
                                                     "y": global.y
                                                 })
                        blockRoot._emitAppAction("blockLaunchCompleted", {
                                                     "row": blockRoot.row,
                                                     "column": blockRoot.column,
                                                     "grid_id": blockRoot.grid_id,
                                                     "damage": blockRoot.block_health,
                                                     "color": blockRoot.block_color
                                                 })

                        blockRoot.y += blockRoot.launchDirection * 12 * blockRoot.height
                        blockRoot.z = 999

                        explode()
                    })
    }

    function gainHealthAnimation() {
        stopIdle()
        const animId = ++_animSerial
        const duration = _durationForRange(gainStartFrame, gainEndFrame, gainFrameDuration)
        _prepareBaseSheet()
        inAnimation = true
        animationStart()
        interpolate(
                    gainStartFrame, gainEndFrame, duration,
                    { "type": Easing.OutBack },
                    function() {
                        if (_animSerial !== animId)
                            return
                    },
                    function() {
                        if (_animSerial !== animId)
                            return
                        inAnimation = false
                        animationDone()
                        idleAnimation()
                    })
    }

    function explode() {
        stopIdle()
        const cfgId = ++_animSerial
        const duration = _durationForRange(explodeStartFrame, explodeEndFrame, explodeFrameDuration)
        _prepareExplosionSheet()
        _rememberSize()
        width = _sizeBeforeAnimW * 4.5
        height = _sizeBeforeAnimH * 4.5

        inAnimation = true
        animationStart()
        hasBeenLaunched = true

        explodeFX.visible = true
        _useParticleSystem(explodeFX)
        explodeFX.burstAll(1, 42, 24)

        let loopCount = 0
        function runLoop() {
            if (_animSerial !== cfgId)
                return
            interpolate(
                        explodeStartFrame, explodeEndFrame, duration,
                        "linear",
                        loopCount === 0 ? function() {} : undefined,
                        function() {
                            if (_animSerial !== cfgId)
                                return
                            loopCount += 1
                            if (loopCount < explodeLoops) {
                                runLoop()
                                return
                            }

                            const global = blockRoot.getGlobalPos()
                            blockRoot._emitAppAction("particleBlockKilledExplodeAtGlobal", {
                                                         "grid_id": blockRoot.grid_id,
                                                         "x": global.x,
                                                         "y": global.y
                                                     })

                            blockRoot.opacity = 0
                            _releaseParticleSystem(explodeFX)
                            _restoreSize()

                            _playDebrisSequence()
                        })
        }
        runLoop()
    }

    function hitAnimation(startFrame, endFrame, durationMs) {
        stopIdle()
        const animId = ++_animSerial
        _prepareBaseSheet()
        const start = startFrame !== undefined ? startFrame : gainEndFrame
        const end = endFrame !== undefined ? endFrame : gainStartFrame
        const duration = durationMs !== undefined ? durationMs : 220
        inAnimation = true
        animationStart()
        interpolate(
                    start, end, duration,
                    { "type": Easing.OutQuad },
                    function() {
                        if (_animSerial !== animId)
                            return
                    },
                    function() {
                        if (_animSerial !== animId)
                            return
                        inAnimation = false
                        animationDone()
                        idleAnimation()
                    })
    }

    function idleAnimation(fps) {
        const useFps = fps || idleFps
        _idleLoopEnabled = true
        const animId = ++_animSerial
        _prepareBaseSheet()
        const duration = _durationForRange(idleStartFrame, idleEndFrame, Math.max(1, Math.round(1000 / useFps)))
        function runLoop() {
            if (!_idleLoopEnabled || _animSerial !== animId)
                return
            interpolate(
                        idleStartFrame, idleEndFrame, duration,
                        "linear",
                        function() {
                            if (_animSerial !== animId)
                                return
                            inAnimation = false
                        },
                        function() {
                            if (_idleLoopEnabled && _animSerial === animId)
                                runLoop()
                        })
        }
        runLoop()
    }

    function stopIdle() {
        _idleLoopEnabled = false
        ++_animSerial
    }

    function playRangeFps(startFrame, endFrame, fps, loopCount) {
        stopIdle()
        const animId = ++_animSerial
        _prepareBaseSheet()
        const frames = Math.max(1, Math.abs(endFrame - startFrame) + 1)
        const useFps = Math.max(1, fps || 12)
        const duration = Math.round((frames / useFps) * 1000)
        let loopsLeft = Math.max(1, loopCount || 1)
        inAnimation = true
        animationStart()
        function runOnce() {
            if (_animSerial !== animId)
                return
            interpolate(
                        startFrame, endFrame, duration,
                        "linear",
                        function() {},
                        function() {
                            if (_animSerial !== animId)
                                return
                            loopsLeft -= 1
                            if (loopsLeft > 0)
                                runOnce()
                            else {
                                inAnimation = false
                                animationDone()
                                idleAnimation()
                            }
                        })
        }
        runOnce()
    }

    function _prepareBaseSheet() {
        const url = "qrc:///images/block_" + block_color + "_ss.png"
        loadSpriteSheet(url)
        setFrameWidth(baseFrameWidth)
        setFrameHeight(baseFrameHeight)
    }

    function _prepareExplosionSheet() {
        loadSpriteSheet("qrc:///images/block_die_ss.png")
        setFrameWidth(178)
        setFrameHeight(178)
    }

    function _prepareDebrisSheet() {
        loadSpriteSheet("qrc:///images/" + block_color + "_killed_ss.png")
        setFrameWidth(128)
        setFrameHeight(70)
    }

    function _durationForRange(startFrame, endFrame, frameDuration) {
        const frames = Math.max(1, Math.abs(endFrame - startFrame) + 1)
        return Math.max(1, frames * frameDuration)
    }

    function _rememberSize() {
        _sizeBeforeAnimW = width
        _sizeBeforeAnimH = height
    }

    function _restoreSize() {
        if (_sizeBeforeAnimW > 0 && _sizeBeforeAnimH > 0) {
            width = _sizeBeforeAnimW
            height = _sizeBeforeAnimH
        }
    }

    function _playDebrisSequence() {
        const animId = ++_animSerial
        _prepareDebrisSheet()
        _rememberSize()
        width = _sizeBeforeAnimW * 4.5
        height = _sizeBeforeAnimH * 4.5
        opacity = 1

        function run() {
            if (_animSerial !== animId)
                return
            interpolate(
                        debrisStartFrame, debrisEndFrame,
                        _durationForRange(debrisStartFrame, debrisEndFrame, debrisFrameDuration),
                        "linear",
                        function() {},
                        function() {
                            if (_animSerial !== animId)
                                return
                            _restoreSize()
                            inAnimation = false
                            animationDone()
                            isMoving = false
                            isAttacking = false

                            if (blockRoot.isBeingAttacked) {
                                blockRoot._emitAppAction("blockKilledFromFrontEnd", {
                                                             "grid_id": blockRoot.grid_id,
                                                             "uuid": blockRoot.uuid,
                                                             "row": blockRoot.row,
                                                             "column": blockRoot.column
                                                         })
                            }
                            blockRoot.destroy()
                        })
        }
        run()
    }

    function _emitAppAction(name, payload) {
        if (typeof AppActions === "undefined")
            return
        const fn = AppActions[name]
        if (typeof fn === "function")
            fn(payload)
    }

    function _useParticleSystem(ps) {
        detachParticleSystem()
        if (ps)
            attachParticleSystem(ps)
    }

    function _releaseParticleSystem(ps) {
        if (ps) {
            detachParticleSystem(ps)
            if (ps.visible !== undefined)
                ps.visible = false
        } else {
            detachParticleSystem()
        }
    }

    Component.onCompleted: {
        _prepareBaseSheet()
        idleAnimation()
    }

    onBlock_colorChanged: {
        _prepareBaseSheet()
        if (!_idleLoopEnabled && !inAnimation)
            setCurrentFrame(idleStartFrame)
    }
}
