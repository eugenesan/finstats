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
	property alias cfg_showMetals: showMetals.checked
	property alias cfg_showBTCFee: showBTCFee.checked
	property alias cfg_stackSymbol: stackSymbol.text
	property alias cfg_curSymbol: curSymbol.text
	property alias cfg_btcSymbol: btcSymbol.text
	property alias cfg_btcfeeSymbol: btcfeeSymbol.text
	property alias cfg_satsSymbol: satsSymbol.text
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
	property alias cfg_priceDivider: priceDivider.value
	property alias cfg_timeRefresh: timeRefresh.value
	property alias cfg_timeRetry: timeRetry.value
	property alias cfg_timeRefetch: timeRefetch.value
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
				id: gridLayout
				columns: 2

				// BTC sources
				Label {
					text: i18n("Load BTC preset:")
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

					ToolTip.visible: hovered
					ToolTip.text: i18n("Load preset for fetching Bitcoin price")
				}

				// BTC URL
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC fetch URL:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcUrl
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL to fetch BTC from")
				}

				// BTC Key
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC JSON key:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcKey
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for BTC value")
				}

				// Show btcfee
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show BTC Fee:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showBTCFee
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display BTC Fee in the applet and ToolTip.")
				}

				// BTC fee URL
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC Fee fetch URL:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcfeeUrl
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL to fetch BTC fee from")
				}

				// BTC fee Key
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC Fee JSON key:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcfeeKey
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for BTC fee value")
				}

				// Show metals
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show Metals:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showMetals
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display metals in the applet and ToolTip.")
				}

				// Metals URL
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals fetch URL:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: metalsUrl
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL to Metals from")
				}

				// Metals Au Key
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Au JSON key:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: metalsKeyAu
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for Au value")
				}

				// Metals Ag Key
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Ag JSON key:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: metalsKeyAg
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which JSON key to extract for Ag value")
				}

				// Stack symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Stack symbol:")
					horizontalAlignment: Label.AlignLeft
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
					Layout.minimumWidth: root.width / 3
					text: i18n("Currency symbol:")
					horizontalAlignment: Label.AlignLeft
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
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate BTC")
				}

				// BTC fee symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC fee symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcfeeSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate BTC fee")
				}

				// Sats symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Sats symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: satsSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Satoshi")
				}

				// Metals Au symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Au symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: auSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Gold")
				}

				// Metals Ag symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Ag symbol:")
					horizontalAlignment: Label.AlignLeft
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
					Layout.minimumWidth: root.width / 3
					text: i18n("Ratio symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: ratioSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate ratio")
				}

				// Show stacks
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show Stacks:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showStacks
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display stacks summary in the ToolTip.")
				}

				// BTC size
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC stack size:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: btcStack
					from: 0
					to: 999
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Count of Bitcoin in the stack. Valid range: 0–999.")
				}

				// Metals Au size
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Au stack size:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: auStack
					from: 0
					to: 999
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Count of Silver in the stack. Valid range: 0–999.")
				}

				// Metals Ag size
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Ag stack size:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: agStack
					from: 0
					to: 999
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Count of Silver in the stack. Valid range: 0–999.")
				}

				// BTC cost
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC cost basis:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: btcCost
					from: 0
					to: 999999
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Bitcoin cost basis. Valid range: 0–999999.")
				}

				// Capital gains
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Capital gains tax (%):")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: capGain
					from: 0
					to: 99
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Capital gains tax ammount. Valid range: 0–99.")
				}

				// Decimal places
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Applet decimal places:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: decPlaces
					from: 0
					to: 9
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Decimal places for applet. Valid range: 0–9.")
				}

				// Decimal places tooltip
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("ToolTip decimal places:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: decPlacesTT
					from: 0
					to: 9
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Decimal places for ToolTip. Valid range: 0–9.")
				}

				// Price divider
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Applet price divider:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: priceDivider
					from: 0
					to: 999999
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Divider to apply to prices on appplet. Valid range: 0–999999.")
				}

				// Refresh timer
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Refresh timer (minutes):")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: timeRefresh
					from: 1
					to: 60
					stepSize: 1
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Minutes to refresh the values. Valid range: 1–60.")
				}

				// Retry parse timer
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Retry parse timer (seconds):")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: timeRetry
					from: 1
					to: 60
					stepSize: 1
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Seconds to retry parsing the values. Valid range: 1–60.")
				}

				// Retry fetch timer
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Retry fetch timer (minutes):")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: timeRefetch
					from: 1
					to: 60
					stepSize: 1
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Minutes to retry fetching the values. Valid range: 1–60.")
				}
			}  // Closing GridLayout
		}      // Closing ColumnLayout
	}          // Closing ScrollView
}              // Closing Item
