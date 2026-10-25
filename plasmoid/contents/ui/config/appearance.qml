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

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Panel")
        }
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Color feedback:")
            text: i18n("Highlight while updating, dim after errors")
            checked: page.cfg_appletColor
            onToggled: page.cfg_appletColor = checked
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Placeholder symbol:")
            presets: ["💰", "🪙", "💲"]
            value: page.cfg_appletSymbol
            onEdited: text => page.cfg_appletSymbol = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Delimiter:")
            presets: ["│", "∣", "¦", "·", "•", "!"]
            value: page.cfg_delimSymbol
            onEdited: text => page.cfg_delimSymbol = text
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Decimal places:")
            from: 0
            to: 9
            value: page.cfg_decPlaces
            onValueModified: page.cfg_decPlaces = value
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Divide prices above:")
            from: 0
            to: 100000
            stepSize: 100
            editable: true
            value: page.cfg_priceDivider
            onValueModified: page.cfg_priceDivider = value
            QQC2.ToolTip.text: i18n("Prices greater than this are divided by it (67123 → 67.1). 0 disables dividing.")
            QQC2.ToolTip.visible: hovered
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Popup and tooltip")
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Decimal places:")
            from: 0
            to: 9
            value: page.cfg_decPlacesTT
            onValueModified: page.cfg_decPlacesTT = value
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Warning:")
            presets: ["⚠", "☝", "!"]
            value: page.cfg_warnSymbol
            onEdited: text => page.cfg_warnSymbol = text
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Symbols")
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Currency:")
            presets: ["$", "US$", "USD"]
            value: page.cfg_curSymbol
            onEdited: text => page.cfg_curSymbol = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Minor currency (1/100):")
            presets: ["¢", "c"]
            value: page.cfg_minorcurSymbol
            onEdited: text => page.cfg_minorcurSymbol = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Bitcoin:")
            presets: ["₿", "Ⓑ", "BTC"]
            value: page.cfg_btcSymbol
            onEdited: text => page.cfg_btcSymbol = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Satoshi:")
            presets: ["Ș", "≐", "丰", "sats"]
            value: page.cfg_satsSymbol
            onEdited: text => page.cfg_satsSymbol = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Gold:")
            presets: ["Au", "☀", "🥇", "🜚"]
            value: page.cfg_auSymbol
            onEdited: text => page.cfg_auSymbol = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Silver:")
            presets: ["Ag", "☾", "🥈", "🜛"]
            value: page.cfg_agSymbol
            onEdited: text => page.cfg_agSymbol = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("Stack:")
            presets: ["∑", "Σ", "Ʃ"]
            value: page.cfg_stackSymbol
            onEdited: text => page.cfg_stackSymbol = text
        }
    }
}
