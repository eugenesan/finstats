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

	property alias cfg_btcStack: btcStack.text
	property alias cfg_btcCost: btcCost.text
	property alias cfg_auStack: auStack.value
	property alias cfg_agStack: agStack.value
	property alias cfg_capGain: capGain.value

	ScrollView {
		width: parent.width
		height: parent.height

		ColumnLayout {
			GridLayout {
				id: gridLayout
				columns: 2

				// BTC stack size
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC stack size:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcStack
					text: "0.0"
					ToolTip.visible: hovered
					ToolTip.text: i18n("Count of Bitcoin in the stack (0–999)")
					validator: DoubleValidator {
						bottom: 0.0
						top: 1000.0
						decimals: 6
					}
				}

				// BTC stack cost basis
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("BTC cost basis:")
					horizontalAlignment: Label.AlignLeft
				}
				TextField {
					id: btcCost
					text: "0.0"
					ToolTip.visible: hovered
					ToolTip.text: i18n("Bitcoin cost basis (0–1000000)")
					validator: DoubleValidator {
						bottom: 0.0
						top: 1000.0
						decimals: 6
					}
				}

				// Metals Au stack size
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Au stack size:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: auStack
					from: 0
					to: 999
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Count of Silver in the stack (0–999)")
				}

				// Metals Ag stack size
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Metals Ag stack size:")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: agStack
					from: 0
					to: 999
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Count of Silver in the stack (0–999)")
				}

				// Capital gains tax
				Label {
					Layout.minimumWidth: root.width / 3
					text: i18n("Capital gains tax (%):")
					horizontalAlignment: Label.AlignLeft
				}
				SpinBox {
					id: capGain
					from: 0
					to: 99
					onValueChanged: configurationChanged()
					ToolTip.visible: hovered
					ToolTip.text: i18n("Capital gains tax ammount (0–99)")
				}
			}  // Closing GridLayout
		}      // Closing ColumnLayout
	}          // Closing ScrollView
}              // Closing Item
