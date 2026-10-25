/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Editable combo box: pick one of the preset symbols or type your own.
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.ComboBox {
    id: combo

    property string value: ""
    property var presets: []
    signal edited(string text)

    editable: true
    model: presets
    implicitWidth: Kirigami.Units.gridUnit * 9

    QQC2.ToolTip.text: i18n("Pick a preset or type your own symbol")
    QQC2.ToolTip.visible: hovered
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

    function sync() {
        // while the user types, the text already equals the value: do not touch it (keeps the cursor)
        if (contentItem && contentItem.activeFocus && editText === value) return;
        currentIndex = presets.indexOf(value);
        if (editText !== value) editText = value;
    }

    onValueChanged: sync()
    onPresetsChanged: sync()
    Component.onCompleted: sync()

    onActivated: index => combo.edited(presets[index])
    onAccepted: combo.edited(editText)

    // live update while typing so "Apply" becomes available immediately
    Connections {
        target: combo.contentItem
        ignoreUnknownSignals: true
        function onTextEdited() { combo.edited(combo.editText) }
    }
}
