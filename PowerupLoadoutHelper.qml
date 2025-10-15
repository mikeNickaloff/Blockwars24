import QtQuick

QtObject {
    id: root

    function deepCopy(value) {
        return JSON.parse(JSON.stringify(value || null))
    }

    function colorHexForKey(colorKey) {
        switch ((colorKey || "").toString().toLowerCase()) {
        case "red": return "#ef4444"
        case "green": return "#22c55e"
        case "blue": return "#3b82f6"
        case "yellow": return "#eab308"
        default: return "#94a3b8"
        }
    }

    function typeLabelForKey(typeKey) {
        switch ((typeKey || "").toString().toLowerCase()) {
        case "self": return qsTr("Self")
        case "ally": return qsTr("Self")
        default: return qsTr("Enemy")
        }
    }

    function targetLabelForKey(targetKey) {
        switch ((targetKey || "").toString().toLowerCase()) {
        case "heroes": return qsTr("Heroes")
        case "player": return qsTr("Player")
        case "blocks":
        default:
            return qsTr("Blocks")
        }
    }

    function colorLabelForKey(colorKey) {
        switch ((colorKey || "").toString().toLowerCase()) {
        case "red": return qsTr("Red")
        case "green": return qsTr("Green")
        case "blue": return qsTr("Blue")
        case "yellow": return qsTr("Yellow")
        default: return qsTr("Neutral")
        }
    }

    function computeEnergy(powerup) {
        if (!powerup)
            return 0
        var targetCount = 1
        if (powerup.targetKey === "blocks")
            targetCount = powerup.blocks ? powerup.blocks.length : 0
        var hpValue = Math.max(0, Number(powerup.hp) || 0)
        return Math.max(0, Math.round(targetCount * hpValue * 0.5))
    }

    function normalizeBlocks(blocks) {
        if (!blocks || !blocks.length)
            return []
        var normalized = []
        for (var i = 0; i < blocks.length; ++i) {
            var block = blocks[i]
            if (!block)
                continue
            var row = Math.max(0, Math.floor(Number(block.row) || 0))
            var column = Math.max(0, Math.floor(Number(block.column) || 0))
            normalized.push({ row: row, column: column })
        }
        return normalized
    }

    function effectSummary(powerup) {
        if (!powerup)
            return ""
        var hpValue = Math.max(0, Number(powerup.hp) || 0)
        var action = powerup.typeKey === "self" ? qsTr("Restores") : qsTr("Deals")
        if (powerup.targetKey === "blocks") {
            var blockCount = powerup.blockCount
            if (blockCount === 0)
                return qsTr("%1 %2 HP to selected blocks.").arg(action).arg(hpValue)
            return qsTr("%1 %2 HP to %3 block%4.")
                    .arg(action)
                    .arg(hpValue)
                    .arg(blockCount)
                    .arg(blockCount === 1 ? "" : "s")
        }
        if (powerup.targetKey === "heroes") {
            return powerup.typeKey === "self"
                    ? qsTr("%1 %2 HP to allied heroes.").arg(action).arg(hpValue)
                    : qsTr("%1 %2 HP to enemy heroes.").arg(action).arg(hpValue)
        }
        return powerup.typeKey === "self"
                ? qsTr("%1 %2 HP to your health.").arg(action).arg(hpValue)
                : qsTr("%1 %2 HP to enemy health.").arg(action).arg(hpValue)
    }

    function detailDescription(powerup) {
        if (!powerup)
            return ""
        var summary = powerup.effectSummary || effectSummary(powerup)
        var energy = Math.max(0, Number(powerup.energy) || 0)
        if (energy <= 0)
            return summary
        return summary + " " + qsTr("Requires %1 energy.").arg(energy)
    }

    function defaultName(powerup) {
        if (!powerup)
            return qsTr("Powerup")
        var color = powerup.colorLabel || colorLabelForKey(powerup.colorKey)
        switch (powerup.targetKey) {
        case "blocks":
            return powerup.typeKey === "self"
                    ? qsTr("%1 Bastion").arg(color)
                    : qsTr("%1 Barrage").arg(color)
        case "heroes":
            return powerup.typeKey === "self"
                    ? qsTr("%1 Rally").arg(color)
                    : qsTr("%1 Ambush").arg(color)
        case "player":
        default:
            return powerup.typeKey === "self"
                    ? qsTr("%1 Vitality Surge").arg(color)
                    : qsTr("%1 Soul Drain").arg(color)
        }
    }

    function buildTags(powerup) {
        var tags = []
        if (!powerup)
            return tags
        tags.push(powerup.typeLabel)
        tags.push(powerup.targetLabel)
        tags.push(qsTr("%1 HP").arg(powerup.hp))
        if (powerup.targetKey === "blocks" && powerup.blockCount > 0)
            tags.push(qsTr("%1 Cells").arg(powerup.blockCount))
        if (powerup.energy > 0)
            tags.push(qsTr("%1 Energy").arg(powerup.energy))
        return tags
    }

    function normalizePowerup(raw) {
        if (!raw)
            return null
        var normalized = deepCopy(raw)
        normalized.typeKey = (normalized.typeKey || "enemy").toString().toLowerCase()
        normalized.targetKey = (normalized.targetKey || "blocks").toString().toLowerCase()
        normalized.colorKey = (normalized.colorKey || "red").toString().toLowerCase()
        normalized.typeLabel = normalized.typeLabel || typeLabelForKey(normalized.typeKey)
        normalized.targetLabel = normalized.targetLabel || targetLabelForKey(normalized.targetKey)
        normalized.colorLabel = normalized.colorLabel || colorLabelForKey(normalized.colorKey)
        normalized.colorHex = normalized.colorHex || colorHexForKey(normalized.colorKey)
        normalized.hp = Math.max(0, Math.round(Number(normalized.hp) || 0))
        normalized.blocks = normalizeBlocks(normalized.blocks)
        normalized.blockCount = normalized.blocks.length
        normalized.energy = computeEnergy(normalized)
        normalized.effectSummary = effectSummary(normalized)
        normalized.detailDescription = detailDescription(normalized)
        normalized.displayName = normalized.displayName || defaultName(normalized)
        return normalized
    }

    function buildOption(rawPowerup, metadata) {
        var normalized = normalizePowerup(rawPowerup)
        if (!normalized)
            return null
        metadata = metadata || {}
        var name = metadata.name || normalized.displayName
        var description = metadata.description || normalized.detailDescription
        var optionId = metadata.id !== undefined ? metadata.id
                      : metadata.powerupId !== undefined ? metadata.powerupId
                      : (normalized.powerupId !== undefined ? normalized.powerupId : name)
        var source = metadata.source || "default"
        var tags = metadata.tags ? metadata.tags.slice() : buildTags(normalized)
        var powerupId = metadata.powerupId !== undefined ? metadata.powerupId
                        : (normalized.powerupId !== undefined ? normalized.powerupId : null)
        var option = {
            id: optionId,
            source: source,
            name: name,
            description: description,
            powerupId: powerupId,
            powerup: deepCopy(normalized),
            tags: tags
        }
        option.powerup.name = name
        option.powerup.description = description
        option.powerup.tags = tags.slice()
        return option
    }

    function createLoadoutEntry(source, slotIndex) {
        if (!source)
            return null
        var metadata = {
            id: source.id,
            source: source.source,
            name: source.name,
            description: source.description,
            powerupId: source.powerupId,
            tags: source.tags
        }
        var basePowerup = source.powerup ? source.powerup : source
        var option = buildOption(basePowerup, metadata)
        if (!option)
            return null
        var sanitizedPowerup = deepCopy(option.powerup)
        sanitizedPowerup.tags = option.tags.slice()
        return {
            slotIndex: slotIndex,
            id: option.id,
            source: option.source,
            name: option.name,
            description: option.description,
            typeLabel: option.powerup.typeLabel,
            targetLabel: option.powerup.targetLabel,
            colorLabel: option.powerup.colorLabel,
            colorHex: option.powerup.colorHex,
            hp: option.powerup.hp,
            blockCount: option.powerup.blockCount,
            energy: option.powerup.energy,
            effectSummary: option.powerup.effectSummary,
            detailDescription: option.powerup.detailDescription,
            tags: option.tags.slice(),
            powerupId: option.powerupId,
            powerup: sanitizedPowerup
        }
    }

    function normalizeSelection(selection, slotCount) {
        var count = Math.max(0, slotCount)
        var normalized = []
        for (var i = 0; i < count; ++i) {
            var entry = selection && selection.length > i ? selection[i] : null
            normalized.push(createLoadoutEntry(entry, i))
        }
        return normalized
    }
}
