const express = require("express");
const db = require("../database");

const router = express.Router();

router.get("/", (req, res) => {

    const prices = db.prepare(`
        SELECT *
        FROM market_prices
        ORDER BY id DESC
    `).all();

    res.status(200).json({
        success: true,
        count: prices.length,
        market_prices: prices
    });
});

module.exports = router;