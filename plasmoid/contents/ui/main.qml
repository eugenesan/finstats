/*
 * SPDX-FileCopyrightText: Copyright 2025 Eugene San (eugenesan)
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Financial Stats Widget for Plasma 6
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import "../code/finlogic.js" as Logic

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration

    // ------------------------------------------------------------ state
    property var prices: ({ btc: 0, fee: 0, au: 0, ag: 0 })   // last good values
    property var okState: ({})        // source -> false when its last fetch failed
    property var errors: ({})         // source -> message of the last fetch
    property bool hasData: false
    property bool fetching: false
    property real lastCheck: 0        // ms since epoch
    property real nextRefresh: 0      // ms since epoch
    property real now: Date.now()     // ticks every few seconds, only while the tooltip/popup is visible
    property bool hovered: false
    property int revision: 0          // bumped when prices/errors change (the maps are mutated copies)
    property bool completed: false
    property int generation: 0        // invalidates callbacks of aborted fetches
    property var jobs: []
    property var batch: ({ prices: {}, errors: {} })

    readonly property bool wantBTC: cfg.showBTC || cfg.showBTCTT || cfg.showBTCTip
    readonly property bool wantFee: cfg.showBTCFee || cfg.showBTCFeeTT || cfg.showBTCFeeTip
    readonly property bool wantMetals: cfg.showMetals || cfg.showMetalsTT || cfg.showMetalsTip
    readonly property bool hasErrors: { revision; return Object.keys(errors).length > 0 }

    // Everything the display code needs, read here so bindings notice any change
    readonly property var viewCfg: ({
        showBTC: cfg.showBTC, showBTCTT: cfg.showBTCTT, showBTCFee: cfg.showBTCFee, showBTCFeeTT: cfg.showBTCFeeTT,
        showMetals: cfg.showMetals, showMetalsRatio: cfg.showMetalsRatio, showMetalsTT: cfg.showMetalsTT,
        showStack: cfg.showStack,
        stackSymbol: cfg.stackSymbol, curSymbol: cfg.curSymbol, minorcurSymbol: cfg.minorcurSymbol,
        btcSymbol: cfg.btcSymbol, satsSymbol: cfg.satsSymbol, auSymbol: cfg.auSymbol, agSymbol: cfg.agSymbol,
        warnSymbol: cfg.warnSymbol, delimSymbol: cfg.delimSymbol,
        decPlaces: cfg.decPlaces, decPlacesTT: cfg.decPlacesTT, priceDivider: cfg.priceDivider,
        btcStack: cfg.btcStack, btcCost: cfg.btcCost, capGainBTC: cfg.capGainBTC,
        auStack: cfg.auStack, auSlip: cfg.auSlip, agStack: cfg.agStack, agSlip: cfg.agSlip
    })

    readonly property var calc: { revision; return Logic.calc(prices, viewCfg) }

    readonly property string appletText: {
        revision;
        var t = hasData ? Logic.appletText(prices, viewCfg, calc) : "";
        return t !== "" ? t : cfg.appletSymbol;
    }

    readonly property color labelColor: !cfg.appletColor ? Kirigami.Theme.textColor
        : fetching ? Kirigami.Theme.highlightColor
        : hasErrors ? Kirigami.Theme.disabledTextColor
        : Kirigami.Theme.textColor

    // ------------------------------------------------------------ table models
    // The tooltip has its own on/off switches; the table builder reads the popup (TT) flags, so map them
    readonly property var tipCfg: Object.assign({}, viewCfg, {
        showBTC: cfg.showBTCTip, showBTCTT: cfg.showBTCTip,
        showBTCFee: false, showBTCFeeTT: cfg.showBTCFeeTip,
        showMetals: false, showMetalsTT: cfg.showMetalsTip,
        showStack: cfg.showStackTip
    })

    function statCells(c) {
        var cells = [];
        Logic.popupRows(prices, c, calc, okState).forEach(function (row) {
            row.forEach(function (pair) {
                cells.push({ text: pair.label, bold: true, shade: true });
                cells.push({ text: pair.value, span: row.length === 1 ? 3 : 1 });
            });
        });
        return cells;
    }

    readonly property var popupCells: { revision; return statCells(viewCfg) }
    readonly property var tipStatCells: { revision; return statCells(tipCfg) }

    readonly property var statusCells: {
        revision;
        var next = fetching ? i18n("refreshing…")
            : nextRefresh > 0
                ? Qt.formatDateTime(new Date(nextRefresh), "hh:mm") + " ("
                  + i18n("in %1", Logic.fmtCountdown(nextRefresh - now)) + ")"
                : "—";
        var cells = [
            { text: i18n("Last check"), bold: true, shade: true },
            { text: lastCheck > 0 ? Qt.formatDateTime(new Date(lastCheck), "yyyy-MM-dd hh:mm") : i18n("never") },
            { text: i18n("Next update"), bold: true, shade: true },
            { text: next }
        ];
        if (hasErrors) {
            cells.push({ text: cfg.warnSymbol + " " + i18n("Error during last update"), span: 2, error: true });
            Object.keys(errors).forEach(function (k) {
                cells.push({ text: errors[k], span: 2, error: true });
            });
        }
        return cells;
    }

    // ------------------------------------------------------------ plasmoid integration
    toolTipMainText: i18n("Financial Stats")
    toolTipItem: Loader {
        sourceComponent: tooltipComponent
        Layout.minimumWidth: item ? item.implicitWidth : 0
        Layout.minimumHeight: item ? item.implicitHeight : 0
        Layout.maximumWidth: Layout.minimumWidth
        Layout.maximumHeight: Layout.minimumHeight
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Refresh now")
            icon.name: "view-refresh"
            enabled: !root.fetching
            onTriggered: root.refreshNow()
        }
    ]

    Component {
        id: tooltipComponent
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            PlasmaExtras.Heading {
                level: 4
                text: i18n("Financial Stats")
            }
            StatsTable {
                visible: root.tipStatCells.length > 0
                columns: 4
                cells: root.tipStatCells
            }
            StatsTable {
                columns: 2
                cells: root.statusCells
            }
        }
    }

    compactRepresentation: MouseArea {
        id: compactArea
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        Layout.minimumWidth: label.implicitWidth + Kirigami.Units.smallSpacing * 2
        onClicked: root.expanded = !root.expanded
        onContainsMouseChanged: root.hovered = containsMouse

        PlasmaComponents3.Label {
            id: label
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: root.appletText
            color: root.labelColor
            Behavior on color { ColorAnimation { duration: 500 } }
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredWidth: Kirigami.Units.gridUnit * 24
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8

        header: PlasmaExtras.PlasmoidHeading {
            RowLayout {
                anchors.fill: parent
                PlasmaExtras.Heading {
                    level: 3
                    text: i18n("Financial Stats")
                    Layout.fillWidth: true
                }
                PlasmaComponents3.ToolButton {
                    icon.name: "view-refresh"
                    text: i18n("Refresh now")
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    enabled: !root.fetching
                    onClicked: root.refreshNow()
                    QQC2.ToolTip.text: text
                    QQC2.ToolTip.visible: hovered
                }
            }
        }

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            // last check / next update (with errors), same table as in the tooltip
            StatsTable {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                columns: 2
                cells: root.statusCells
            }

            StatsTable {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                visible: root.popupCells.length > 0
                columns: 4
                cells: root.popupCells
            }

            PlasmaExtras.PlaceholderMessage {
                Layout.fillWidth: true
                visible: root.popupCells.length === 0
                text: root.hasData ? i18n("Nothing to show") : i18n("Waiting for data…")
                explanation: i18n("Choose what to display in the popup in the widget settings.")
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ------------------------------------------------------------ fetching
    function refreshNow() {
        if (!fetching) startFetch();
    }

    // Abort whatever is running and start over (used after the settings changed)
    function restartFetch() {
        generation++;
        watchdog.stop();
        jobs.forEach(function (j) { if (!j.done) { try { j.xhr.abort(); } catch (e) {} } });
        fetching = false;
        startFetch();
    }

    function buildJobs() {
        var list = [];
        if (wantBTC)
            list.push({ src: "btc", url: cfg.btcUrl, targets: [{ key: cfg.btcKey, field: "btc" }] });
        if (wantFee)
            list.push({ src: "fee", url: cfg.btcfeeUrl, targets: [{ key: cfg.btcfeeKey, field: "fee" }] });
        if (wantMetals) {
            var sAu = cfg.metalsSuffAu, sAg = cfg.metalsSuffAg;
            if (sAg.length > 0 && sAg !== sAu) {
                // one request per metal
                list.push({ src: "metals", url: cfg.metalsUrl + sAu, targets: [{ key: cfg.metalsKeyAu, field: "au" }] });
                list.push({ src: "metals", url: cfg.metalsUrl + sAg, targets: [{ key: cfg.metalsKeyAg, field: "ag" }] });
            } else {
                // both metals come from one response
                list.push({ src: "metals", url: cfg.metalsUrl + sAu,
                            targets: [{ key: cfg.metalsKeyAu, field: "au" }, { key: cfg.metalsKeyAg, field: "ag" }] });
            }
        }
        return list;
    }

    function startFetch() {
        var myGen = ++generation;
        fetching = true;
        batch = { prices: {}, errors: {} };
        var list = buildJobs();
        jobs = list;
        if (list.length === 0) { finishFetch(); return; }

        list.forEach(function (job) {
            job.done = false;
            var xhr = new XMLHttpRequest();
            job.xhr = xhr;
            xhr.onreadystatechange = function () {
                if (xhr.readyState !== XMLHttpRequest.DONE || myGen !== generation || job.done) return;
                job.done = true;
                handleResponse(job, xhr);
                if (list.every(function (j) { return j.done; })) finishFetch();
            };
            xhr.open("GET", job.url, true);
            xhr.setRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0esr) Gecko/20100101 Firefox/140.0esr");
            xhr.send();
        });
        watchdog.interval = Math.max(1, cfg.timeDataReady) * 1000;
        watchdog.restart();
    }

    function failJob(job, msg) {
        var prev = batch.errors[job.src];
        batch.errors[job.src] = (prev ? prev + "; " : "") + msg;
    }

    function handleResponse(job, xhr) {
        if (xhr.status !== 200) {
            failJob(job, job.src + ": " + (xhr.status === 0 ? i18n("no response") : "HTTP " + xhr.status));
            return;
        }
        var data;
        try {
            data = JSON.parse(xhr.responseText);
        } catch (e) {
            failJob(job, job.src + ": " + i18n("invalid JSON"));
            return;
        }
        job.targets.forEach(function (t) {
            if (t.key === "") return;
            var v = Logic.dive(data, t.key);
            if (Logic.valid(v)) batch.prices[t.field] = v;
            else failJob(job, job.src + ": " + i18n("no value for key “%1”", t.key));
        });
    }

    function finishFetch() {
        watchdog.stop();
        var p = Object.assign({}, prices, batch.prices);
        var ok = {};
        buildJobs().forEach(function (j) { ok[j.src] = !batch.errors[j.src]; });
        prices = p;
        okState = ok;
        errors = batch.errors;
        if (Object.keys(batch.prices).length > 0) hasData = true;
        lastCheck = Date.now();
        now = lastCheck;
        fetching = false;
        revision++;
        schedule();
    }

    // Time budget exceeded: whatever has not answered is failed
    Timer {
        id: watchdog
        repeat: false
        onTriggered: {
            root.jobs.forEach(function (j) {
                if (j.done) return;
                j.done = true;
                try { j.xhr.abort(); } catch (e) {}
                root.failJob(j, j.src + ": " + i18n("timeout"));
            });
            root.finishFetch();
        }
    }

    // ------------------------------------------------------------ scheduling
    function schedule() {
        var failed = Object.keys(errors).length > 0;
        var minutes = Math.max(1, failed ? cfg.timeRefetch : cfg.timeRefresh);
        var base = lastCheck > 0 ? lastCheck : Date.now();
        nextRefresh = Math.max(base + minutes * 60000, Date.now() + 1000);
        refreshTimer.interval = nextRefresh - Date.now();
        refreshTimer.restart();
    }

    Timer {
        id: refreshTimer
        repeat: false
        onTriggered: root.startFetch()
    }

    // Countdown tick (minute resolution), only while somebody can see it
    Timer {
        interval: 10000
        repeat: true
        running: root.hovered || root.expanded
        triggeredOnStart: true
        onTriggered: root.now = Date.now()
    }

    // Changes to what/where we fetch re-fetch (debounced while the user is typing in the settings)
    readonly property string fetchSignature: [cfg.btcUrl, cfg.btcKey, cfg.btcfeeUrl, cfg.btcfeeKey,
        cfg.metalsUrl, cfg.metalsSuffAu, cfg.metalsSuffAg, cfg.metalsKeyAu, cfg.metalsKeyAg,
        wantBTC, wantFee, wantMetals].join("|")
    onFetchSignatureChanged: if (completed) refetchTimer.restart()

    Timer {
        id: refetchTimer
        interval: 1000
        repeat: false
        onTriggered: root.restartFetch()
    }

    Connections {
        target: root.cfg
        function onTimeRefreshChanged() { if (root.completed && !root.fetching && root.lastCheck > 0) root.schedule() }
        function onTimeRefetchChanged() { if (root.completed && !root.fetching && root.lastCheck > 0) root.schedule() }
    }

    Component.onCompleted: {
        completed = true;
        startFetch();
    }
}
