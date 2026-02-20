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
	Layout.fillHeight: true
	Layout.minimumWidth: myLabel.implicitWidth + 5

	// Stores status of fetch process
	property bool btcReady: false
	property bool btcfeeReady: false
	property bool metalsReady: false
	property bool dataReadyFull: false
	property int dataReadyAttemp: 0

	// Stores fetched data
	property variant btcData: [0.0]
	property variant btcfeeData: [0.0]
	property variant metalsData: [0.0,0.0,0.0]

	// Global vars from config
	property bool appletColor: plasmoid.configuration.appletColor
	property bool showBTC: plasmoid.configuration.showBTC
	property bool showBTCTT: plasmoid.configuration.showBTCTT
	property bool showBTCFee: plasmoid.configuration.showBTCFee
	property bool showBTCFeeTT: plasmoid.configuration.showBTCFeeTT
	property bool showMetals: plasmoid.configuration.showMetals
	property bool showMetalsTT: plasmoid.configuration.showMetalsTT
	property bool showStack: plasmoid.configuration.showStack
	property string stackSymbol: plasmoid.configuration.stackSymbol
	property string appletSymbol: plasmoid.configuration.appletSymbol
	property string curSymbol: plasmoid.configuration.curSymbol
	property string minorcurSymbol: plasmoid.configuration.minorcurSymbol
	property string btcSymbol: plasmoid.configuration.btcSymbol
	property string satsSymbol: plasmoid.configuration.satsSymbol
	property string auSymbol: plasmoid.configuration.auSymbol
	property string agSymbol: plasmoid.configuration.agSymbol
	property int btcStack: plasmoid.configuration.btcStack
	property int auStack: plasmoid.configuration.auStack
	property int agStack: plasmoid.configuration.agStack
	property int btcCost: plasmoid.configuration.btcCost
	property int capGain: plasmoid.configuration.capGain
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
			console.log("finstats::*::clicked-start-refresh-data")

			// Change applet color if needed
			if (appletColor) myLabel.color = Theme.disabledTextColor

			// Send fetch requests, reset attempt counter and reset/enable data ready timer
			refreshTimer.interval = timeRefresh * 60 * 1000
			dataReadyAttemp = 0
			fetchData()
			datareadyWait.running = true
			console.debug("finstats::*::clicked--stop-timer-restart")
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
				( (btcReady    && (btcData[0]    > (1/100000000))) || (!showBTC    && !showBTCTT)    ) &&
				( (btcfeeReady && (btcfeeData[0] > (1/100000000))) || (!showBTCFee && !showBTCFeeTT) ) &&
				( (metalsReady && (metalsData[0] > (1/100000000))) || (!showMetals && !showMetalsTT) ) &&
				( (metalsReady && (metalsData[1] > (1/100000000))) || (!showMetals && !showMetalsTT) ) )
			{
				console.debug("finstats::timerTriggered::Build:",
					"dataReadyAttemp:", dataReadyAttemp, "dataReadyFull:", dataReadyFull,
					"datareadyWait.running:", datareadyWait.running,
					"showBTC:", showBTC, "showBTCFee:", showBTCFee, "showMetals:", showMetals,
					"showBTCTT:", showBTCTT, "showBTCFeeTT:", showBTCFeeTT, "showMetalsTT:", showMetalsTT,
					"btcReady:", btcReady, "btcfeeReady:",  btcfeeReady, "metalsReady:", metalsReady,
					"btcData[0]:", btcData[0], "btcfeeData[0]:", btcfeeData[0],
					"metalsData[0]:", metalsData[0], "metalsData[1]:", metalsData[1])

				// Disable timer to avoid duplicate calls
				datareadyWait.running = false

				// Once all data fetched, build label
				dataReadyFull = true
				buildData()
				if (appletColor) colorFeedback.restart()
			} else {
				console.debug("finstats::timerTriggered::Attempt:",
					"dataReadyAttemp:", dataReadyAttemp, "dataReadyFull:", dataReadyFull,
					"datareadyWait.running:", datareadyWait.running,
					"showBTC:", showBTC, "showBTCFee:", showBTCFee, "showMetals:", showMetals,
					"showBTCTT:", showBTCTT, "showBTCFeeTT:", showBTCFeeTT, "showMetalsTT:", showMetalsTT,
					"btcReady:", btcReady, "btcfeeReady:",  btcfeeReady, "metalsReady:", metalsReady,
					"btcData[0]:", btcData[0], "btcfeeData[0]:", btcfeeData[0],
					"metalsData[0]:", metalsData[0], "metalsData[1]:", metalsData[1])

				// Disable full readiness until result are ready
				dataReadyFull = false

				// Not all data is ready, invalid results or duplicate call
				dataReadyAttemp++
			}

			// Retry 3 times and if still failed, set refresh timer as configured
			if (dataReadyAttemp > 2) {
				console.log("finstats::timerTriggered::LastAttemp::", "timeRetry:", timeRetry, "refreshTimer.interval:" , refreshTimer.interval)
				running = false
				refreshTimer.interval = timeRefetch * 60 * 1000

				// After max retries, call partial build
				dataReadyFull = false
				buildData()
				if (appletColor) colorFeedback.restart()
			}
		}
	}

	function buildData() {
		console.log("finstats::*::buildData::dataReadyFull:", dataReadyFull)

		// Get current date and time
		var currentTime = new Date()
		// Format date and time for display
		var formattedDate = Qt.formatDateTime(currentTime, "yyyy-MM-dd")
		var formattedTime = Qt.formatDateTime(currentTime, "hh:mm")
		var refreshTime = new Date(currentTime.getTime() + refreshTimer.interval)
		var formattedRefresh = Qt.formatDateTime(refreshTime, "hh:mm")

		// Calculate BTCFee
		var btcStdFee = (( (btcfeeData[0] < 1) && (btcfeeData[0] > 0) ) ? 1 : btcfeeData[0]) * 141 // vBytes for segwit 1 in 2 out Tx
		var btcStdFeePrice = btcStdFee / 100000000 * btcData[0] // Price per Tx in currency

		// Initialize applet and tooltip strings (unicode symbols collection Ⓑ₿Ș$≐🜚🜛· ∣│◕ │ )
		var ttStr = ""
		var aStr = ""

		// Add BTC to applet
		if (showBTC) {
			aStr = ((btcData[0] > priceDivider) ? (btcData[0] / priceDivider) : btcData[0]).toFixed(decPlaces)
		}

		// Add BTC fee to applet
		if (showBTCFee) {
			aStr += ((aStr.length > 0) ? " │ " : "") + ((btcStdFeePrice < 1) ? (btcStdFeePrice * 100).toFixed(0) : btcStdFeePrice.toFixed(decPlacesTT))
		}

		// Add metals to applet
		if (showMetals) {
			aStr += ((aStr.length > 0) ? " │ " : "") + ((metalsData[0] > priceDivider) ? (metalsData[0] / priceDivider) : metalsData[0]).toFixed(decPlaces)
			aStr += " │ " + ((metalsData[1] > priceDivider) ? (metalsData[1] / priceDivider) : metalsData[1]).toFixed(decPlaces)
			aStr += " │ " + (metalsData[2]).toFixed(decPlaces)
		}

		myLabel.text = (aStr.length > 0) ? aStr : curSymbol
		console.log("finstats::*::applet-ready::myLabel.text:", myLabel.text)

		// Start tooltip with timestamp and markdown table header
		ttStr += "| 🗓️ | " + formattedDate + " | ⏱ | " + formattedTime + " |\n"
		ttStr += "| :--- | :--- | :--- | :--- |\n"

		// Add BTC totooltip
		if (showBTCTT) {
			ttStr += "| **" + btcSymbol + (btcReady ? "" : "<sup>⚠️</sup>") + "** | " + (btcData[0]).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
		}

		// Add BTC Fee to tooltip
		if (showBTCFeeTT) {
			ttStr += " | **" + btcSymbol + "<sub>Fee</sub>" + (btcfeeReady ? "" : "<sup>⚠️</sup>") + "** | " + btcStdFee + "<sup>" + satsSymbol + "</sup>"
			ttStr += " / " + ((btcStdFeePrice < 1) ? (btcStdFeePrice * 100).toFixed(0) : btcStdFeePrice.toFixed(decPlacesTT)) + "<sup>" + ((btcStdFeePrice < 1) ? minorcurSymbol : curSymbol) + "</sup> |"
		}
		if (showBTCTT || showBTCFeeTT) ttStr += "\n"

		// Add metals to tooltip
		if (showMetalsTT) {
			ttStr += "| **" + auSymbol + (metalsReady ? "" : "<sup>⚠️</sup>") + "** | " + (metalsData[0]).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " | **" + agSymbol + (metalsReady ? "" : "<sup>⚠️</sup>") + "** | " + (metalsData[1]).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " |\n"

			if (showBTC || showBTCTT) ttStr += "| **" + btcSymbol + "/" + auSymbol + "** | " + ( ((btcData[0] > 0) && (metalsData[0] > 0) ) ? btcData[0]/metalsData[0] : 0).toFixed(decPlacesTT)
			ttStr += " | **" + auSymbol + "/" + agSymbol + "** | " + (metalsData[2]).toFixed(decPlacesTT)
			ttStr += " |\n"
		}

		// Add stack to tooltip
		if (showStack) {
			// Calculate stack
			var btcTax = (((btcData[0] * btcStack) - (btcCost * btcStack)) / 100 * capGain)
			var btcNet = ((btcData[0] * btcStack) - ((btcTax < 0) ? 0 : btcTax))
			var auNet = (metalsData[0] * auStack)
			var agNet = (metalsData[1] * agStack)

			if (showMetalsTT) {
				ttStr += "| **" + stackSymbol + auSymbol + "** | " + (auNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
				ttStr += " | **" + stackSymbol + agSymbol + "** | " + (agNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
				ttStr += " |\n"
			}

			if (showBTC || showBTCTT) ttStr += "| **" + stackSymbol + btcSymbol + "** | " + (btcNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " | **" + stackSymbol + "<sub>Total</sub>** | " + ( ((showBTC || showBTCTT) ? btcNet : 0) + auNet + agNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " |\n"
		}

		// Finalize the tooltip
		if (!dataReadyFull) ttStr += "*⚠️ Error during last update*\n"
		ttStr += "*Next update at " +  formattedRefresh + " (click for now)*\n"

		toolTip.subText = ttStr
		console.log("finstats::*::tooltip-ready::toolTip.subText:", toolTip.subText)
	}

	// Initiate fetch requests
	function fetchData() {
		var userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0esr) Gecko/20100101 Firefox/140.0esr"
		var btcPaths = [ btcKey ]
		var btcfeePaths = [ btcfeeKey ]
		var metalsPaths = []
		if (metalsKeyAu.length > 0) metalsPaths.push(metalsKeyAu)
		if ((metalsKeyAg.length > 0) && (metalsKeyAu != metalsKeyAg)) metalsPaths.push(metalsKeyAg)
		var metalsSuffs = []
		if (metalsSuffAu.length > 0) metalsSuffs.push(metalsSuffAu)
		if ((metalsSuffAg.length > 0) && (metalsSuffAu != metalsSuffAg)) metalsSuffs.push(metalsSuffAg)
		console.debug("finstats::fetchdata:", "btcPaths:", btcPaths, "btcfeePaths", btcfeePaths, "metalsPaths", metalsPaths, "metalsSuffs", metalsSuffs)

		var btcXhr = new XMLHttpRequest()
		btcXhr.onreadystatechange = function() {
			// Fetch BTC
			if (btcXhr.readyState === XMLHttpRequest.DONE) {
				if (btcXhr.status === 200) {
					try {
						// Parse response
						for (var y = 0; y < btcPaths.length; y++) {
							var data = JSON.parse(btcXhr.responseText)
							var keys = btcPaths[y].split(".")
							console.debug("finstats::BTC::PreParsing::data:", data, "y:", y, "keys:", keys)
							for (var x = 0; x < keys.length; x++) {
								console.debug("finstats::BTC::Parsing::x:", x, "btcPaths[y]:", btcPaths[y], "keys[x]:", keys[x], "data[keys[x]]:", data[keys[x]])
								if (typeof data[keys[x]] != 'undefined' ) {
									// Signal data is ready (first hit is a must)
									if (x == 0) btcReady = true
									// Save filtered value
									btcData[y] = parseFloat(data[keys[x]])
								} else {
									console.debug("finstats::BTC::Parsing::undefined")
									// Fail parsing
									btcReady = false
								}
							}

							console.debug("finstats::BTC::PostParsing::y:", y, "data:", data)
						}
					} catch (e) {
						console.error("finstats::BTC::JSON parsing error:", e)
					}
				} else {
					console.error("finstats::BTC::HTTP Error::btcXhr.status:", btcXhr.status)
				}

				console.log("finstats::BTC::PostFetch::btcReady:", btcReady)
			} else {
				console.debug("finstats::BTC::readyStatus::btcXhr.readyState:", btcXhr.readyState)
			}
		}

		var btcfeeXhr = new XMLHttpRequest()
		btcfeeXhr.onreadystatechange = function() {
			// Fetch BTC Fee
			if (btcfeeXhr.readyState === XMLHttpRequest.DONE) {
				if (btcfeeXhr.status === 200) {
					try {
						// Parse response
						for (var y = 0; y < btcfeePaths.length; y++) {
							var data = JSON.parse(btcfeeXhr.responseText)
							var keys = btcfeePaths[y].split(".")
							console.debug("finstats::BTCFee::PreParsing::data:", data, "y", y, "keys", keys)
							for (var x = 0; x < keys.length; x++) {
								console.debug("finstats::BTCFee::Parsing::x:", x, "btcfeePaths[y]:", btcfeePaths[y], "keys[x]", keys[x], "data[keys[x]]:", data[keys[x]])
								if (typeof data[keys[x]] != 'undefined' ) {
									// Signal data is ready (first hit is a must)
									if (x == 0) btcfeeReady = true
									// Save filtered value
									btcfeeData[y] = parseFloat(data[keys[x]])
								} else {
									console.debug("finstats::BTCFee::Parsing::undefined")
									// Fail parsing
									btcfeeReady = false
								}
							}

							console.debug("finstats::BTCFee::PostParsing::x:", y, "data:", data)
						}
					} catch (e) {
						console.error("finstats::BTCFee::JSON parsing error:", e)
					}
				} else {
					console.error("finstats::BTCFee::HTTP Error::btcfeeXhr.status:", btcfeeXhr.status)
				}

				console.log("finstats::BTCFee::PostFetch::btcfeeReady:", btcfeeReady)
			} else {
				console.debug("finstats::BTCFee::readyStatus::btcfeeXhr.readyState:", btcfeeXhr.readyState)
			}
		}

		function fetchMetals (xhdr) {
			// Fetch Metals
			if (xhdr.readyState === XMLHttpRequest.DONE) {
				if (xhdr.status === 200) {
					try {
						// Parse response
						for (var y = 0; y < metalsPaths.length; y++) {
							var data = JSON.parse(xhdr.responseText)
							var keys = metalsPaths[y].split(".")
							console.debug("finstats::Metals::PreParsing:", data, y, keys)
							for (var x = 0; x < keys.length; x++) {
								console.debug("finstats::Metals::Parsing::x:", x, "metalsPaths[y]:", metalsPaths[y], "keys[x]:", keys[x], "data[keys[x]]:", data[keys[x]])
								if (typeof data[keys[x]] != 'undefined' ) {
									// Signal data is ready (first hit is a must)
									if (x == 0) metalsReady = true
									var suffUsed = false

									// Check if data contains suffix symbol
									for (var z = 0; z < metalsSuffs.length; z++) {
										if ( (typeof data["symbol"] != 'undefined' ) && (data["symbol"] == metalsSuffs[z]) ){
											console.debug("finstats::Metals::Parsing::z:", z, "data[\"symbol\"]", data["symbol"], "metalsSuffs[z]:", metalsSuffs[z], "keys[x]:", keys[x], "data[keys[x]]:", data[keys[x]])											// Indicate suffix used and save filtered value
											metalsData[z] = parseFloat(data[keys[x]])
											suffUsed = true
										} else {
											console.debug("finstats::Metals::Parsing::z:error", z, "metalsSuffs[z]:", metalsSuffs[z], "keys[x]:", keys[x], "data[keys[x]]:", data[keys[x]])
										}
									}

									// Save filtered value if suffix not used above
									if (!suffUsed) metalsData[y] = parseFloat(data[keys[x]])
								} else {
									console.debug("finstats::Metals::Parsing::undefined")
									// Fail parsing
									metalsReady = false
								}
							}
							// Add metals ratio if possible
							metalsData[2] = (((metalsData[0] > 0) && (metalsData[1] > 0)) ? (metalsData[0]/metalsData[1]) : 0)
							console.debug("finstats::Metals::PostParsing:", y, data)
						}
					} catch (e) {
						console.error("finstats::Metals::JSONParsingError:", e)
					}
				} else {
					console.error("finstats::Metals::HTTP Error:", xhdr.status)
				}

				console.log("finstats::Metals::PostFetch::metalsReady:", metalsReady)
			} else {
				console.debug("finstats::Metals::readyStatus:", xhdr.readyState)
			}
		}

		var metalsXhr1 = new XMLHttpRequest()
		metalsXhr1.onreadystatechange = function() {
			fetchMetals(metalsXhr1)
		}

		var metalsXhr2 = new XMLHttpRequest()
		metalsXhr2.onreadystatechange = function() {
			fetchMetals(metalsXhr2)
		}

		// Reset results readiness and que fetch requests
		if (showBTC || showBTCTT) {
			btcReady = false
			btcXhr.open("GET", btcUrl, true)
			btcXhr.setRequestHeader('User-Agent', userAgent)
			btcXhr.timeout = timeRetry * 1000
			btcXhr.send()
		}

		if (showBTCFee || showBTCFeeTT) {
			btcfeeReady = false
			btcfeeXhr.open("GET", btcfeeUrl, true)
			btcfeeXhr.setRequestHeader('User-Agent', userAgent)
			btcfeeXhr.timeout = timeRetry * 1000
			btcfeeXhr.send()
		}

		if (showMetals || showMetalsTT) {
			metalsReady = false
			if ((metalsSuffAu.length > 0) && (metalsSuffAg.length > 0)) {
				console.debug("finstats::Metals::send::multi::Au:", metalsSuffAu)
				metalsXhr1.timeout = timeRetry * 1000
				metalsXhr1.open("GET", metalsUrl + metalsSuffAu, true)
				metalsXhr1.setRequestHeader('User-Agent', userAgent)
				metalsXhr1.send()
				console.debug("finstats::Metals::send::multi::Ag:", metalsSuffAg)
				metalsXhr2.timeout = timeRetry * 1000
				metalsXhr2.open("GET", metalsUrl + metalsSuffAg, true)
				metalsXhr2.setRequestHeader('User-Agent', userAgent)
				metalsXhr2.send()
			} else {
				console.debug("finstats::Metals::send::single::")
				metalsXhr1.timeout = timeRetry * 1000
				metalsXhr1.open("GET", metalsUrl, true)
				metalsXhr1.setRequestHeader('User-Agent', userAgent)
				metalsXhr1.send()
			}
		}
	}
}
