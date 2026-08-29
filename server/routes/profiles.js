const express = require("express");
const db = require("../database");

const router = express.Router();

// =====================================================
// FARMER PROFILE
// GET /api/farmers/:id
// =====================================================

router.get("/farmers/:id", (req, res) => {

    const id = Number(req.params.id);

    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid farmer ID"
        });
    }

    const farmer = db.prepare(`
        SELECT
            id,
            name,
            email,
            location,
            farm_details,
            phone,
            language,
            address,
            land_area,
            land_unit,
            soil_type,
            crops,
            irrigation,
            latitude,
            longitude,
            bank_account,
            ifsc,
            settlement_method
        FROM farmers
        WHERE id = ?
    `).get(id);

    if (!farmer) {
        return res.status(404).json({
            success: false,
            message: "Farmer not found"
        });
    }

    res.status(200).json({
        success: true,
        profile: farmer
    });
});


// =====================================================
// UPDATE FARMER PROFILE
// PUT /api/farmers/:id
// =====================================================

router.put("/farmers/:id", (req, res) => {

    const id = Number(req.params.id);

    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid farmer ID"
        });
    }

    const existing = db.prepare("SELECT * FROM farmers WHERE id = ?").get(id);

    if (!existing) {
        return res.status(404).json({
            success: false,
            message: "Farmer not found"
        });
    }

    const body = req.body || {};

    const update = db.prepare(`
        UPDATE farmers
        SET
            name = ?,
            location = ?,
            phone = ?,
            language = ?,
            address = ?,
            land_area = ?,
            land_unit = ?,
            soil_type = ?,
            crops = ?,
            irrigation = ?,
            latitude = ?,
            longitude = ?,
            bank_account = ?,
            ifsc = ?,
            settlement_method = ?,
            farm_details = ?
        WHERE id = ?
    `);

    const name = body.name !== undefined ? body.name : existing.name;
    const location = body.location !== undefined ? body.location : existing.location;
    const landArea = body.land_area !== undefined ? body.land_area : existing.land_area;
    const farmlandUnit = body.land_unit !== undefined ? body.land_unit : existing.land_unit;
    const soil = body.soil_type !== undefined ? body.soil_type : existing.soil_type;
    const crops = body.crops !== undefined ? body.crops : existing.crops;
    const irrigation = body.irrigation !== undefined ? body.irrigation : existing.irrigation;

    // Keep the legacy farm_details JSON in sync with the structured columns.
    const farmDetails = JSON.stringify({
        land_area: landArea ? `${landArea} ${farmlandUnit || "acres"}`.trim() : null,
        soil: soil,
        crops: crops
            ? crops.split(",").map((c) => c.trim()).filter(Boolean)
            : [],
        irrigation: irrigation
    });

    update.run(
        name,
        body.location !== undefined ? body.location : existing.location,
        body.phone !== undefined ? body.phone : existing.phone,
        body.language !== undefined ? body.language : existing.language,
        body.address !== undefined ? body.address : existing.address,
        landArea,
        farmlandUnit,
        soil,
        crops,
        irrigation,
        body.latitude !== undefined ? body.latitude : existing.latitude,
        body.longitude !== undefined ? body.longitude : existing.longitude,
        body.bank_account !== undefined ? body.bank_account : existing.bank_account,
        body.ifsc !== undefined ? body.ifsc : existing.ifsc,
        body.settlement_method !== undefined ? body.settlement_method : existing.settlement_method,
        farmDetails,
        id
    );

    const updated = db.prepare(`
        SELECT
            id,
            name,
            email,
            location,
            farm_details,
            phone,
            language,
            address,
            land_area,
            land_unit,
            soil_type,
            crops,
            irrigation,
            latitude,
            longitude,
            bank_account,
            ifsc,
            settlement_method
        FROM farmers
        WHERE id = ?
    `).get(id);

    res.status(200).json({
        success: true,
        message: "Farmer profile updated successfully",
        profile: updated
    });
});


// =====================================================
// BUYER PROFILE
// GET /api/buyers/:id
// =====================================================

router.get("/buyers/:id", (req, res) => {

    const id = Number(req.params.id);

    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid buyer ID"
        });
    }

    const buyer = db.prepare(`
        SELECT
            id,
            name,
            email,
            location,
            company_name,
            gst_pan,
            company_address,
            crops_interested,
            preferred_locations,
            contact_phone,
            payment_method,
            bank_account,
            ifsc
        FROM buyers
        WHERE id = ?
    `).get(id);

    if (!buyer) {
        return res.status(404).json({
            success: false,
            message: "Buyer not found"
        });
    }

    res.status(200).json({
        success: true,
        profile: buyer
    });
});


// =====================================================
// UPDATE BUYER PROFILE
// PUT /api/buyers/:id
// =====================================================

router.put("/buyers/:id", (req, res) => {

    const id = Number(req.params.id);

    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid buyer ID"
        });
    }

    const existing = db.prepare("SELECT * FROM buyers WHERE id = ?").get(id);

    if (!existing) {
        return res.status(404).json({
            success: false,
            message: "Buyer not found"
        });
    }

    const body = req.body || {};

    const update = db.prepare(`
        UPDATE buyers
        SET
            name = ?,
            location = ?,
            company_name = ?,
            gst_pan = ?,
            company_address = ?,
            crops_interested = ?,
            preferred_locations = ?,
            contact_phone = ?,
            payment_method = ?,
            bank_account = ?,
            ifsc = ?
        WHERE id = ?
    `);

    update.run(
        body.name !== undefined ? body.name : existing.name,
        body.location !== undefined ? body.location : existing.location,
        body.company_name !== undefined ? body.company_name : existing.company_name,
        body.gst_pan !== undefined ? body.gst_pan : existing.gst_pan,
        body.company_address !== undefined ? body.company_address : existing.company_address,
        body.crops_interested !== undefined ? body.crops_interested : existing.crops_interested,
        body.preferred_locations !== undefined ? body.preferred_locations : existing.preferred_locations,
        body.contact_phone !== undefined ? body.contact_phone : existing.contact_phone,
        body.payment_method !== undefined ? body.payment_method : existing.payment_method,
        body.bank_account !== undefined ? body.bank_account : existing.bank_account,
        body.ifsc !== undefined ? body.ifsc : existing.ifsc,
        id
    );

    const updated = db.prepare(`
        SELECT
            id,
            name,
            email,
            location,
            company_name,
            gst_pan,
            company_address,
            crops_interested,
            preferred_locations,
            contact_phone,
            payment_method,
            bank_account,
            ifsc
        FROM buyers
        WHERE id = ?
    `).get(id);

    res.status(200).json({
        success: true,
        message: "Buyer profile updated successfully",
        profile: updated
    });
});


module.exports = router;
