.pragma library

/*
 * Pure helpers for Financial Stats (no QML state, easy to test).
 * `p`  = prices   {btc, fee, au, ag}
 * `c`  = display settings snapshot (see main.qml: viewCfg)
 * `k`  = result of calc()
 * `ok` = per-source status {btc, fee, metals}: false = last fetch failed
 */

function valid(x) {
    return isFinite(x) && x > 1e-8;
}

// Walk a dotted path ("data.amount", "items.0.xauPrice") through parsed JSON
function dive(obj, path) {
    var v = obj, keys = String(path).split(".");
    for (var i = 0; i < keys.length; i++) {
        if (v === null || v === undefined || typeof v !== "object") return NaN;
        v = v[keys[i]];
    }
    return parseFloat(v);
}

function fixed(v, d) {
    return Number(v).toFixed(d);
}

// Divide only values above the divider (e.g. 67123 -> 67.1); 0 disables dividing
function scaled(v, divider) {
    return (divider > 0 && v > divider) ? v / divider : v;
}

function num(s) {
    var n = parseFloat(s);
    return isFinite(n) ? n : 0;
}

function calc(p, c) {
    // 141 vB is a SegWit 1-input / 2-output transaction; fee rates below 1 sat/vB are floored to 1
    var feeRate = (p.fee > 0 && p.fee < 1) ? 1 : p.fee;
    var feeSats = feeRate * 141;
    var feePrice = feeSats / 100000000 * p.btc;

    var stack = num(c.btcStack), cost = num(c.btcCost);
    var tax = ((p.btc * stack) - (cost * stack)) / 100 * c.capGainBTC;
    var btcNet = (p.btc * stack) - Math.max(0, tax);
    var auNet = p.au * c.auStack * (1 - c.auSlip / 100);
    var agNet = p.ag * c.agStack * (1 - c.agSlip / 100);

    return {
        feeSats: feeSats,
        feePrice: feePrice,
        ratioBtcAu: (p.btc > 0 && p.au > 0) ? p.btc / p.au : 0,
        ratioAuAg: (p.au > 0 && p.ag > 0) ? p.au / p.ag : 0,
        btcNet: btcNet,
        auNet: auNet,
        agNet: agNet
    };
}

// Text shown in the panel
function appletText(p, c, k) {
    var parts = [];
    if (c.showBTC)
        parts.push(fixed(scaled(p.btc, c.priceDivider), c.decPlaces));
    if (c.showBTCFee)
        parts.push(k.feePrice < 1 ? fixed(k.feePrice * 100, 0) : fixed(k.feePrice, c.decPlacesTT));
    if (c.showMetals) {
        parts.push(fixed(scaled(p.au, c.priceDivider), c.decPlaces));
        parts.push(fixed(scaled(p.ag, c.priceDivider), c.decPlaces));
        if (c.showMetalsRatio) parts.push(fixed(k.ratioAuAg, c.decPlaces));
    }
    return parts.length ? parts.join(" " + c.delimSymbol + " ") : "";
}

function warn(ok, src, c) {
    return ok[src] === false ? " " + c.warnSymbol : "";
}

function chunk(items) {
    var rows = [];
    for (var i = 0; i < items.length; i += 2) rows.push(items.slice(i, i + 2));
    return rows;
}

// Rows of the popup table; each row has one or two {label, value} pairs
function popupRows(p, c, k, ok) {
    var d = c.decPlacesTT, cur = c.curSymbol;
    var rows = [], items;
    var btcOn = c.showBTC || c.showBTCTT;

    items = [];
    if (c.showBTCTT)
        items.push({ label: c.btcSymbol + warn(ok, "btc", c), value: fixed(p.btc, d) + " " + cur });
    if (c.showBTCFeeTT)
        items.push({
            label: c.btcSymbol + " Fee" + warn(ok, "fee", c),
            value: (Math.round(k.feeSats * 10) / 10) + " " + c.satsSymbol + " / "
                   + (k.feePrice < 1 ? fixed(k.feePrice * 100, 0) + " " + c.minorcurSymbol
                                     : fixed(k.feePrice, d) + " " + cur)
        });
    rows = rows.concat(chunk(items));

    if (c.showMetalsTT) {
        rows = rows.concat(chunk([
            { label: c.auSymbol + warn(ok, "metals", c), value: fixed(p.au, d) + " " + cur },
            { label: c.agSymbol + warn(ok, "metals", c), value: fixed(p.ag, d) + " " + cur }
        ]));
        items = [];
        if (btcOn) items.push({ label: c.btcSymbol + "/" + c.auSymbol, value: fixed(k.ratioBtcAu, d) });
        items.push({ label: c.auSymbol + "/" + c.agSymbol, value: fixed(k.ratioAuAg, d) });
        rows = rows.concat(chunk(items));
    }

    if (c.showStack) {
        items = [];
        var total = 0;
        if (c.showMetalsTT) {
            items.push({ label: c.stackSymbol + c.auSymbol, value: fixed(k.auNet, d) + " " + cur });
            items.push({ label: c.stackSymbol + c.agSymbol, value: fixed(k.agNet, d) + " " + cur });
            total += k.auNet + k.agNet;
        }
        if (btcOn) {
            items.push({ label: c.stackSymbol + c.btcSymbol, value: fixed(k.btcNet, d) + " " + cur });
            total += k.btcNet;
        }
        if (items.length) {
            items.push({ label: c.stackSymbol + " Total", value: fixed(total, d) + " " + cur });
            rows = rows.concat(chunk(items));
        }
    }
    return rows;
}

function fmtCountdown(ms) {
    var s = Math.max(0, Math.round(ms / 1000));
    var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60;
    var pad = function (n) { return (n < 10 ? "0" : "") + n; };
    return h > 0 ? h + ":" + pad(m) + ":" + pad(sec) : pad(m) + ":" + pad(sec);
}
