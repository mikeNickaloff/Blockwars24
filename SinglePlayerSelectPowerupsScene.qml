import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Blockwars24
import "."

GameScene {
    id: scene

    property var powerupRepository
    property var stackView
    property int slotCount: 4

    signal backRequested
    signal selectionConfirmed(var selection)

    PowerupDataStore {
        id: selectedPowerupStore
        table: "single_player_selected_powerups"
    }

    DefaultPowerupRepository {
        id: defaultRepository
    }

    ListModel {
        id: slotModel
    }

    ListModel {
        id: catalogModel
    }

    QtObject {
        id: slotLedger

        readonly property var _blankSignature: ({
                                                    typeKey: "",
                                                    typeLabel: "",
                                                    targetKey: "",
                                                    targetLabel: "",
                                                    colorKey: "",
                                                    colorLabel: "",
                                                    colorHex: "#334155",
                                                    hp: 0,
                                                    energy: 0,
                                                    blocks: [],
                                                    blockCount: 0
                                                })

        function composeSlot(index, source) {
            const normalized = clonePayload(source)
            return {
                slotIndex: index,
                payload: hasPowerup(normalized) ? normalized : clonePayload(_blankSignature),
                hasPowerup: hasPowerup(normalized)
            }
        }

        function clonePayload(payload) {
            const candidate = Object.assign({}, _blankSignature, payload || {})
            const sanitized = sanitizeBlocks(candidate.blocks)
            candidate.blocks = sanitized
            candidate.blockCount = sanitized.length
            return candidate
        }

        function sanitizeBlocks(blocks) {
            const source = Array.isArray(blocks) ? blocks : []
            const seen = {}
            const sanitized = []
            for (let i = 0; i < source.length; ++i) {
                const cell = source[i]
                if (!cell)
                    continue
                const row = Math.max(0, Math.min(5, Number(cell.row)))
                const column = Math.max(0, Math.min(5, Number(cell.column)))
                const key = row + ":" + column
                if (seen[key])
                    continue
                seen[key] = true
                sanitized.push({ row: row, column: column })
            }
            return sanitized
        }

        function hasPowerup(payload) {
            return Boolean(payload && payload.typeKey)
        }

        function serializePayload(payload) {
            const normalized = clonePayload(payload)
            return hasPowerup(normalized) ? normalized : {}
        }
    }

    anchors.fill: parent

    Component.onCompleted: {
        scene._synchronizeRepository()
        scene._initializeSlots()
    }
    onSlotCountChanged: scene._initializeSlots()

    Rectangle {
        anchors.fill: parent
        color: "#020617"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("Back")
                onClicked: scene.backRequested()
            }

            Label {
                text: qsTr("Select Powerups")
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: 28
                font.bold: true
                color: "#f8fafc"
            }
        }

        ListView {
            id: slotList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 16
            model: slotModel

            delegate: Rectangle {
                required property int slotIndex
                required property var payload
                required property bool hasPowerup

                width: slotList.width
                height: 132
                radius: 14
                color: "#111827"
                border.color: "#1e293b"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 10
                            color: (payload && payload.colorHex) ? payload.colorHex : "#334155"
                            border.color: "#1e293b"
                            border.width: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: qsTr("Slot %1").arg(slotIndex + 1)
                                font.pixelSize: 16
                                font.bold: true
                                color: "#e2e8f0"
                            }

                            Label {
                                text: scene._resolveTitle(payload)
                                color: "#cbd5f5"
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Label {
                                text: scene._resolveSubtitle(payload)
                                color: "#94a3b8"
                                font.pixelSize: 13
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Label {
                                visible: Boolean(payload && payload.targetKey === "blocks")
                                text: qsTr("Blocks targeted: %1").arg(payload && payload.blockCount ? payload.blockCount : 0)
                                color: "#64748b"
                                font.pixelSize: 12
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Label {
                                text: qsTr("Energy")
                                font.pixelSize: 12
                                color: "#f8fafc"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: scene._formatEnergy(payload ? payload.energy : 0)
                                font.pixelSize: 20
                                font.bold: true
                                color: "#38bdf8"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Button {
                            text: qsTr("Select Powerup")
                            Layout.preferredWidth: 160
                            onClicked: scene._openSelection(slotIndex)
                        }

                        Button {
                            text: qsTr("Clear")
                            Layout.preferredWidth: 120
                            enabled: hasPowerup
                            onClicked: scene._clearSlot(slotIndex)
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No slots configured.")
                color: "#64748b"
                visible: slotModel.count === 0
            }
        }

        Button {
            text: qsTr("Confirm Selection")
            Layout.alignment: Qt.AlignHCenter
            enabled: slotModel.count > 0
            onClicked: scene._confirmSelection()
        }
    }

    Popup {
        id: catalogModal
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        property int targetSlot: -1
        width: 420

        background: Rectangle {
            radius: 16
            color: "#0f172a"
            border.color: "#1e293b"
            border.width: 1
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Label {
                text: qsTr("Choose Powerup")
                font.pixelSize: 22
                font.bold: true
                color: "#f8fafc"
            }

            ListView {
                id: catalogList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(420, contentHeight)
                clip: true
                model: catalogModel
                spacing: 10

                delegate: ItemDelegate {
                    required property var payload
                    required property string label
                    required property string subtitle
                    required property string colorHex
                    required property string sourceLabel

                    width: catalogList.width
                    onClicked: {
                        catalogModal.close()
                        scene._applySelection(catalogModal.targetSlot, payload)
                    }

                    background: Rectangle {
                        radius: 12
                        color: hovered ? "#14213b" : "#0f172a"
                        border.color: "#1e293b"
                        border.width: 1
                    }

                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Rectangle {
                            width: 48
                            height: 48
                            radius: 10
                            color: colorHex
                            border.color: "#1e293b"
                            border.width: 1
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Label {
                                text: label
                                font.pixelSize: 16
                                font.bold: true
                                color: "#e2e8f0"
                                wrapMode: Text.WordWrap
                            }
                            Label {
                                text: subtitle
                                font.pixelSize: 13
                                color: "#94a3b8"
                                wrapMode: Text.WordWrap
                            }
                            Label {
                                text: sourceLabel
                                font.pixelSize: 11
                                color: "#64748b"
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Label {
                                text: qsTr("Energy")
                                font.pixelSize: 11
                                color: "#f8fafc"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: scene._formatEnergy(payload ? payload.energy : 0)
                                font.pixelSize: 16
                                font.bold: true
                                color: "#38bdf8"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("No powerups available.")
                    color: "#64748b"
                    visible: catalogModel.count === 0
                }
            }

            Button {
                text: qsTr("Close")
                Layout.alignment: Qt.AlignHCenter
                onClicked: catalogModal.close()
            }
        }
    }

    function _initializeSlots() {
        const persisted = selectedPowerupStore ? selectedPowerupStore.getPowerupData() : []
        const count = slotCount > 0 ? slotCount : 0
        slotModel.clear()
        for (let i = 0; i < count; ++i) {
            const entry = (persisted && persisted.length > i) ? persisted[i] : null
            slotModel.append(slotLedger.composeSlot(i, entry))
        }
    }

    function _synchronizeRepository() {
        if (powerupRepository && powerupRepository.reload)
            powerupRepository.reload()
    }

    function _refreshCatalog() {
        catalogModel.clear()
        const customEntries = powerupRepository && powerupRepository.allPowerups ? powerupRepository.allPowerups() : []
        for (let i = 0; i < customEntries.length; ++i) {
            const entry = powerupRepository && powerupRepository.cloneEntry ? powerupRepository.cloneEntry(customEntries[i]) : _clonePayload(customEntries[i])
            catalogModel.append({
                payload: entry,
                label: _resolveTitle(entry),
                subtitle: _resolveSubtitle(entry),
                colorHex: entry && entry.colorHex ? entry.colorHex : "#334155",
                sourceLabel: qsTr("Custom Powerup")
            })
        }

        const defaultEntries = defaultRepository ? defaultRepository.allPowerups() : []
        for (let j = 0; j < defaultEntries.length; ++j) {
            const entry = _clonePayload(defaultEntries[j])
            catalogModel.append({
                payload: entry,
                label: _resolveTitle(entry),
                subtitle: _resolveSubtitle(entry),
                colorHex: entry && entry.colorHex ? entry.colorHex : "#334155",
                sourceLabel: qsTr("Default Catalog")
            })
        }
    }

    function _openSelection(slotIndex) {
        if (slotIndex < 0)
            return
        catalogModal.targetSlot = slotIndex
        _refreshCatalog()
        catalogModal.open()
    }

    function _applySelection(slotIndex, payload) {
        if (slotIndex < 0 || slotIndex >= slotModel.count)
            return
        const slotEntry = slotLedger.composeSlot(slotIndex, payload)
        slotModel.set(slotIndex, slotEntry)
        _persistSelection()
    }

    function _clearSlot(slotIndex) {
        if (slotIndex < 0 || slotIndex >= slotModel.count)
            return
        slotModel.set(slotIndex, slotLedger.composeSlot(slotIndex, null))
        _persistSelection()
    }

    function _persistSelection() {
        if (!selectedPowerupStore)
            return
        const snapshot = []
        for (let i = 0; i < slotModel.count; ++i) {
            const entry = slotModel.get(i)
            snapshot.push(slotLedger.serializePayload(entry ? entry.payload : null))
        }
        selectedPowerupStore.setPowerupData(snapshot)
    }

    function _confirmSelection() {
        const chosen = []
        for (let i = 0; i < slotModel.count; ++i) {
            const entry = slotModel.get(i)
            if (entry && slotLedger.hasPowerup(entry.payload))
                chosen.push(_clonePayload(entry.payload))
        }
        scene.selectionConfirmed(chosen)
    }

    function _resolveTitle(payload) {
        if (!payload || !payload.typeLabel)
            return qsTr("No powerup selected")
        const type = payload.typeLabel
        const target = payload && payload.targetLabel ? payload.targetLabel : qsTr("Target")
        return type + qsTr(" vs ") + target
    }

    function _resolveSubtitle(payload) {
        if (!payload)
            return qsTr("Choose a powerup to fill this slot.")
        const color = payload.colorLabel || qsTr("No Color")
        const hp = payload.hp !== undefined ? payload.hp : 0
        return qsTr("Color: %1 — HP: %2").arg(color).arg(hp)
    }

    function _formatEnergy(value) {
        if (value === undefined || value === null)
            return "0"
        const number = Number(value)
        if (isNaN(number))
            return "0"
        const rounded = Math.round(number * 10) / 10
        return Math.abs(rounded - Math.round(rounded)) < 0.0001 ? String(Math.round(rounded)) : rounded.toFixed(1)
    }

    function _clonePayload(payload) {
        return slotLedger.clonePayload(payload)
    }
    onPowerupRepositoryChanged: scene._synchronizeRepository()

    Connections {
        target: powerupRepository
        function onPowerupsChanged() {
            if (catalogModal.visible)
                scene._refreshCatalog()
        }
    }
}
