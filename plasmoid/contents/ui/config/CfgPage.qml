/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Base of all settings pages.
 *
 * Plasma sets every cfg_<key> and cfg_<key>Default property of main.xml on each page it opens.
 * Declaring them all here (once) keeps the pages small and avoids the
 * "Setting initial properties failed: ... does not have a property called cfg_..." warnings.
 */
import QtQuick
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property bool cfg_showBTC
    property bool cfg_showBTCDefault
    property bool cfg_showBTCTT
    property bool cfg_showBTCTTDefault
    property bool cfg_showBTCFee
    property bool cfg_showBTCFeeDefault
    property bool cfg_showBTCFeeTT
    property bool cfg_showBTCFeeTTDefault
    property bool cfg_showMetals
    property bool cfg_showMetalsDefault
    property bool cfg_showMetalsRatio
    property bool cfg_showMetalsRatioDefault
    property bool cfg_showMetalsTT
    property bool cfg_showMetalsTTDefault
    property bool cfg_showStack
    property bool cfg_showStackDefault
    property bool cfg_showBTCTip
    property bool cfg_showBTCTipDefault
    property bool cfg_showBTCFeeTip
    property bool cfg_showBTCFeeTipDefault
    property bool cfg_showMetalsTip
    property bool cfg_showMetalsTipDefault
    property bool cfg_showStackTip
    property bool cfg_showStackTipDefault
    property bool cfg_appletColor
    property bool cfg_appletColorDefault
    property string cfg_appletSymbol
    property string cfg_appletSymbolDefault
    property string cfg_stackSymbol
    property string cfg_stackSymbolDefault
    property string cfg_curSymbol
    property string cfg_curSymbolDefault
    property string cfg_minorcurSymbol
    property string cfg_minorcurSymbolDefault
    property string cfg_btcSymbol
    property string cfg_btcSymbolDefault
    property string cfg_satsSymbol
    property string cfg_satsSymbolDefault
    property string cfg_auSymbol
    property string cfg_auSymbolDefault
    property string cfg_agSymbol
    property string cfg_agSymbolDefault
    property string cfg_warnSymbol
    property string cfg_warnSymbolDefault
    property string cfg_delimSymbol
    property string cfg_delimSymbolDefault
    property int cfg_decPlaces
    property int cfg_decPlacesDefault
    property int cfg_decPlacesTT
    property int cfg_decPlacesTTDefault
    property int cfg_priceDivider
    property int cfg_priceDividerDefault
    property int cfg_timeRefresh
    property int cfg_timeRefreshDefault
    property int cfg_timeDataReady
    property int cfg_timeDataReadyDefault
    property int cfg_timeRefetch
    property int cfg_timeRefetchDefault
    property string cfg_cacheJson
    property string cfg_cacheJsonDefault
    property string cfg_btcUrl
    property string cfg_btcUrlDefault
    property string cfg_btcKey
    property string cfg_btcKeyDefault
    property string cfg_btcfeeUrl
    property string cfg_btcfeeUrlDefault
    property string cfg_btcfeeKey
    property string cfg_btcfeeKeyDefault
    property string cfg_metalsUrl
    property string cfg_metalsUrlDefault
    property string cfg_metalsSuffAu
    property string cfg_metalsSuffAuDefault
    property string cfg_metalsSuffAg
    property string cfg_metalsSuffAgDefault
    property string cfg_metalsKeyAu
    property string cfg_metalsKeyAuDefault
    property string cfg_metalsKeyAg
    property string cfg_metalsKeyAgDefault
    property string cfg_btcStack
    property string cfg_btcStackDefault
    property string cfg_btcCost
    property string cfg_btcCostDefault
    property int cfg_capGainBTC
    property int cfg_capGainBTCDefault
    property int cfg_auStack
    property int cfg_auStackDefault
    property int cfg_auSlip
    property int cfg_auSlipDefault
    property int cfg_agStack
    property int cfg_agStackDefault
    property int cfg_agSlip
    property int cfg_agSlipDefault
}
