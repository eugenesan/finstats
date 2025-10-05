/*
* SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-SnippetComment: Financial Stats Applet for Plasma 6
* Debug:
*   systemctl --user restart plasma-plasmashell
*   plasmoidviewer --applet com.github.eugenesan.finstats
*   plasmawindowed com.github.eugenesan.finstats
*   plasmapkg2 -i .
*
* https://develop.kde.org/docs/plasma/widget/properties/
* https://develop.kde.org/docs/features/configuration/porting_kf6/
* https://develop.kde.org/docs/plasma/widget/testing/
*
* TODO: * Fix config page: Symbols: Strings -> Symbols?, Fix tooltips
*       * Try to align columns in tooltip?
*       * Split config page (too long?)
*       * Figure out why it complains about "Setting initial properties failed" on config page
*       * Purge unused *Status
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core
import org.kde.plasma.plasmoid
import org.kde.plasma.components

PlasmoidItem {
	id: root
	Layout.fillHeight: true
	Layout.minimumWidth: myLabel.implicitWidth + 10

	// Indicates if fetch finished
	property bool metalsReady: false
	property bool btcReady: false
	property bool btcfeeReady: false
	property int dataReadyAttemp: 0

	// Indicates if fetch was successful + error code
	//property variant metalsStatus: [0,0]
	//property variant btcStatus: [0,0]
	//property variant btcfeeStatus: [0,0]

	// Stores fetched data
	property variant metalsData: [0.0,0.0]
	property variant btcData: [0.0]
	property variant btcfeeData: [0.0]

	// Global vars from config
	property bool showStacks: plasmoid.configuration.showStacks
	property string stackSymbol: plasmoid.configuration.stackSymbol
	property string curSymbol: plasmoid.configuration.curSymbol
	property string btcSymbol: plasmoid.configuration.btcSymbol
	property string satSymbol: plasmoid.configuration.satSymbol
	property string auSymbol: plasmoid.configuration.auSymbol
	property string agSymbol: plasmoid.configuration.agSymbol
	property int btcStack: plasmoid.configuration.btcStack
	property int auStack: plasmoid.configuration.auStack
	property int agStack: plasmoid.configuration.agStack
	property int btcCost: plasmoid.configuration.btcCost
	property int capGain: plasmoid.configuration.capGain
	property int decPlaces: plasmoid.configuration.decPlaces
	property int decPlacesTT: plasmoid.configuration.decPlacesTT
	property int timeRefresh: plasmoid.configuration.timeRefresh

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
	}

	MouseArea {
		id: mouseAreaValue
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton
		// Refresh the label and reset time on mouse click
		onClicked: (mouse) => {
			console.log("finstats::*::clicked-fetch-data");
			// Restore configured refresh interval and attempt acounter in case it was shortened by datareadyWait
			refreshTimer.interval = timeRefresh * 60 * 1000
			dataReadyAttemp = 0
			fetchData()
			// Once fetch requests were sent, enable data ready timer
			datareadyWait.running = true
			console.log("finstats::*::clicked-timer-reset");
			refreshTimer.restart()
		}

		hoverEnabled: true
		onEntered: {
			toolTip.showToolTip()
			//console.log("finstats::*::hover-enter")
		}
		onExited: {
			toolTip.hideToolTip()
			//console.log("finstats::*::hover-exit")}
		}
	}

	ColumnLayout {
		// A simple label to display the JSON data
		Label {
			id: myLabel
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			//Layout.fillWidth: true
		}
	}

	Component.onCompleted: {
		myLabel.text = ".....·..."
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
			// Restore configured interval in case it was shortened by datareadyWait
			interval = timeRefresh * 60 * 1000
			fetchData()
			// Once fetch requests were sent, enable data ready timer
			datareadyWait.running = true
			dataReadyAttemp = 0
		}
	}

	// Wait for all data be fetched
	Timer {
		id: datareadyWait
		interval: 1000
		running: true
		repeat: true

		onTriggered: {
			// Get the current date and time
			var today = new Date();
			// Format the date and time for display
			var formattedDateTime = Qt.formatDateTime(today, "yyyy-MM-dd hh:mm:ss");
			var myTT_text = "<b>Date</b>: " + formattedDateTime;

			// Check if all the results marked as fetched and dataready timer still enabled
			if ( (datareadyWait.running == true) && (root.metalsReady == root.btcReady == root.btcfeeReady == true) &&
				 // Make sure none of the results are zero
				 (root.btcData[0]>0) && (root.btcfeeData[0]>0) && (root.metalsData[0]>0) && (root.metalsData[1]>0)
			   ) {
				// Once all data fetched, build label
				console.log("finstats::dataready::status:building-label", dataReadyAttemp, root.metalsReady, root.btcReady, root.btcfeeReady, root.btcData[0], root.btcfeeData[0], root.metalsData[0], root.metalsData[1])

				// Disable timer to avoid duplicate calls
				datareadyWait.running = false

				// Calculate stacks
				if (showStacks) {
					var btcNet = ((root.btcData[0] * (btcStack - (btcStack * (capGain/100)))) + (btcCost * (btcStack * (capGain/100))))
					var auNet = (root.metalsData[0] * auStack)
					var agNet = (root.metalsData[1] * agStack)
				}

				// Build panel view text. Unicode symbols collection Ⓑ₿Ș$≐🜚🜛·
				myLabel.text  = (root.btcData[0]/1000).toFixed(decPlaces) // + "k"
				//myLabel.text += "·" + root.btcfeeData[0] // + "·" + satSymbol + "/vKb"
				myLabel.text += "·" + (root.metalsData[0]/1000).toFixed(decPlaces) // + "·" + auSymbol
				//myLabel.text += "/" + root.metalsData[1]) // + "·" + agSymbol
				//myLabel.text += "·" + (root.metalsData[0]/root.metalsData[1]).toFixed(1)
				console.log("finstats::*::label-ready:", myLabel.text)

				// Build tooltip text
				myTT_text += "<br><b>" + btcSymbol + "</b>: "  + root.btcData[0] + "·" + curSymbol
				myTT_text += " | <b>" + satSymbol + "</b>: " + root.btcfeeData[0] + "·" + satSymbol + "/vKb"
				myTT_text += "<br><b>" + auSymbol + "</b>: " + root.metalsData[0] + "·" + curSymbol
				myTT_text += " | <b>" + agSymbol + "</b>: " + root.metalsData[1] + "·" + curSymbol
				myTT_text += " <b>[</b>" + (root.metalsData[0]/root.metalsData[1]).toFixed(decPlacesTT) + "<b>]</b>";
				if (showStacks) {
					myTT_text += "<br><b>" + auSymbol + "" + stackSymbol + "</b>: " + (auNet).toFixed(decPlacesTT) + "·" + curSymbol
					myTT_text += " | <b>" + agSymbol + "" + stackSymbol + "</b>: " + (agNet).toFixed(decPlacesTT) + "·" + curSymbol
					myTT_text += "<br><b>" + btcSymbol + "" + stackSymbol + "</b>: " + (btcNet).toFixed(decPlacesTT) + "·" + curSymbol
					myTT_text += " | <b>" + stackSymbol + "</b>: " + (btcNet+auNet+agNet).toFixed(decPlacesTT) + "·" + curSymbol
					console.log("finstats::*::tooltip-add-stacks:", myTT_text)
				} else {
					console.log("finstats::*::tooltip-skip-stacks:", myTT_text)
				}
				console.log("finstats::*::tooltip-ready:", myTT_text)
				toolTip.subText = myTT_text
			} else {
				// Not all data is ready, invalid results or duplicate call
				dataReadyAttemp++
				console.log("finstats::dataready::status:skipping-build", dataReadyAttemp, root.metalsReady, root.btcReady, root.btcfeeReady, root.btcData[0], root.btcfeeData[0], root.metalsData[0], root.metalsData[1])
			}

			// Retry 10 time and if still failed, set refresh timer to 5 minutes
			if (dataReadyAttemp > 10) {
				running = false
				refreshTimer.interval = 5 * 60 * 1000
				myTT_text += "<br>Failed to fetch, will retry in 5 minutes"
				toolTip.subText = myTT_text
				console.log("finstats::dataready::lastattemp")
			}
		}
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
							console.log("finstats::Metals::PreParsing:", data,y, keys)
							for (var x = 0; x < keys.length; x++) {
								console.log("finstats::Metals::Parsing:", x, metalsPaths[y], keys[x])
								data = data[keys[x]];
							}
							console.log("finstats::Metals::PostParsing:", y, data)
							data = parseInt(data)
							// Save filtered value
							root.metalsData[y] = data
						}
					} catch (e) {
						console.log("finstats::Metals::JSON parsing error:", e)
						//metalsStatus = [2, e]
					}
				} else {
					console.log("finstats::Metals::HTTP Error:", mxhr.status)
					//metalsStatus = [2, mxhr.status]
				}

				// Signal data is ready
				root.metalsReady = true
				//metalsStatus = [1, 0]
				console.log("finstats::Metals::PostFetch:Ready")
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
							console.log("finstats::BTC::PreParsing:", data, y, keys)
							for (var x = 0; x < keys.length; x++) {
								console.log("finstats::BTC::Parsing:", x, btcPaths[y], keys[x])
								data = data[keys[x]];
							}
							console.log("finstats::BTC::PostParsing:", y, data)
							data = parseInt(data)
							// Save filtered value
							root.btcData[y] = data
						}
					} catch (e) {
						console.log("finstats::BTC::JSON parsing error:", e)
						//btcStatus = [2, e]
					}
				} else {
					console.log("finstats::BTC::HTTP Error:", bxhr.status)
						//btcStatus = [2, bxhr.status]
				}

				// Signal data is ready
				root.btcReady = true
				//btcStatus = [1, 0]
				console.log("finstats::BTC::PostFetch:Ready")
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
							console.log("finstats::BTCFee::PreParsing:", data, y, keys)
							for (var x = 0; x < keys.length; x++) {
								console.log("finstats::BTCFee::Parsing:", x, btcfeePaths[y], keys[x])
								data = data[keys[x]];
							}
							console.log("finstats::BTCFee::PostParsing:", y, data)
							data = parseInt(data)
							// Save filtered value
							root.btcfeeData[y] = data
						}
					} catch (e) {
						console.log("finstats::BTCFee::JSON parsing error:", e)
						//btcfeeStatus = [2, e]
					}
				} else {
					console.log("finstats::BTCFee::HTTP Error:", fxhr.status)
					//btcfeeStatus = [2, fxhr.status]
				}

				// Signal data is ready
				root.btcfeeReady = true
				//btcfeeStatus = [1, 0]
				console.log("finstats::BTCFee::PostFetch:Ready")
			}
		}

		// Reset statuses and que fetches
		metalsReady = false
		//metalsStatus = [0,0]
		mxhr.open("GET", metalsUrl, true)
		mxhr.timeout = 3000;
		mxhr.send()

		btcReady = false
		//btcStatus = [0,0]
		bxhr.open("GET", btcUrl, true)
		bxhr.timeout = 3000;
		bxhr.send()

		btcfeeReady = false
		//btcfeeStatus = [0,0]
		fxhr.open("GET", btcfeeUrl, true)
		fxhr.timeout = 3000;
		fxhr.send()
	}
}
