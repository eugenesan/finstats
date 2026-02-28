/*
 * SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Financial Stats Applet for Plasma 6
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
	id: root

	signal configurationChanged

	property alias cfg_showBTC: showBTC.checked
	property alias cfg_showBTCTT: showBTCTT.checked
	property alias cfg_showBTCFee: showBTCFee.checked
	property alias cfg_showBTCFeeTT: showBTCFeeTT.checked
	property alias cfg_showMetals: showMetals.checked
	property alias cfg_showMetalsRatio: showMetalsRatio.checked
	property alias cfg_showMetalsTT: showMetalsTT.checked
	property alias cfg_showStack: showStack.checked

	ScrollView {
		width: parent.width
		height: parent.height

		ColumnLayout {
			GridLayout {
				id: gridLayout
				columns: 2

				// Show btc
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show BTC:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showBTC
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display BTC on Applet")
				}

				// Show btc tooltip
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show BTC tootltip:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showBTCTT
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display BTC on ToolTip")
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
					ToolTip.text: i18n("Wether to display BTC Fee on Applet")
				}

				// Show btcfee tooltip
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show BTC Fee tooltip:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showBTCFeeTT
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display BTC Fee on ToolTip")
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
					ToolTip.text: i18n("Wether to display metals on Applet")
				}

				// Show metals ratio on applet
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show Metals ratio:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showMetalsRatio
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display metals ratio on Applet")
				}

				// Show metals tooltip
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show Metals tooltip:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showMetalsTT
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display metals on ToolTip")
				}

				// Show stack
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Show Stack:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: showStack
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to display Stack on ToolTip")
				}
			}  // Closing GridLayout
		}      // Closing ColumnLayout
	}          // Closing ScrollView
}              // Closing Item
