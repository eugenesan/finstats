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

	property alias cfg_btcUrl: btcUrl.text
	property alias cfg_btcKey: btcKey.text
	property alias cfg_btcfeeUrl: btcfeeUrl.text
	property alias cfg_btcfeeKey: btcfeeKey.text
	property alias cfg_metalsUrl: metalsUrl.text
	property alias cfg_metalsKeyAu: metalsKeyAu.text
	property alias cfg_metalsKeyAg: metalsKeyAg.text
	property alias cfg_metalsSuffAu: metalsSuffAu.text
	property alias cfg_metalsSuffAg: metalsSuffAg.text
	property alias cfg_timeRefresh: timeRefresh.value
	property alias cfg_timeRetry: timeRetry.value
	property alias cfg_timeRefetch: timeRefetch.value

	ScrollView {
		width: parent.width
		height: parent.height

		ColumnLayout {
			GridLayout {
				id: gridLayout
				columns: 2

				// BTC sources
				Label {
					text: i18n("Select BTC fetch preset:")
				}
				ComboBox {
					id: loadBTCPresetCombo
					textRole: "text"
					currentIndex: -1

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
						console.debug("finstats::*::config::fetch::BTC::ComboBox::onCompleted::currentIndex:", currentIndex)
						for (var i = 0, length = model.length; i < length; ++i) {
							if (model[i].url === cfg_btcUrl) {
								currentIndex = i
								console.debug("finstats::*::config::BTC::fetch::ComboBox::onCompleted::seekFound:", currentIndex, model[currentIndex].url, model[currentIndex].key);
								return
							}
						}
						console.log("finstats::*::config::fetch::BTC::ComboBox::onCompleted::seekError:", currentIndex)
					}

					onCurrentIndexChanged: {
						console.log("finstats::*::config::fetch::BTC::ComboBox::onCurrentIndexChanged:", currentIndex, model[currentIndex].url, model[currentIndex].key)
						// Perform actions based on the new index
						cfg_btcUrl = model[currentIndex].url
						cfg_btcKey = model[currentIndex].key
					}

					ToolTip.visible: hovered
					ToolTip.text: i18n("Select preset for fetching Bitcoin price")
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

				// Metals sources
				Label {
					text: i18n("Select Metals fetch preset:")
				}
				ComboBox {
					id: loadMetalsPresetCombo
					textRole: "text"
					currentIndex: -1

					model: [{
						text: i18n("Gold Price (goldprice.org)"),
						url: "https://data-asg.goldprice.org/dbXRates/USD",
						suffAu: "",
						suffAg: "",
						keyAu: "items.0.xauPrice",
						keyAg: "items.0.xagPrice"
					}, {
						text: i18n("Gold API (gold-api.com)"),
						url: "https://api.gold-api.com/price/",
						suffAu: "XAU",
						suffAg: "XAG",
						keyAu: "price",
						keyAg: "price"
					}]

					Component.onCompleted: {
						console.debug("finstats::*::config::fetch::Metals::ComboBox::onCompleted::currentIndex:", currentIndex)
						for (var i = 0, length = model.length; i < length; ++i) {
							if (model[i].url === cfg_metalsUrl) {
								currentIndex = i
								console.debug("finstats::*::config::fetch::Metals::ComboBox::onCompleted::seekFound:", currentIndex, model[currentIndex].url, model[currentIndex].keyAu, model[currentIndex].keyAg, model[currentIndex].suffAu, model[currentIndex].suffAg);
								return
							}
						}
						console.log("finstats::*::config::fetch::Metals::ComboBox::onCompleted::seekError:", currentIndex)
					}

					onCurrentIndexChanged: {
						console.log("finstats::*::config::fetch::Metals::ComboBox::onCurrentIndexChanged:", currentIndex, model[currentIndex].keyAu, model[currentIndex].keyAg, model[currentIndex].suffAu, model[currentIndex].suffAg)
						// Perform actions based on the new index
						cfg_metalsUrl = model[currentIndex].url
						cfg_metalsSuffAu = model[currentIndex].suffAu
						cfg_metalsSuffAg = model[currentIndex].suffAg
						cfg_metalsKeyAu = model[currentIndex].keyAu
						cfg_metalsKeyAg = model[currentIndex].keyAg
					}

					ToolTip.visible: hovered
					ToolTip.text: i18n("Select preset for fetching Metals price")
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

				// Metals Au Suffix
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Au URL suffix:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: metalsSuffAu
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL suffix to use for Au value")
				}

				// Metals Ag Suffix
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Ag URL suffix:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: metalsSuffAg
					Layout.minimumWidth: root.width * 0.6
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which URL suffix to use for Ag value")
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
