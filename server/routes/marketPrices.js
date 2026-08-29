const express = require("express");
const db = require("../database");

const router = express.Router();

// data.gov.in Daily Mandi Price resource. Prices are per quintal.
const DATA_GOV_IN_BASE =
    "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070" +
    "?api-key=579b464db66ec23bdd000001cbe3b7f2f9a34a6058e9c52ff20a304b" +
    "&format=json";

const MAX_LIMIT = 200;

// Fetch from the external API and map to the shape the Flutter app expects.
async function fetchLivePrices({ limit, state }) {
    const params = new URLSearchParams();
    params.set("limit", String(limit));
    if (state) {
        params.set("filters[state]", state);
    }
    const res = await fetch(`${DATA_GOV_IN_BASE}&${params.toString()}`, {
        signal: AbortSignal.timeout(15000)
    });
    if (!res.ok) {
        throw new Error(`data.gov.in responded ${res.status}`);
    }
    const data = await res.json();
    const records = Array.isArray(data.records) ? data.records : [];
    return records.map((r) => ({
        product_name: r.commodity,
        market_name: r.market,
        state: r.state,
        district: r.district,
        variety: r.variety,
        grade: r.grade,
        arrival_date: r.arrival_date,
        min_price: r.min_price,
        max_price: r.max_price,
        modal_price: r.modal_price
    }));
}

router.get("/", async (req, res) => {
    const limit = Math.max(
        1,
        Math.min(MAX_LIMIT, Number.parseInt(req.query.limit, 10) || MAX_LIMIT)
    );
    const state = typeof req.query.state === "string"
        ? req.query.state.trim()
        : "";

    try {
        const live = await fetchLivePrices({ limit, state });
        return res.status(200).json({
            success: true,
            source: "data.gov.in",
            count: live.length,
            market_prices: live
        });
    } catch (_) {
        // Fall back to the seeded DB rows so the screen still works offline.
        let prices;
        if (state) {
            prices = db.prepare(`
                SELECT *
                FROM market_prices
                WHERE state = ?
                ORDER BY id DESC
                LIMIT ?
            `).all(state, limit);
        } else {
            prices = db.prepare(`
                SELECT *
                FROM market_prices
                ORDER BY id DESC
                LIMIT ?
            `).all(limit);
        }
        return res.status(200).json({
            success: true,
            source: "database",
            count: prices.length,
            market_prices: prices
        });
    }
});

module.exports = router;
