import QtQuick
import QtQml.Models

Item {
    id: store

    property alias createdPowerupsModel: createdModel

    property int _nextId: 0

    ListModel {
        id: createdModel
    }

    function addPowerup(payload) {
        const entry = Object.assign({}, payload || {})
        entry.id = store._nextId
        store._nextId += 1
        createdModel.append(entry)
        return entry.id
    }

    function updatePowerup(identifier, payload) {
        const index = store._indexOfId(identifier)
        if (index < 0)
            return false
        const entry = Object.assign({ id: identifier }, payload || {})
        createdModel.set(index, entry)
        return true
    }

    function getPowerup(identifier) {
        const index = store._indexOfId(identifier)
        if (index < 0)
            return null
        return createdModel.get(index)
    }

    function allPowerups() {
        const values = []
        for (let i = 0; i < createdModel.count; ++i)
            values.push(createdModel.get(i))
        return values
    }

    function _indexOfId(identifier) {
        const count = createdModel.count
        for (let i = 0; i < count; ++i) {
            const candidate = createdModel.get(i)
            if (candidate && candidate.id === identifier)
                return i
        }
        return -1
    }
}
