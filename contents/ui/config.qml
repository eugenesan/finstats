/*
 * SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Financial Stats Applet for Plasma 6
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.11
import org.kde.kirigami as Kirigami

Item {
	id: root

	signal configurationChanged

	property alias cfg_showStacks: showStacks.checked
	property alias cfg_stackSymbol: stackSymbol.text
	property alias cfg_curSymbol: curSymbol.text
	property alias cfg_btcSymbol: btcSymbol.text
	property alias cfg_satSymbol: satSymbol.text
	property alias cfg_auSymbol: auSymbol.text
	property alias cfg_agSymbol: agSymbol.text
	property alias cfg_btcStack: btcStack.value
	property alias cfg_auStack: auStack.value
	property alias cfg_agStack: agStack.value
	property alias cfg_btcCost: btcCost.value
	property alias cfg_capGain: capGain.value
	property alias cfg_decPlaces: decPlaces.value
	property alias cfg_timeRefresh: timeRefresh.value

	ScrollView {
		width: parent.width
		height: parent.height

		ColumnLayout {
			//Layout.preferredWidth: parent.width - Kirigami.Units.largeSpacing * 2
			//Layout.minimumWidth: preferredWidth
			//Layout.maximumWidth: preferredWidth
			spacing: Kirigami.Units.smallSpacing * 3

			GridLayout {
				//Layout.preferredWidth: parent.width
				//Layout.minimumWidth: preferredWidth
				//Layout.maximumWidth: preferredWidth
				columns: 2

				// Show stacks
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Show Stacks:")
					horizontalAlignment: Label.AlignRight
				}
				CheckBox {
					id: showStacks
					text: i18n("ShowStacks")
				}

				// Stack symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Stack symbol:")
					horizontalAlignment: Label.AlignRight
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
					Layout.minimumWidth: root.width / 2
					text: i18n("Currency symbol:")
					horizontalAlignment: Label.AlignRight
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
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: btcSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate BTC")
				}

				// Sat symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Sat symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: satSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Satoshi")
				}

				// Au symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Au symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: auSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Gold")
				}

				// Ag symbol
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Ag symbol:")
					horizontalAlignment: Label.AlignRight
				}
				TextField {
					id: agSymbol
					text: "#000000"
					onTextChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Which symbol to use to indicate Silver")
				}

				// BTC size
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC stack size:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: btcStack
					to: 999
				}

				// Au size
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Au stack size:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: auStack
					to: 999
				}

				// Ag size
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Ag stack size:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: agStack
					to: 999
				}

				// BTC cost
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("BTC cost basis:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: btcCost
					to: 999999
				}

				// Cap gains
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Capital gains tax:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: capGain
					to: 99
				}

				// Decimal places
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Decimal places to display:")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					from: 0
					id: decPlaces
					to: 9
				}

				// Time Refresh
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Time Refresh (minutes):")
					horizontalAlignment: Label.AlignRight
				}
				SpinBox {
					id: timeRefresh
					from: 1
					to: 60
					stepSize: 1
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Minutes to refresh the coin value. Valid range: 1–60.")
				}

				// Applet version
				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("Financial Stats")
					horizontalAlignment: Label.AlignRight
				}

				Label {
					Layout.minimumWidth: root.width / 2
					text: i18n("v0.2 (2025-10-04)")
				}

			}  // Closing GridLayout
		}      // Closing ColumnLayout
	}          // Closing ScrollView
}              // Closing Item
