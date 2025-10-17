import QtQuick

QtObject {
    id: model

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

    function estimateEnergy(specification) {
        const spec = specification || {}
        const hp = Math.max(0, Number(spec.hp))
        const rawBlockCount = Number(spec.blockCount)
        const blockCount = isNaN(rawBlockCount) ? 1 : Math.max(1, Math.floor(rawBlockCount))
        const typeKey = spec.typeKey || "enemy"
        const targetKey = spec.targetKey || "players"
        const minimum = spec.minimum !== undefined ? Number(spec.minimum) : minimumEnergy
        const maximum = spec.maximum !== undefined ? Number(spec.maximum) : maximumEnergy

        const baseline = baseCost + (hp * hpScalar)
        const blockWeight = 1 + ((blockCount - 1) * blockScalar)

        let roleModifier = typeKey === "self" ? supportModifier : assaultModifier
        if (targetKey === "blocks")
            roleModifier += blockTargetBonus
        else if (targetKey === "heroes")
            roleModifier += heroTargetBonus
        else
            roleModifier += playerTargetBonus

        const energy = baseline * roleModifier * blockWeight
        return Math.round(_clamp(energy, minimum, maximum))
    }

    function _clamp(value, minimum, maximum) {
        const lower = isNaN(minimum) ? minimumEnergy : minimum
        const upper = isNaN(maximum) ? maximumEnergy : maximum
        if (isNaN(value))
            return Math.max(lower, 0)
        return Math.max(lower, Math.min(upper, value))
    }
}
