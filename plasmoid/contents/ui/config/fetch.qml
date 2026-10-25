/*
 * SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Financial Stats Applet for Plasma 6
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

CfgPage {
    id: page

    readonly property var btcPresets: [
        { text: "Coinstats",      url: "https://openapiv1.coinstats.app/coins/bitcoin",       key: "price" },
        { text: "Bitstamp",       url: "https://www.bitstamp.net/api/ticker/",                key: "last" },
        { text: "Coinbase",       url: "https://api.coinbase.com/v2/prices/BTC-USD/spot",     key: "data.amount" },
        { text: "Mempool.space",  url: "https://mempool.space/api/v1/prices",                 key: "USD" },
        { text: "Mempool.guide",  url: "https://mempool.guide/api/v1/prices",                 key: "USD" },
        { text: "Kilombino.com",  url: "https://mempool.kilombino.com/api/v1/prices",         key: "USD" },
        { text: "Bitfinex",       url: "https://api.bitfinex.com/v1/pubticker/BTCUSD",        key: "last_price" },
        { text: "Gemini",         url: "https://api.gemini.com/v1/pubticker/btcusd",          key: "last" },
        { text: "Kraken",         url: "https://api.kraken.com/0/public/Ticker?pair=XBTUSD",  key: "result.XXBTZUSD.c.0" }
    ]

    readonly property var feePresets: [
        { text: "Mempool.space", url: "https://mempool.space/api/v1/fees/precise" },
        { text: "Mempool.guide", url: "https://mempool.guide/api/v1/fees/recommended" },
        { text: "Kilombino.com", url: "https://mempool.kilombino.com/api/v1/fees/recommended" }
    ]

    readonly property var feeKeys: ["fastestFee", "halfHourFee", "hourFee", "economyFee", "minimumFee"]

    readonly property var metalsPresets: [
        { text: "goldprice.org", url: "https://data-asg.goldprice.org/dbXRates/USD",
          suffAu: "", suffAg: "", keyAu: "items.0.xauPrice", keyAg: "items.0.xagPrice" },
        { text: "gold-api.com", url: "https://api.gold-api.com/price/",
          suffAu: "XAU", suffAg: "XAG", keyAu: "price", keyAg: "price" }
    ]

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Timing")
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Refresh every (minutes):")
            from: 1
            to: 999
            value: page.cfg_timeRefresh
            onValueModified: page.cfg_timeRefresh = value
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Request timeout (seconds):")
            from: 1
            to: 99
            value: page.cfg_timeDataReady
            onValueModified: page.cfg_timeDataReady = value
            QQC2.ToolTip.text: i18n("How long to wait for the servers to answer")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Retry after error (minutes):")
            from: 1
            to: 99
            value: page.cfg_timeRefetch
            onValueModified: page.cfg_timeRefetch = value
        }

        // ---------------------------------------------------------------- BTC
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Bitcoin price")
        }
        PresetBox {
            Kirigami.FormData.label: i18n("Source:")
            presets: page.btcPresets
            current: ({ url: page.cfg_btcUrl, key: page.cfg_btcKey })
            onPresetChosen: p => { page.cfg_btcUrl = p.url; page.cfg_btcKey = p.key }
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("URL:")
            Layout.minimumWidth: Kirigami.Units.gridUnit * 22
            text: page.cfg_btcUrl
            onTextEdited: page.cfg_btcUrl = text
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("JSON key:")
            text: page.cfg_btcKey
            onTextEdited: page.cfg_btcKey = text
            QQC2.ToolTip.text: i18n("Dotted path to the price in the response, e.g. data.amount or result.XXBTZUSD.c.0")
            QQC2.ToolTip.visible: hovered
        }

        // ---------------------------------------------------------------- fee
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Bitcoin fee")
        }
        PresetBox {
            Kirigami.FormData.label: i18n("Source:")
            presets: page.feePresets
            current: ({ url: page.cfg_btcfeeUrl })
            onPresetChosen: p => page.cfg_btcfeeUrl = p.url
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("URL:")
            Layout.minimumWidth: Kirigami.Units.gridUnit * 22
            text: page.cfg_btcfeeUrl
            onTextEdited: page.cfg_btcfeeUrl = text
        }
        SymbolField {
            Kirigami.FormData.label: i18n("JSON key:")
            presets: page.feeKeys
            value: page.cfg_btcfeeKey
            onEdited: text => page.cfg_btcfeeKey = text
            QQC2.ToolTip.text: i18n("Fee level to use (sat/vB), or type another key")
        }

        // ---------------------------------------------------------------- metals
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Gold and silver")
        }
        PresetBox {
            Kirigami.FormData.label: i18n("Source:")
            presets: page.metalsPresets
            current: ({ url: page.cfg_metalsUrl, suffAu: page.cfg_metalsSuffAu, suffAg: page.cfg_metalsSuffAg,
                        keyAu: page.cfg_metalsKeyAu, keyAg: page.cfg_metalsKeyAg })
            onPresetChosen: p => {
                page.cfg_metalsUrl = p.url;
                page.cfg_metalsSuffAu = p.suffAu;
                page.cfg_metalsSuffAg = p.suffAg;
                page.cfg_metalsKeyAu = p.keyAu;
                page.cfg_metalsKeyAg = p.keyAg;
            }
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("URL:")
            Layout.minimumWidth: Kirigami.Units.gridUnit * 22
            text: page.cfg_metalsUrl
            onTextEdited: page.cfg_metalsUrl = text
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("Gold URL suffix:")
            text: page.cfg_metalsSuffAu
            onTextEdited: page.cfg_metalsSuffAu = text
            QQC2.ToolTip.text: i18n("Appended to the URL for the gold request")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("Silver URL suffix:")
            text: page.cfg_metalsSuffAg
            onTextEdited: page.cfg_metalsSuffAg = text
            QQC2.ToolTip.text: i18n("Appended to the URL for the silver request. Leave empty when one response holds both metals.")
            QQC2.ToolTip.visible: hovered
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("Gold JSON key:")
            text: page.cfg_metalsKeyAu
            onTextEdited: page.cfg_metalsKeyAu = text
        }
        QQC2.TextField {
            Kirigami.FormData.label: i18n("Silver JSON key:")
            text: page.cfg_metalsKeyAg
            onTextEdited: page.cfg_metalsKeyAg = text
        }
    }
}
