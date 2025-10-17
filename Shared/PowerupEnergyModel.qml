import QtQuick

QtObject {
    id: energyModel

    property real baseCost: 6
    property real hpScalar: 0.9
    property real blockScalar: 0.55
    property real supportModifier: 0.82
    property real assaultModifier: 1.18
    property real playerTargetBonus: 0.18
    property real heroTargetBonus: 0.12
    property real blockTargetBonus: 0.28
    property int minimumEnergy: 4
    property int maximumEnergy: 120

    function estimateEnergy(spec) {
        const draft = spec || {}
        const hp = Math.max(0, Number(draft.hp))
        const blockCount = Math.max(1, draft.blockCount ? Math.floor(Number(draft.blockCount)) : 1)
        const typeKey = draft.typeKey || "enemy"
        const targetKey = draft.targetKey || "players"
        const min = draft.minimum !== undefined ? Number(draft.minimum) : minimumEnergy
        const max = draft.maximum !== undefined ? Number(draft.maximum) : maximumEnergy

        const baseline = baseCost + (hp * hpScalar)
        const blockWeight = 1 + ((blockCount - 1) * blockScalar)

        let roleModifier = typeKey === "self" ? supportModifier : assaultModifier
        if (targetKey === "blocks")
            roleModifier += blockTargetBonus
        else if (targetKey === "heroes")
            roleModifier += heroTargetBonus
        else
            roleModifier += playerTargetBonus

        const energy = baseline * blockWeight * roleModifier
        return Math.round(_clamp(energy, min, max))
    }

    function _clamp(value, lower, upper) {
        const min = isNaN(lower) ? minimumEnergy : lower
        const max = isNaN(upper) ? maximumEnergy : upper
        if (isNaN(value))
            return Math.max(min, 0)
        return Math.max(min, Math.min(max, value))
    }
}
