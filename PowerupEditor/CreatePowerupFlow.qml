import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Shared"
import "./"

Item {
    id: root

    required property PowerupRepository repository
    property string mode: "create"
    property var existingEntry: null
    signal finished()

    property var draft: ({
        typeKey: "enemy",
        typeLabel: qsTr("Enemy"),
        targetKey: "blocks",
        targetLabel: qsTr("Blocks"),
        colorKey: "red",
        colorLabel: qsTr("Red"),
        colorHex: "#ef4444",
        blocks: [],
        hp: 10
    })

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0f172a"
    }

    StackView {
        id: flowStack
        anchors.fill: parent
        anchors.margins: 32
    }

    Component.onCompleted: {
        const initialDraft = root.mode === "edit" && root.existingEntry ? root._cloneDraft(root.existingEntry) : root._cloneDraft(draft)
        draft = initialDraft
        flowStack.push(overviewComponent, {
                             flow: root,
                             stackView: flowStack,
                             draft: root._cloneDraft(initialDraft)
                         })
    }

    Component {
        id: overviewComponent
        CreatePowerupOverviewStep {}
    }

    Component {
        id: blockComponent
        CreatePowerupBlockStep {}
    }

    function proceedToBlockStep(updatedDraft) {
        draft = _cloneDraft(updatedDraft)
        flowStack.push(blockComponent, {
                             flow: root,
                             stackView: flowStack,
                             draft: _cloneDraft(draft)
                         })
    }

    function saveAndExit(finalDraft) {
        draft = _cloneDraft(finalDraft)
        if (repository) {
            if (mode === "edit" && draft.id !== undefined && draft.id >= 0)
                repository.updatePowerup(draft.id, draft)
            else
                repository.addPowerup(draft)
        }
        finished()
    }

    function _cloneDraft(source) {
        const reference = source || {}
        const clone = {
            id: reference.id !== undefined ? reference.id : -1,
            typeKey: reference.typeKey,
            typeLabel: reference.typeLabel,
            targetKey: reference.targetKey,
            targetLabel: reference.targetLabel,
            colorKey: reference.colorKey,
            colorLabel: reference.colorLabel,
            colorHex: reference.colorHex,
            hp: Math.max(1, Math.round(reference.hp || 1)),
            blocks: []
        }
        if (reference.blocks && reference.blocks.length) {
            for (let i = 0; i < reference.blocks.length; ++i) {
                const cell = reference.blocks[i]
                if (!cell)
                    continue
                clone.blocks.push({ row: cell.row, column: cell.column })
            }
        }
        return clone
    }
}
