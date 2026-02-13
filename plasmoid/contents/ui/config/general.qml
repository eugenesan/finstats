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

	property alias cfg_appletFlash: appletFlash.checked
	property alias cfg_showMetals: showMetals.checked
	property alias cfg_showBTCFee: showBTCFee.checked
	property alias cfg_showStack: showStack.checked
	property alias cfg_stackSymbol: stackSymbol.text
	property alias cfg_curSymbol: curSymbol.text
	property alias cfg_btcSymbol: btcSymbol.text
	property alias cfg_satsSymbol: satsSymbol.text
	property alias cfg_auSymbol: auSymbol.text
	property alias cfg_agSymbol: agSymbol.text
	property alias cfg_decPlaces: decPlaces.value
	property alias cfg_decPlacesTT: decPlacesTT.value
	property alias cfg_priceDivider: priceDivider.value

	ScrollView {
		width: parent.width
		height: parent.height

		ColumnLayout {
			GridLayout {
				id: gridLayout
				columns: 2

				// Applet flash feedback
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Flash Applet on change:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: appletFlash
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to flash applet on chnage.")
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
					ToolTip.text: i18n("Wether to display stack summary in the ToolTip.")
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

				// Applet decimal places
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

				// ToolTip decimal places
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
			}  // Closing GridLayout
		}      // Closing ColumnLayout
	}          // Closing ScrollView
}              // Closing Item
