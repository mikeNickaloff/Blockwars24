import QtQuick

QtObject {
    id: machine

    property Item target

    readonly property var statePalette: ({
        idle: {
            opacity: 1.0,
            scale: 1.0
        },
        matched: {
            opacity: 1.0,
            scale: 1.05
        },
        preparingLaunch: {
            opacity: 1.0,
            scale: 1.08
        },
        launching: {
            opacity: 0.9,
            scale: 0.96
        },
        airborne: {
            opacity: 0.75,
            scale: 0.85
        },
        colliding: {
            opacity: 0.65,
            scale: 1.1
        },
        exploding: {
            opacity: 0.0,
            scale: 1.25
        },
        filling: {
            opacity: 1.0,
            scale: 1.0
        },
        waiting: {
            opacity: 0.6,
            scale: 0.98
        },
        defeated: {
            opacity: 0.0,
            scale: 0.7
        }
    })

    function transitionTo(stateName) {
        if (!target)
            return
        const state = statePalette[stateName] || statePalette.idle
        target.blockState = stateName
        if (state.opacity !== undefined)
            target.opacity = state.opacity
        if (state.scale !== undefined)
            target.scale = state.scale
    }
}
