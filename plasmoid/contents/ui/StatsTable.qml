/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Bordered table used by the tooltip and the popup.
 * cells: [{text, bold, shade, error, span}] filled left-to-right, wrapping after `columns`.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Rectangle {
    id: frame

    property var cells: []
    property int columns: 4
    readonly property color lineColor: Qt.alpha(Kirigami.Theme.textColor, 0.4)
    readonly property var laid: layoutCells(cells, columns)

    function layoutCells(list, cols) {
        var out = [], col = 0, row = 0;
        list.forEach(function (c) {
            var span = Math.min(c.span || 1, cols);
            if (col + span > cols) { col = 0; row++; }
            out.push({ text: c.text, bold: !!c.bold, shade: !!c.shade, error: !!c.error,
                       span: span, row: row, lastCol: col + span >= cols });
            col += span;
            if (col >= cols) { col = 0; row++; }
        });
        var maxRow = out.length ? out[out.length - 1].row : 0;
        out.forEach(function (c) { c.lastRow = (c.row === maxRow); });
        return out;
    }

    color: "transparent"
    border.width: 1
    border.color: lineColor
    implicitWidth: grid.implicitWidth + 2
    implicitHeight: grid.implicitHeight + 2

    GridLayout {
        id: grid
        anchors.fill: parent
        anchors.margins: 1
        columns: frame.columns
        columnSpacing: 0
        rowSpacing: 0

        Repeater {
            model: frame.laid
            delegate: Rectangle {
                id: cell
                required property var modelData
                Layout.columnSpan: modelData.span
                Layout.fillWidth: true
                Layout.fillHeight: true
                // A spanning value cell must report its real width, otherwise the columns it spans stay empty and
                // a tooltip (sized from the implicit width) squeezes it. Only long error texts stay "elastic".
                implicitWidth: (modelData.span > 1 && modelData.error) ? 1 : label.implicitWidth + Kirigami.Units.largeSpacing * 2
                implicitHeight: label.implicitHeight + Kirigami.Units.smallSpacing * 2
                color: modelData.shade ? Qt.alpha(Kirigami.Theme.textColor, 0.12) : "transparent"

                // right and bottom rules (the outer frame is drawn by the container)
                Rectangle {
                    visible: !cell.modelData.lastCol
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    width: 1
                    color: frame.lineColor
                }
                Rectangle {
                    visible: !cell.modelData.lastRow
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1
                    color: frame.lineColor
                }

                PlasmaComponents3.Label {
                    id: label
                    anchors.left: parent.left
                    anchors.right: cell.modelData.span > 1 ? parent.right : undefined
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Kirigami.Units.largeSpacing
                    anchors.rightMargin: Kirigami.Units.largeSpacing
                    text: cell.modelData.text
                    textFormat: Text.PlainText
                    elide: cell.modelData.span > 1 ? Text.ElideRight : Text.ElideNone
                    font.bold: cell.modelData.bold
                    color: cell.modelData.error ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                }
            }
        }
    }
}
