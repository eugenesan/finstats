/*
* SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-SnippetComment: Financial Stats Widget for Plasma 6
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core
import org.kde.plasma.plasmoid
import org.kde.plasma.components
import org.kde.kirigami

PlasmoidItem {
	id: root
	//Layout.fillHeight: true
	Layout.minimumWidth: myLabel.implicitWidth + 5

	// Global status of fetch process
	property bool dataReadyFull: false
	property int dataReadyAttemp: 0

	// Status and data of individual fetches
	property variant fetchState:
	{
		"btc":    {ready: false, data: [0.0], xhr: []},
		"btcfee": {ready: false, data: [0.0], xhr: []},
		"metals": {ready: false, data: [0.0,0.0,0.0], xhr: [,]}
	}

	// Global vars from config
	property bool appletColor: plasmoid.configuration.appletColor
	property bool showBTC: plasmoid.configuration.showBTC
	property bool showBTCTT: plasmoid.configuration.showBTCTT
	property bool showBTCFee: plasmoid.configuration.showBTCFee
	property bool showBTCFeeTT: plasmoid.configuration.showBTCFeeTT
	property bool showMetals: plasmoid.configuration.showMetals
	property bool showMetalsRatio: plasmoid.configuration.showMetalsRatio
	property bool showMetalsTT: plasmoid.configuration.showMetalsTT
	property bool showStack: plasmoid.configuration.showStack
	property string appletSymbol: plasmoid.configuration.appletSymbol
	property string stackSymbol: plasmoid.configuration.stackSymbol
	property string curSymbol: plasmoid.configuration.curSymbol
	property string minorcurSymbol: plasmoid.configuration.minorcurSymbol
	property string btcSymbol: plasmoid.configuration.btcSymbol
	property string satsSymbol: plasmoid.configuration.satsSymbol
	property string auSymbol: plasmoid.configuration.auSymbol
	property string agSymbol: plasmoid.configuration.agSymbol
	property string warnSymbol: plasmoid.configuration.warnSymbol
	property string delimSymbol: plasmoid.configuration.delimSymbol
	property real btcStack: plasmoid.configuration.btcStack
	property int btcCost: plasmoid.configuration.btcCost
	property int capGainBTC: plasmoid.configuration.capGainBTC
	property int auStack: plasmoid.configuration.auStack
	property int auSlip: plasmoid.configuration.auSlip
	property int agStack: plasmoid.configuration.agStack
	property int agSlip: plasmoid.configuration.agSlip
	property int decPlaces: plasmoid.configuration.decPlaces
	property int decPlacesTT: plasmoid.configuration.decPlacesTT
	property int priceDivider: plasmoid.configuration.priceDivider
	property int timeRefresh: plasmoid.configuration.timeRefresh
	property int timeRetry: plasmoid.configuration.timeRetry
	property int timeRefetch: plasmoid.configuration.timeRefetch

	// Fetch paramaters from config
	property string btcUrl: plasmoid.configuration.btcUrl
	property string btcKey: plasmoid.configuration.btcKey
	property string btcfeeUrl: plasmoid.configuration.btcfeeUrl
	property string btcfeeKey: plasmoid.configuration.btcfeeKey
	property string metalsUrl: plasmoid.configuration.metalsUrl
	property string metalsSuffAu: plasmoid.configuration.metalsSuffAu
	property string metalsSuffAg: plasmoid.configuration.metalsSuffAg
	property string metalsKeyAu: plasmoid.configuration.metalsKeyAu
	property string metalsKeyAg: plasmoid.configuration.metalsKeyAg

	ToolTipArea {
		id: toolTip
		width: parent.width
		height: parent.height
		anchors.fill: parent
		mainText: "Financial Stats"
		active: true
		interactive: true
		textFormat: Text.MarkdownText // RichText StyledText
	}

	MouseArea {
		id: mouseAreaValue
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton
		// Refresh the label and reset time on mouse click
		onClicked: (mouse) => {
			console.log("finstats::MouseArea::clicked-start-refresh-data")

			// Change applet color if needed
			if (appletColor) myLabel.color = Theme.disabledTextColor

			// Send fetch requests, reset attempt counter and reset/enable data ready timer
			refreshTimer.interval = timeRefresh * 60 * 1000
			dataReadyAttemp = 0
			fetchData()
			datareadyWait.running = true
			console.debug("finstats::MouseArea::clicked::stop-timer-restart")
			refreshTimer.restart()
		}

		hoverEnabled: true
		onEntered: {
			toolTip.showToolTip()
		}
		onExited: {
			toolTip.hideToolTip()
		}
	}

	ColumnLayout {
		// A simple label to display the JSON data
		Label {
			id: myLabel
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
	}

	ColorAnimation {
		id: colorFeedback
		target: myLabel
		property: "color"
		from: Theme.disabledTextColor
		to: (dataReadyFull) ? Theme.textColor : Theme.neutralTextColor
		duration: 1000
	}

	Component.onCompleted: {
		myLabel.text = appletSymbol
		fetchData()

		// Resume monitoring data ready
		datareadyWait.running = true
		dataReadyAttemp = 0
	}

	// Refresh applet every 15 minutes
	Timer {
		id: refreshTimer
		interval: timeRefresh * 60 * 1000
		running: true
		repeat: true
		onTriggered: {
			// Change applet color if needed
			if (appletColor) myLabel.color = Theme.disabledTextColor

			// Restore configured interval in case it was shortened by datareadyWait
			interval = timeRefresh * 60 * 1000

			// Send fetch requests and enable data ready timer
			fetchData()
			datareadyWait.running = true
			dataReadyAttemp = 0
		}
	}

	// Wait for data to be fetched and build applet/tooltip text
	Timer {
		id: datareadyWait
		interval: (timeRetry / 2) * 1000
		running: true
		repeat: true

		onTriggered: {
			// Check if all the results marked as fetched and dataready timer still enabled
			if ( datareadyWait.running &&
				( (fetchState["btc"].ready &&
					(fetchState["btc"].data[0] > (1/100000000))) || (!showBTC && !showBTCTT) ) &&
				( (fetchState["btcfee"].ready &&
					(fetchState["btcfee"].data[0] > (1/100000000))) || (!showBTCFee && !showBTCFeeTT) ) &&
				( (fetchState["metals"].ready &&
					(fetchState["metals"].data[0] > (1/100000000))) || (!showMetals && !showMetalsTT) ) &&
				( (fetchState["metals"].ready &&
					(fetchState["metals"].data[1] > (1/100000000))) || (!showMetals && !showMetalsTT) ) )
			{
				console.debug("finstats::Timer::timerTriggered::Build::Ready::interval:", interval,
					"dataReadyAttemp:", dataReadyAttemp, "dataReadyFull:", dataReadyFull,
					"datareadyWait.running:", datareadyWait.running,
					"showBTC:", showBTC, "showBTCFee:", showBTCFee, "showMetals:", showMetals,
					"showBTCTT:", showBTCTT, "showBTCFeeTT:", showBTCFeeTT, "showMetalsTT:", showMetalsTT,
					"btcReady:", fetchState["btc"].ready, "btcfeeReady:", fetchState["btcfee"].ready,
					"metalsReady:", fetchState["metals"].ready,
					"btcData:", fetchState["btc"].data[0], "btcfeeData[0]:", fetchState["btcfee"].data[0],
					"metalsData[0]:", fetchState["metals"].data[0], "metalsData[1]:", fetchState["metals"].data[1])

				// Disable timer to avoid duplicate calls
				datareadyWait.running = false

				// Once all data fetched, build label
				dataReadyFull = true
				buildData()
				if (appletColor) colorFeedback.restart()
			} else {
				console.debug("finstats::Timer::timerTriggered::Attempt::interval:", interval,
					"dataReadyAttemp:", dataReadyAttemp, "dataReadyFull:", dataReadyFull,
					"datareadyWait.running:", datareadyWait.running,
					"showBTC:", showBTC, "showBTCFee:", showBTCFee, "showMetals:", showMetals,
					"showBTCTT:", showBTCTT, "showBTCFeeTT:", showBTCFeeTT, "showMetalsTT:", showMetalsTT,
					"btcReady:", fetchState["btc"].ready, "btcfeeReady:", fetchState["btcfee"].ready,
					"metalsReady:", fetchState["metals"].ready,
					"btcData:", fetchState["btc"].data[0], "btcfeeData[0]:", fetchState["btcfee"].data[0],
					"metalsData[0]:", fetchState["metals"].data[0], "metalsData[1]:", fetchState["metals"].data[1])

				// Disable full readiness until result are ready
				dataReadyFull = false

				// Not all data is ready, invalid results or duplicate call
				dataReadyAttemp++
			}

			// Retry 3 times and if still failed, set refresh timer as configured
			if (dataReadyAttemp > 4) {
				console.log("finstats::Timer::timerTriggered::LastAttemp::AbortingFetches:", "timeRetry:", timeRetry,
							"refreshTimer.interval:", refreshTimer.interval)

				// Stop all fetch requests
				if (typeof fetchState["btc"].xhr[0] != 'undefined') fetchState["btc"].xhr[0].abort()
				if (typeof fetchState["btcfee"].xhr[0] != 'undefined') fetchState["btcfee"].xhr[0].abort()
				if (typeof fetchState["metals"].xhr[0] != 'undefined') fetchState["metals"].xhr[0].abort()
				if (typeof fetchState["metals"].xhr[1] != 'undefined') fetchState["metals"].xhr[1].abort()

				// Reset ready/running states and set refetch timer
				running = false
				dataReadyFull = false
				refreshTimer.interval = timeRefetch * 60 * 1000

				// After max retries, call partial build
				buildData()
				if (appletColor) colorFeedback.restart()
			}
		}
	}

	function buildData() {
		console.log("finstats::buildData::dataReadyFull:", dataReadyFull)

		// Get current date and time
		var currentTime = new Date()
		// Format date and time for display
		var formattedDate = Qt.formatDateTime(currentTime, "yyyy-MM-dd")
		var formattedTime = Qt.formatDateTime(currentTime, "hh:mm")
		var refreshTime = new Date(currentTime.getTime() + refreshTimer.interval)
		var formattedRefresh = Qt.formatDateTime(refreshTime, "hh:mm")

		// Calculate BTCFee (141Stas/vB is for Segwit 1*in 2*out Tx)
		var btcStdFee = (( (fetchState["btcfee"].data[0] < 1) &&
			(fetchState["btcfee"].data[0] > 0) ) ? 1 : fetchState["btcfee"].data[0]) * 141
		// Price per Tx in currency
		var btcStdFeePrice = btcStdFee / 100000000 * fetchState["btc"].data[0]

		// Initialize stack values
		var btcTax = 0
		var btcNet = 0
		var auNet = 0
		var agNet = 0

		// Initialize applet and tooltip strings (unicode symbols collection Ⓑ₿Ș$≐🜚🜛· ∣│◕ │ )
		var ttStr = ""
		var aStr = ""

		// Add BTC to applet
		if (showBTC) {
			aStr = ((fetchState["btc"].data[0] > priceDivider) ?
				(fetchState["btc"].data[0] / priceDivider) : fetchState["btc"].data[0]).toFixed(decPlaces)
		}

		// Add BTC fee to applet
		if (showBTCFee) {
			aStr += ((aStr.length > 0) ? " " + delimSymbol + " " : "") + ((btcStdFeePrice < 1) ?
				(btcStdFeePrice * 100).toFixed(0) : btcStdFeePrice.toFixed(decPlacesTT))
		}

		// Add metals to applet
		if (showMetals) {
			aStr += ((aStr.length > 0) ? " " + delimSymbol + " " : "") +
				((fetchState["metals"].data[0] > priceDivider) ?
					(fetchState["metals"].data[0] / priceDivider) : fetchState["metals"].data[0]).toFixed(decPlaces)
			aStr += " " + delimSymbol + " " +
				((fetchState["metals"].data[1] > priceDivider) ?
					(fetchState["metals"].data[1] / priceDivider) : fetchState["metals"].data[1]).toFixed(decPlaces)
			if (showMetalsRatio)
					aStr += " " + delimSymbol + " " + (fetchState["metals"].data[2]).toFixed(decPlaces)
		}

		myLabel.text = (aStr.length > 0) ? aStr : curSymbol
		console.log("finstats::buildData::applet-ready::myLabel.text:", myLabel.text)

		// Start tooltip with timestamp and markdown table header
		ttStr += "| 🗓 |" + formattedDate + " | ⏱ | " + formattedTime + " |\n"
		ttStr += "| :--- | :--- | :--- | :--- |\n"

		// Add BTC totooltip
		if (showBTCTT) {
			ttStr += "| **" + btcSymbol + (fetchState["btc"].ready ?
				"" : "<sup>" + warnSymbol + "</sup>") + "** | " + (fetchState["btc"].data[0]).toFixed(decPlacesTT) +
					"<sup>" + curSymbol + "</sup>"
		}

		// Add BTC Fee to tooltip
		if (showBTCFeeTT) {
			ttStr += " | **" + btcSymbol + "<sub>Fee</sub>" + (fetchState["btcfee"].ready ?
				"" : "<sup>" + warnSymbol + "</sup>") + "** | " + btcStdFee + "<sup>" + satsSymbol + "</sup>"
			ttStr += " / " + ((btcStdFeePrice < 1) ?
				(btcStdFeePrice * 100).toFixed(0) : btcStdFeePrice.toFixed(decPlacesTT)) + "<sup>" +
					((btcStdFeePrice < 1) ? minorcurSymbol : curSymbol) + "</sup> |"
		}
		if (showBTCTT || showBTCFeeTT) ttStr += "\n"

		// Add metals to tooltip
		if (showMetalsTT) {
			ttStr += "| **" + auSymbol + (fetchState["metals"].ready ?
				"" : "<sup>" + warnSymbol + "</sup>") + "** | " + (fetchState["metals"].data[0]).toFixed(decPlacesTT) +
					"<sup>" + curSymbol + "</sup>"
			ttStr += " | **" + agSymbol + (fetchState["metals"].ready ?
				"" : "<sup>" + warnSymbol + "</sup>") + "** | " + (fetchState["metals"].data[1]).toFixed(decPlacesTT) +
					"<sup>" + curSymbol + "</sup>"
			ttStr += " |\n"

			if (showBTC || showBTCTT) ttStr += "| **" + btcSymbol + "/" + auSymbol + "** | " +
				( ((fetchState["btc"].data[0] > 0) && (fetchState["metals"].data[0] > 0) ) ?
					fetchState["btc"].data[0]/fetchState["metals"].data[0] : 0).toFixed(decPlacesTT)
			ttStr += " | **" + auSymbol + "/" + agSymbol + "** | " +
				(fetchState["metals"].data[2]).toFixed(decPlacesTT)
			ttStr += " |\n"
		}

		// Add stack to tooltip
		if (showStack) {
			if (showMetalsTT) {
				// Calculate Metals related stack
				auNet = fetchState["metals"].data[0] * auStack * (1 - (1 / 100 * auSlip))
				agNet = fetchState["metals"].data[1] * agStack * (1 - (1 / 100 * agSlip))
				ttStr += "| **" + stackSymbol + auSymbol + "** | " + auNet.toFixed(decPlacesTT) +
					"<sup>" + curSymbol + "</sup>"
				ttStr += " | **" + stackSymbol + agSymbol + "** | " + agNet.toFixed(decPlacesTT) +
					"<sup>" + curSymbol + "</sup>"
				ttStr += " |\n"
			}

			if (showBTC || showBTCTT) {
				// Calculate BTC related stack
				btcTax = ((fetchState["btc"].data[0] * btcStack) - (btcCost * btcStack)) / 100 * capGainBTC
				btcNet = (fetchState["btc"].data[0] * btcStack) - ((btcTax < 0) ? 0 : btcTax)
				ttStr += "| **" + stackSymbol + btcSymbol + "** | " +
					(btcNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
				ttStr += " | **" + stackSymbol + "<sub>Total</sub>** | " +
				( ((showBTC || showBTCTT) ? btcNet : 0) + auNet + agNet).toFixed(decPlacesTT) +
					"<sup>" + curSymbol + "</sup>"
				ttStr += " |\n"
			}
		}

		// Finalize the tooltip
		if (!dataReadyFull) ttStr += "*" + warnSymbol + " Error during last update*\n"
		ttStr += "*Next update at " +  formattedRefresh + " (click for now)*\n"

		toolTip.subText = ttStr
		console.log("finstats::buildData::tooltip-ready::toolTip.subText:", toolTip.subText)
	}

	// Initiate fetch requests
	function fetchData() {
		var userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0esr) Gecko/20100101 Firefox/140.0esr"
		var Paths = {"btc": [], "btcfee": [], "metals": []}
		var Suffs = {"btc": [], "btcfee": [], "metals": []}

		Paths["btc"].push(btcKey)
		Paths["btcfee"].push(btcfeeKey)

		if (metalsKeyAu.length > 0) Paths["metals"].push(metalsKeyAu)
		if ((metalsKeyAg.length > 0) && (metalsKeyAu != metalsKeyAg)) Paths["metals"].push(metalsKeyAg)

		if (metalsSuffAu.length > 0) Suffs["metals"].push(metalsSuffAu)
		if ((metalsSuffAg.length > 0) && (metalsSuffAu != metalsSuffAg)) Suffs["metals"].push(metalsSuffAg)
		console.debug("finstats::fetchData:", "btcPaths:", Paths["btc"], "btcfeePaths", Paths["btcfee"],
					  "metalsPaths", Paths["metals"], "metalsSuffs", Suffs["metals"])

		function parseData (xhr, idx) {
			// Parse data from XML response
			if (xhr.readyState === XMLHttpRequest.DONE) {
				if (xhr.status === 200) {
					try {
						// Parse response
						for (var y = 0; y < Paths[idx].length; y++) {
							// Parse response
							var data = JSON.parse(xhr.responseText)
							// Save original response for later
							var data_orig = data
							// Explode keys for "dive search"
							var keys = Paths[idx][y].split(".")

							// Start "dive search" in JSON tree and derive which data index to use based on suffix
							console.debug("finstats::fetchData::parseData::PreParsing::idx:", idx, "data:",
										  data, "y:", y, "keys:", keys)
							for (var x = 0; x < keys.length; x++) {
								console.debug("finstats::fetchData::parseData::Parsing::idx:", idx, "x:", x,
											  "Paths[y]:", Paths[idx][y], "keys[x]:", keys[x],
											  "data[keys[x]]:", data[keys[x]])
								if (typeof data[keys[x]] != 'undefined' ) {
									// Strip one level from data
									data = data[keys[x]]

									// Signal data is ready (first hit is a must)
									if (x == 0) fetchState[idx].ready = true

									// Make sure suffixes are not enabled before we check
									var suffUsed = false

									// Check if data contains suffix symbol and use corresponding data index
									for (var z = 0; z < Suffs[idx].length; z++) {
										if ( (typeof data_orig["symbol"] != 'undefined' ) &&
											(data_orig["symbol"] == Suffs[idx][z]) ) {
											console.debug("finstats::fetchData::parseData::Parsing::z::idx:", idx,
														  "z:", z, "data_orig[symbol]", data_orig["symbol"],
														  "Suffs[z]:", Suffs[idx][z], "keys[x]:", keys[x],
														  "data[keys[x]]:", data[keys[x]])

											// Indicate suffix used and save filtered value
											fetchState[idx].data[z] = parseFloat(data)
											suffUsed = true
										} else {
											console.debug("finstats::fetchData::parseData::Parsing::z::skip::idx:", idx,
														  "z:", z, "Suffs[z]:", Suffs[idx][z],
														  "keys[x]:", keys[x], "data[keys[x]]:", data[keys[x]])
										}
									}

									// Save filtered value if suffix not used above
									if (!suffUsed) fetchState[idx].data[y] = parseFloat(data)
								} else {
									console.debug("finstats::fetchData::parseData::Parsing::undefined:idx:", idx)
									// Fail parsing for now
									fetchState[idx].ready = false
								}
							}
							// Add metals ratio if possible
							if (idx == "metals") {
								fetchState[idx].data[2] = (((fetchState[idx].data[0] > 0) &&
								(fetchState[idx].data[1] > 0)) ? (fetchState[idx].data[0]/fetchState[idx].data[1]) : 0)
							}
							console.debug("finstats::fetchData::parseData::PostParsing:idx:", idx, "y:", y,
										  "data:", data)
						}
					} catch (e) {
						console.error("finstats::fetchData::parseData::JSONParsingError::idx:", idx, "error:", e)
					}
				} else {
					console.error("finstats::fetchData::parseData::HTTP Error::idx:", idx, "error:", xhr.status)
				}

				console.log("finstats::fetchData::parseData::PostFetch::Ready::idx:", idx, "ready:",
							fetchState[idx].ready)
			} else {
				console.debug("finstats::fetchData::parseData::readyStatus::idx:", idx, "state:", xhr.readyState)
			}
		}

		// Initialize and send BTC fetch request
		if (showBTC || showBTCTT) {
			fetchState["btc"].ready = false
			fetchState["btc"].xhr[0] = new XMLHttpRequest()
			fetchState["btc"].xhr[0].onreadystatechange = function() { parseData(fetchState["btc"].xhr[0], "btc") }
			fetchState["btc"].xhr[0].open("GET", btcUrl, true)
			fetchState["btc"].xhr[0].setRequestHeader('User-Agent', userAgent)
			fetchState["btc"].xhr[0].send()
			console.debug("finstats::fetchData::BTC::send::URL:", btcUrl)
		}

		// Initialize and send BTCfee fetch request
		if (showBTCFee || showBTCFeeTT) {
			fetchState["btcfee"].ready = false
			fetchState["btcfee"].xhr[0] = new XMLHttpRequest()
			fetchState["btcfee"].xhr[0].onreadystatechange = function() { parseData(fetchState["btcfee"].xhr[0], "btcfee") }
			fetchState["btcfee"].xhr[0].open("GET", btcfeeUrl, true)
			fetchState["btcfee"].xhr[0].setRequestHeader('User-Agent', userAgent)
			fetchState["btcfee"].xhr[0].send()
			console.debug("finstats::fetchData::BTCfee::send::URL:", btcfeeUrl)
		}

		// Initialize and send Metals fetch request (2 if 2nd suffix is provided)
		if (showMetals || showMetalsTT) {
			fetchState["metals"].ready = false
			fetchState["metals"].xhr[0] = new XMLHttpRequest()
			fetchState["metals"].xhr[0].onreadystatechange = function() { parseData(fetchState["metals"].xhr[0], "metals") }
			fetchState["metals"].xhr[0].open("GET", metalsUrl + metalsSuffAu, true)
			fetchState["metals"].xhr[0].setRequestHeader('User-Agent', userAgent)
			fetchState["metals"].xhr[0].send()
			console.debug("finstats::fetchData::Metals1::send::URL:", metalsUrl, "suffix1:", metalsSuffAu)

			if ( (metalsSuffAg.length > 0) && (metalsSuffAg != metalsSuffAu) ) {
				fetchState["metals"].xhr[1] = new XMLHttpRequest()
				fetchState["metals"].xhr[1].onreadystatechange = function() { parseData(fetchState["metals"].xhr[1], "metals") }
				fetchState["metals"].xhr[1].open("GET", metalsUrl + metalsSuffAg, true)
				fetchState["metals"].xhr[1].setRequestHeader('User-Agent', userAgent)
				fetchState["metals"].xhr[1].send()
				console.debug("finstats::fetchData::Metals2::send::URL:", metalsUrl, "suffix2:", metalsSuffAg)
			}
		}
	}
}
