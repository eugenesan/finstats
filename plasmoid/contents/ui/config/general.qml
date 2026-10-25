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
            Kirigami.FormData.label: i18n("Shown on the panel")
        }
        QQC2.CheckBox {
            text: i18n("Bitcoin price")
            checked: page.cfg_showBTC
            onToggled: page.cfg_showBTC = checked
        }
        QQC2.CheckBox {
            text: i18n("Bitcoin transaction fee")
            checked: page.cfg_showBTCFee
            onToggled: page.cfg_showBTCFee = checked
        }
        QQC2.CheckBox {
            text: i18n("Gold and silver prices")
            checked: page.cfg_showMetals
            onToggled: page.cfg_showMetals = checked
        }
        QQC2.CheckBox {
            text: i18n("Gold/silver ratio")
            enabled: page.cfg_showMetals
            checked: page.cfg_showMetalsRatio
            onToggled: page.cfg_showMetalsRatio = checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Shown in the popup")
        }
        QQC2.CheckBox {
            text: i18n("Bitcoin price")
            checked: page.cfg_showBTCTT
            onToggled: page.cfg_showBTCTT = checked
        }
        QQC2.CheckBox {
            text: i18n("Bitcoin transaction fee")
            checked: page.cfg_showBTCFeeTT
            onToggled: page.cfg_showBTCFeeTT = checked
        }
        QQC2.CheckBox {
            text: i18n("Gold and silver prices and ratios")
            checked: page.cfg_showMetalsTT
            onToggled: page.cfg_showMetalsTT = checked
        }
        QQC2.CheckBox {
            text: i18n("Stack value (configured on the Stack page)")
            checked: page.cfg_showStack
            onToggled: page.cfg_showStack = checked
        }
    }
}
