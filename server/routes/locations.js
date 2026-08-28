const express = require("express");
const db = require("../database");

const router = express.Router();


// =====================================================
// GET ALL LOCATIONS
// GET /api/locations
// =====================================================

router.get("/", (req, res) => {

    const locations = db.prepare(`
        SELECT *
        FROM locations
        ORDER BY id ASC
    `).all();

    res.status(200).json({
        success: true,
        count: locations.length,
        locations: locations
    });
});


module.exports = router;