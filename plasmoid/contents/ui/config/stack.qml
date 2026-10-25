/*
 * SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Financial Stats Applet for Plasma 6
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

CfgPage {
    id: page

    // Dot-decimal numbers only, independent of the system locale
    readonly property var numberValidator: RegularExpressionValidator { regularExpression: /^\d{0,9}(\.\d{0,8})?$/ }

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Bitcoin")
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("Amount held:")
            text: page.cfg_btcStack
            validator: page.numberValidator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onTextEdited: page.cfg_btcStack = text
            QQC2.ToolTip.text: i18n("Number of bitcoins in the stack, e.g. 1.234567")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("Cost basis per BTC:")
            text: page.cfg_btcCost
            validator: page.numberValidator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onTextEdited: page.cfg_btcCost = text
            QQC2.ToolTip.text: i18n("Average purchase price of one bitcoin, in your currency")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Capital gains tax (%):")
            from: 0
            to: 99
            value: page.cfg_capGainBTC
            onValueModified: page.cfg_capGainBTC = value
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Gold")
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Amount held:")
            from: 0
            to: 999
            value: page.cfg_auStack
            onValueModified: page.cfg_auStack = value
            QQC2.ToolTip.text: i18n("Amount of gold in the stack (0–999), in the unit of the price source")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Slippage (%):")
            from: 0
            to: 99
            value: page.cfg_auSlip
            onValueModified: page.cfg_auSlip = value
            QQC2.ToolTip.text: i18n("Estimated loss when selling gold (0–99 %)")
            QQC2.ToolTip.visible: hovered
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Silver")
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Amount held:")
            from: 0
            to: 999
            value: page.cfg_agStack
            onValueModified: page.cfg_agStack = value
            QQC2.ToolTip.text: i18n("Amount of silver in the stack (0–999), in the unit of the price source")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Slippage (%):")
            from: 0
            to: 99
            value: page.cfg_agSlip
            onValueModified: page.cfg_agSlip = value
            QQC2.ToolTip.text: i18n("Estimated loss when selling silver (0–99 %)")
            QQC2.ToolTip.visible: hovered
        }
    }
}
