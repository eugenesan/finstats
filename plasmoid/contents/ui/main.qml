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
	property bool metalsReady: false
	property bool btcReady: false
	property bool btcfeeReady: false
	property int dataReadyAttemp: 0
	property bool dataReadyFull: false

	// Stores fetched data
	property variant metalsData: [0.0,0.0]
	property variant btcData: [0.0]
	property variant btcfeeData: [0.0]

	// Global vars from config
	property bool showStack: plasmoid.configuration.showStack
	property bool showMetals: plasmoid.configuration.showMetals
	property bool showBTCFee: plasmoid.configuration.showBTCFee
	property string stackSymbol: plasmoid.configuration.stackSymbol
	property string curSymbol: plasmoid.configuration.curSymbol
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
			console.log("finstats::*::clicked-refresh-data");
			myLabel.color = Theme.highlightColor
			// Restore configured refresh interval and attempt counter in case they were affected by datareadyWait
			refreshTimer.interval = timeRefresh * 60 * 1000
			dataReadyAttemp = 0
			fetchData()
			// Once fetch requests were sent, enable data ready timer
			datareadyWait.running = true
			console.debug("finstats::*::clicked-timer-reset");
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
		id: priceFlash
		target: myLabel
		property: "color"
		from: Theme.highlightColor
		to: (dataReadyFull) ? Theme.textColor : Theme.negativeTextColor
		duration: 1000
	}

	Component.onCompleted: {
		myLabel.text = "... │ ..."
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
			console.debug("finstats::refreshTimer::triggered:");
			myLabel.color = Theme.highlightColor
			// Restore configured interval in case it was shortened by datareadyWait
			interval = timeRefresh * 60 * 1000
			fetchData()
			// Once fetch requests were sent, enable data ready timer
			datareadyWait.running = true
			dataReadyAttemp = 0
		}
	}

	// Wait for data to be fetched and build applet/tooltip text
	Timer {
		id: datareadyWait
		interval: timeRetry * 1000
		running: true
		repeat: true

		onTriggered: {
			// Check if all the results marked as fetched and dataready timer still enabled
			if ( datareadyWait.running &&
				(btcReady || (btcData[0] > (1/100000000))) &&
				(btcfeeReady || (btcfeeData[0] > (1/100000000))) &&
				(metalsReady || (metalsData[0] > (1/100000000))) &&
				(metalsReady || (metalsData[1] > (1/100000000))) )
			{
				// Disable timer to avoid duplicate calls
				datareadyWait.running = false

				console.debug("finstats::timerTriggered::Build:", dataReadyAttemp, datareadyWait.running, metalsReady, btcReady, btcfeeReady, btcData[0], btcfeeData[0], metalsData[0], metalsData[1])

				// Once all data fetched, build label
				dataReadyFull = true
				buildData()
				priceFlash.restart()
			} else {
				// Not all data is ready, invalid results or duplicate call
				dataReadyAttemp++
				console.debug("finstats::timerTriggered::Attempt:", dataReadyAttemp, datareadyWait.running, metalsReady, btcReady, btcfeeReady, btcData[0], btcfeeData[0], 	metalsData[0], metalsData[1])

			}

			// Retry 3 times and if still failed, set refresh timer as configured
			if (dataReadyAttemp > 3) {
				console.log("finstats::dataready::lastattemp", timeRetry, refreshTimer.interval)
				running = false
				refreshTimer.interval = timeRefetch * 60 * 1000

				// After max retries, call partial build
				dataReadyFull = false
				buildData()
				priceFlash.restart()
			}
		}
	}

	function buildData() {
		console.log("finstats::*::buildData:", dataReadyFull)

		// Get current date and time
		var currentTime = new Date()
		// Format date and time for display
		var formattedDate = Qt.formatDateTime(currentTime, "yyyy-MM-dd")
		var formattedTime = Qt.formatDateTime(currentTime, "hh:mm")
		var refreshTime = new Date(currentTime.getTime() + refreshTimer.interval)
		var formattedRefresh = Qt.formatDateTime(refreshTime, "hh:mm")

		var ttStr = ""
		var btcStdFee = (( (btcfeeData[0] < 1) && (btcfeeData[0] > 0) ) ? 1 : btcfeeData[0]) * 141 // vBytes for segwit 1 in 2 out Tx
		var btcStdFeePrice = btcStdFee / 100000000 * btcData[0]  // price per Tx in currency

		// Build panel applet text (unicode symbols collection Ⓑ₿Ș$≐🜚🜛· ∣│◕)
		myLabel.text  = (btcData[0]/priceDivider).toFixed(decPlaces) // + "k"

		if (showBTCFee) {
			//myLabel.text += " │ " + btcfeeData[0] // + "·" + satsSymbol + "/vKb"
		}

		if (showMetals) {
			myLabel.text += " │ " + (metalsData[0]/priceDivider).toFixed(decPlaces) // + "·" + auSymbol
			//myLabel.text += " │ " + (metalsData[1]).toFixed(decPlaces) // + "·" + agSymbol
			//myLabel.text += " │ " + (metalsData[0]/metalsData[1]).toFixed(decPlaces)
		}
		console.log("finstats::*::applet-ready:", myLabel.text)

		// Build tooltip text starting with timestamp
		ttStr += "| 🗓️ | " + formattedDate + " | ⏱ | " + formattedTime + " |\n"

		// Add markdown table
		ttStr += "| :--- | :--- | :--- | :--- |\n"

		// Add BTC
		ttStr += "| **" + btcSymbol + (btcReady ? "" : "<sup>⚠️</sup>") + "** | " + (btcData[0]).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"

		// Add BTC Fee
		if (showBTCFee) {
			ttStr += " | **" + btcSymbol + "<sub>Fee</sub>" + (btcfeeReady ? "" : "<sup>⚠️</sup>") + "** | " + btcStdFee + "<sup>" + satsSymbol + "</sup>"
			ttStr += " / " + btcStdFeePrice.toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
		} else {
			ttStr += " | |"
		}
		ttStr += " |\n"

		// Add metals
		if (showMetals) {
			ttStr += "| **" + auSymbol + (metalsReady ? "" : "<sup>⚠️</sup>") + "** | " + (metalsData[0]).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " | **" + agSymbol + (metalsReady ? "" : "<sup>⚠️</sup>") + "** | " + (metalsData[1]).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " |\n"

			ttStr += "| **" + btcSymbol + "/" + auSymbol + "** | " + (btcData[0]/metalsData[0]).toFixed(decPlacesTT)
			ttStr += " | **" + auSymbol + "/" + agSymbol + "** | " + (metalsData[0]/metalsData[1]).toFixed(decPlacesTT)
			ttStr += " |\n"
		}

		// Add stack
		if (showStack) {
			// Calculate stack
			var btcTax = (((btcData[0] * btcStack) - (btcCost * btcStack)) / 100 * capGain)
			var btcNet = ((btcData[0] * btcStack) - ((btcTax < 0) ? 0 : btcTax))
			var auNet = (metalsData[0] * auStack)
			var agNet = (metalsData[1] * agStack)

			if (showMetals) {
				ttStr += "| **" + stackSymbol + auSymbol + "** | " + (auNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
				ttStr += " | **" + stackSymbol + agSymbol + "** | " + (agNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
				ttStr += " |\n"
			}

			ttStr += "| **" + stackSymbol + btcSymbol + "** | " + (btcNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " | **" + stackSymbol + "<sub>Total</sub>** | " + (btcNet+auNet+agNet).toFixed(decPlacesTT) + "<sup>" + curSymbol + "</sup>"
			ttStr += " |\n"
		}

		// Finalize the tooltip
		if (!dataReadyFull) ttStr += "*⚠️ Error during last update*\n"
		ttStr += "*Next update at " +  formattedRefresh + " (click for now)*\n"

		toolTip.subText = ttStr
		console.log("finstats::*::tooltip-ready:", toolTip.subText)
	}

	// Initiate fetch requests
	function fetchData() {
		var metalsPaths = [ metalsKeyAu, metalsKeyAg ]
		var btcPaths = [ btcKey ]
		var btcfeePaths = [ btcfeeKey ]

		var mxhr = new XMLHttpRequest()
		mxhr.onreadystatechange = function() {
			// Fetch Metals
			if (mxhr.readyState === XMLHttpRequest.DONE) {
				if (mxhr.status === 200) {
					try {
						// Parse response
						for (var y = 0; y < metalsPaths.length; y++) {
							var data = JSON.parse(mxhr.responseText)
							var keys = metalsPaths[y].split(".");
							console.debug("finstats::Metals::PreParsing:", data, y, keys)
							for (var x = 0; x < keys.length; x++) {
								console.debug("finstats::Metals::Parsing:", x, metalsPaths[y], keys[x])
								data = data[keys[x]];
							}
							console.debug("finstats::Metals::PostParsing:", y, data)
							data = parseFloat(data)
							// Save filtered value
							metalsData[y] = data

							// Signal data is ready
							metalsReady = true
						}
					} catch (e) {
						console.error("finstats::Metals::JSONParsingError:", e)
					}
				} else {
					console.error("finstats::Metals::HTTP Error:", mxhr.status)
				}

				console.log("finstats::Metals::PostFetch:", metalsReady)
			} else {
				console.debug("finstats::Metals::readyStatus:", mxhr.readyState)
			}
		}

		var bxhr = new XMLHttpRequest()
		bxhr.onreadystatechange = function() {
			// Fetch BTC
			if (bxhr.readyState === XMLHttpRequest.DONE) {
				if (bxhr.status === 200) {
					try {
						// Parse response
						for (var y = 0; y < btcPaths.length; y++) {
							var data = JSON.parse(bxhr.responseText)
							var keys = btcPaths[y].split(".");
							console.debug("finstats::BTC::PreParsing:", data, y, keys)
							for (var x = 0; x < keys.length; x++) {
								console.debug("finstats::BTC::Parsing:", x, btcPaths[y], keys[x])
								data = data[keys[x]];
							}
							console.debug("finstats::BTC::PostParsing:", y, data)
							data = parseFloat(data)
							// Save filtered value
							btcData[y] = data

							// Signal data is ready
							btcReady = true
						}
					} catch (e) {
						console.error("finstats::BTC::JSON parsing error:", e)
					}
				} else {
					console.error("finstats::BTC::HTTP Error:", bxhr.status)
				}

				console.log("finstats::BTC::PostFetch:", btcReady)
			} else {
				console.debug("finstats::BTC::readyStatus:", bxhr.readyState)
			}
		}

		var fxhr = new XMLHttpRequest()
		fxhr.onreadystatechange = function() {
			// Fetch BTC Fee
			if (fxhr.readyState === XMLHttpRequest.DONE) {
				if (fxhr.status === 200) {
					try {
						// Parse response
						for (var y = 0; y < btcfeePaths.length; y++) {
							var data = JSON.parse(fxhr.responseText)
							var keys = btcfeePaths[y].split(".");
							console.debug("finstats::BTCFee::PreParsing:", data, y, keys)
							for (var x = 0; x < keys.length; x++) {
								console.debug("finstats::BTCFee::Parsing:", x, btcfeePaths[y], keys[x])
								data = data[keys[x]];
							}
							console.debug("finstats::BTCFee::PostParsing:", y, data)
							data = parseFloat(data)
							// Save filtered value
							btcfeeData[y] = data

							// Signal data is ready
							btcfeeReady = true
						}
					} catch (e) {
						console.error("finstats::BTCFee::JSON parsing error:", e)
					}
				} else {
					console.error("finstats::BTCFee::HTTP Error:", fxhr.status)
				}

				console.log("finstats::BTCFee::PostFetch:", btcfeeReady)
			} else {
				console.debug("finstats::BTCFee::readyStatus:", fxhr.readyState)
			}
		}

		// Reset results readiness and que fetch requests
		if (true) {
		btcReady = false
		bxhr.open("GET", btcUrl, true)
		bxhr.setRequestHeader('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0');
		bxhr.timeout = timeRetry * 1000;
		bxhr.send()
		} else {
			btcReady = true
			btcData[0] = 0.0
		}

		if (showMetals) {
			metalsReady = false
			mxhr.open("GET", metalsUrl, true)
			mxhr.setRequestHeader('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0');
			mxhr.timeout = timeRetry * 1000;
			mxhr.send()
		} else {
			metalsReady = true
			metalsData[0] = 0.0
			metalsData[1] = 0.0
		}

		if (showBTCFee) {
			btcfeeReady = false
			fxhr.open("GET", btcfeeUrl, true)
			fxhr.setRequestHeader('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0');
			fxhr.timeout = timeRetry * 1000;
			fxhr.send()
		} else {
			btcfeeReady = true
			btcfeeData[0] = 0.0
		}
	}
}
