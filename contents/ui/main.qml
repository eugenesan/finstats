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
*
* TODO: Enable tooltips
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
	//Layout.minimumHeight: 30
	property bool metalsReady: false
	property bool btcReady: false
	property bool btcfeeReady: false
	property variant metalsData: [0,0]
	property variant btcData: [0]
	property variant btcfeeData: [0]

	/*
	toolTipTextFormat: Text.RichText
	toolTipMainText: i18n("My Applet Title")
	toolTipSubText: i18n("This is a description of my applet.")
	*/

	MouseArea {
		// Refresh the label and reset time on mouse click
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton
		onClicked: (mouse) => {
			console.log("finstats::*::clicked-fetch-data");
			text: "...k·. ..../..·.."
			fetchData()
			// Once fetch requests were sent, enable data ready timer
			datareadyWait.running = true
			console.log("finstats::*::clicked-timer-reset");
			refreshTimer.restart()
		}
		/*
		hoverEnabled: true
		onEntered: console.log("finstats::*::hover-enter");
		onExited: console.log("finstats::*::hover-exit");
		*/
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

	// Refresh applet every 15 minutes
	Timer {
		id: refreshTimer
		interval: 15 * 60 * 1000
		running: true
		repeat: true
		onTriggered: {
			fetchData()
			// Once fetch requests were sent, enable data ready timer
			datareadyWait.running = true
		}
	}

	// Wait for all data be fetched
	Timer {
		id: datareadyWait
		interval: 500
		running: true
		repeat: true
		onTriggered: {
			console.log("finstats::BTC::status:", root.metalsReady, root.btcReady, root.btcfeeReady)
			if (( root.metalsReady == root.btcReady == root.btcfeeReady == true ) && ( datareadyWait.running == true )) {
				// Once all data fetched, build label
				console.log("finstats::*::building-label:", datareadyWait.running)
				// Disable timer to avoid duplicate calls
				datareadyWait.running = false
				// Unicode symbols collection Ⓑ₿Ș$≐🜚🜛·
				myLabel.text = /*"₿" + */ JSON.stringify(Math.round(root.btcData[0]/1000)) + "k";
				myLabel.text += "·" + JSON.stringify(Math.round(root.btcfeeData[0]))// + "Ș";
				myLabel.text += " " + JSON.stringify(Math.round(root.metalsData[0]))// + "🜚";
				myLabel.text += "/" + JSON.stringify(Math.round(root.metalsData[1]))// + "🜛";
				myLabel.text += "·" + JSON.stringify(Math.round(root.metalsData[0]/root.metalsData[1]));
				console.log("finstats::*::label-ready:", myLabel.text)
			} else {
				// Not all data is ready or duplicate call
				console.log("finstats::*::skipping-build:", datareadyWait.running)
			}
		}
	}

	Component.onCompleted: {
		myLabel.text = "...k·. ..../..·.."
		fetchData()

		// Resume monitoring data ready
		datareadyWait.running = true
	}

	function fetchData() {
		var urls = [ "https://data-asg.goldprice.org/dbXRates/USD", "https://mempool.space/api/v1/prices",
						"https://mempool.space/api/v1/fees/recommended" ]
		var metalsPaths = [ "items.0.xauPrice", "items.0.xagPrice" ];
		var btcPaths = [ "USD" ]
		var btcfeePaths = [ "economyFee" ] //"fastestFee":6,"halfHourFee":5,"hourFee":4,"economyFee":2,"minimumFee":1
		myLabel.text = ""

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
							data = Math.round(parseInt(data))
							// Save filtered value
							root.metalsData[y] = JSON.stringify(data)
						}
					} catch (e) {
						console.log("finstats::Metals::JSON parsing error:", e)
					}
				} else {
					console.log("finstats::Metals::HTTP Error:", mxhr.status)
				}

				// Signal data is ready
				root.metalsReady = true
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
							data = Math.round(parseInt(data))
							// Save filtered value
							root.btcData[y] = JSON.stringify(data)
						}
					} catch (e) {
						console.log("finstats::BTC::JSON parsing error:", e)
					}
				} else {
					console.log("finstats::BTC::HTTP Error:", bxhr.status)
				}

				// Signal data is ready
				root.btcReady = true
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
							data = Math.round(parseInt(data))
							// Save filtered value
							root.btcfeeData[y] = JSON.stringify(data)
						}
					} catch (e) {
						console.log("finstats::BTCFee::JSON parsing error:", e)
					}
				} else {
					console.log("finstats::BTCFee::HTTP Error:", fxhr.status)
				}

				// Signal data is ready
				root.btcfeeReady = true
			}
		}

		bxhr.open("GET", urls[1], true)
		bxhr.timeout = 2000;
		bxhr.send()

		fxhr.open("GET", urls[2], true)
		fxhr.timeout = 2000;
		fxhr.send()

		mxhr.open("GET", urls[0], true)
		mxhr.timeout = 2000;
		mxhr.send()
	}
}
