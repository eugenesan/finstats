/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Combo box of fetch presets. Shows "Custom" when the current settings match no preset.
 * presets: [{text, <field>: value, ...}]   current: {<field>: value, ...}
 */
import QtQuick
import QtQuick.Controls as QQC2

QQC2.ComboBox {
    id: combo

    property var presets: []
    property var current: ({})
    signal presetChosen(var preset)

    textRole: "text"
    model: presets.concat([{ text: i18n("Custom") }])

    function matches(preset) {
        for (var k in preset) {
            if (k !== "text" && preset[k] !== current[k]) return false;
        }
        return true;
    }

    function sync() {
        for (var i = 0; i < presets.length; i++) {
            if (matches(presets[i])) { currentIndex = i; return; }
        }
        currentIndex = presets.length;
    }

    onCurrentChanged: sync()
    onPresetsChanged: sync()
    Component.onCompleted: sync()

    onActivated: index => { if (index < presets.length) combo.presetChosen(presets[index]) }
}
