/*
 * SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Financial Stats Applet for Plasma 6
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
	id: root

	signal configurationChanged

	property alias cfg_showStacks: showStacks.checked
	property alias cfg_stackSymbol: stackSymbol.text
	property alias cfg_curSymbol: curSymbol.text
	property alias cfg_btcSymbol: btcSymbol.text
	property alias cfg_satSymbol: satSymbol.text
	property alias cfg_auSymbol: auSymbol.text
	property alias cfg_agSymbol: agSymbol.text
	property alias cfg_ratioSymbol: ratioSymbol.text
	property alias cfg_btcStack: btcStack.value
	property alias cfg_auStack: auStack.value
	property alias cfg_agStack: agStack.value
	property alias cfg_btcCost: btcCost.value
	property alias cfg_capGain: capGain.value
	property alias cfg_decPlaces: decPlaces.value
	property alias cfg_decPlacesTT: decPlacesTT.value
	property alias cfg_timeRefresh: timeRefresh.value
	property alias cfg_btcUrl: btcUrl.text
	property alias cfg_btcKey: btcKey.text
	property alias cfg_btcfeeUrl: btcfeeUrl.text
	property alias cfg_btcfeeKey: btcfeeKey.text
	property alias cfg_metalsUrl: metalsUrl.text
	property alias cfg_metalsKeyAu: metalsKeyAu.text
	property alias cfg_metalsKeyAg: metalsKeyAg.text

	ScrollView {
		width: parent.width
		height: parent.height

		ColumnLayout {
			GridLayout {
				columns: 2

				Label {
					text: i18n("Load BTC source:")
				}
				ComboBox {
					id: loadPresetCombo
					textRole: "text"

					model: [{
						text: i18n("Bitstamp BTC-USD"),
						url: "https://www.bitstamp.net/api/ticker/",
						key: "last"
					}, {
						text: i18n("Coinbase BTC-USD"),
						url: "https://api.coinbase.com/v2/prices/BTC-USD/spot",
						key: "data.amount"
					}, {
						text: i18n("Mempool BTC-USD"),
						url: "https://mempool.space/api/v1/prices",
						key: "USD"
					}, {
						text: i18n("Bitfinex BTC-USD"),
						url: "https://api.bitfinex.com/v1/pubticker/BTCUSD",
						key: "last_price"
					}, {
						text: i18n("Gemini BTC-USD"),
						url: "https://api.gemini.com/v1/pubticker/btcusd",
						key: "last"
					}, {
						text: i18n("Kraken BTC-USD"),
						url: "https://api.kraken.com/0/public/Ticker?pair=XBTUSD",
						key: "result.XXBTZUSD.c.0"
					}]

					Component.onCompleted: {
						for (var i = 0, length = model.length; i < length; ++i) {
							if (model[i].url === cfg_btcUrl) {
								currentIndex = i
								console.log("finstats::*::config:current-model:", currentIndex, model[currentIndex].url, model[currentIndex].key);
								return
							}
						}
					}

					onCurrentIndexChanged: {
						console.log("finstats::*::config:comboselect:", currentIndex, model[currentIndex].url, model[currentIndex].key);
						// Perform actions based on the new index
						cfg_btcUrl = model[currentIndex].url
						cfg_btcKey = model[currentIndex].key
					}
				}

				// Show stacks
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Show Stacks:")
					horizontalAlignment: Label.AlignRight
				}
				CheckBox {
					id: showStacks
					text: i18n("ShowStacks")
				}

				// Stack symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Stack symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: stackSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate stack")
				}

				// Currency symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Currency symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: curSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate currency")
				}

				// BTC symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: btcSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate BTC")
				}

				// Sat symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Sat symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: satSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Satoshi")
				}

				// Au symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Au symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: auSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Gold")
				}

				// Ag symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Ag symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: agSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Silver")
				}

				// Ratio symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Ratio symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: ratioSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate ratio")
				}

				// BTC size
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC stack size:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: btcStack
					to: 999
				}

				// Au size
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Au stack size:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: auStack
					to: 999
				}

				// Ag size
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Ag stack size:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: agStack
					to: 999
				}

				// BTC cost
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC cost basis:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: btcCost
					to: 999999
				}

				// Cap gains
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Capital gains tax:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: capGain
					to: 99
				}

				// Decimal places
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Decimal places to display:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: decPlaces
					to: 9
				}

				// Decimal places ToolTip
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Decimal places to display on ToolTip:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: decPlacesTT
					to: 9
				}

				// Time Refresh
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Time Refresh (minutes):")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					id: timeRefresh
					from: 1
					to: 60
					stepSize: 1
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Minutes to refresh the coin value. Valid range: 1–60.")
				}

				// BTC URL
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC fetch URL:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: btcUrl
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL to fetch BTC from")
				}

				// BTC Key
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC JSON key:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: btcKey
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for BTC value")
				}

				// BTC fee URL
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC Fee fetch URL:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: btcfeeUrl
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL to fetch BTC fee from")
				}

				// BTC fee Key
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC Fee JSON key:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: btcfeeKey
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for BTC fee value")
				}

				// Metals URL
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Metals fetch URL:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: metalsUrl
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL to Metals from")
				}

				// Au Key
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Au JSON key:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: metalsKeyAu
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for Au value")
				}

				// Ag Key
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Au JSON key:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: metalsKeyAg
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for Ag value")
				}

				// Applet version
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Financial Stats")
					horizontalAlignment: Label.AlignRight
				}

				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("v0.2 (2025-10-04)")
				}

			}  // Closing GridLayout
		}      // Closing ColumnLayout
	}          // Closing ScrollView
}              // Closing Item
