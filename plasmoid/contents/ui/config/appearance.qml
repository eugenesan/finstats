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

	property alias cfg_appletColor: appletColor.checked
	property alias cfg_appletSymbol: appletSymbol.text
	property alias cfg_stackSymbol: stackSymbol.text
	property alias cfg_curSymbol: curSymbol.text
	property alias cfg_minorcurSymbol: minorcurSymbol.text
	property alias cfg_btcSymbol: btcSymbol.text
	property alias cfg_satsSymbol: satsSymbol.text
	property alias cfg_auSymbol: auSymbol.text
	property alias cfg_agSymbol: agSymbol.text
	property alias cfg_warnSymbol: warnSymbol.text
	property alias cfg_delimSymbol: delimSymbol.text
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

				// Applet color feedback
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Color fedback on change/errors:")
					horizontalAlignment: Label.AlignLeft
				}
				CheckBox {
					id: appletColor
					onCheckedChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Wether to color applet on change")
				}

				// Applet symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Applet symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: appletSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Default symbol for empty Applet")
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
					ToolTip.text: i18n("Which symbol to use for Stack")
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
					ToolTip.text: i18n("Which symbol to use for Currency")
				}

				// Minor Currency symbol (cents)
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Minor Currency symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: minorcurSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use for minor Currency (1/100th)")
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
					ToolTip.text: i18n("Which symbol to use for BTC")
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
					ToolTip.text: i18n("Which symbol to use for Satoshi")
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
					ToolTip.text: i18n("Which symbol to use for Gold")
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
					ToolTip.text: i18n("Which symbol to use for Silver")
				}

				// Warning symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Warning symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: warnSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use for Warning")
				}


				// Delimiter symbol
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Delimiter symbol:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: delimSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use as delimiter on applet")
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
					ToolTip.text: i18n("Decimal places for Applet")
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
					ToolTip.text: i18n("Decimal places for ToolTip")
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
					to: 100000
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Divider to apply to prices on appplet (applies only to 'greater than' values)")
				}
			}  // Closing GridLayout
		}      // Closing ColumnLayout
	}          // Closing ScrollView
}              // Closing Item
