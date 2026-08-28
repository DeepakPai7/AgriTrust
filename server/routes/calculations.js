const express = require("express");
const db = require("../database");

const router = express.Router();


// =====================================================
// GET CALCULATION FOR A DEAL
// GET /api/deals/:id/calculation
// =====================================================

router.get("/:id/calculation", (req, res) => {

    const dealId = Number(req.params.id);

    // Validate deal ID
    if (isNaN(dealId)) {
        return res.status(400).json({
            success: false,
            message: "Invalid deal ID"
        });
    }

    // Check whether deal exists
    const deal = db.prepare(`
        SELECT *
        FROM deals
        WHERE id = ?
    `).get(dealId);

    if (!deal) {
        return res.status(404).json({
            success: false,
            message: "Deal not found"
        });
    }

    // Find calculation
    const calculation = db.prepare(`
        SELECT *
        FROM calculations
        WHERE deal_id = ?
    `).get(dealId);

    // If calculation does not exist yet
    if (!calculation) {
        return res.status(404).json({
            success: false,
            message: "Calculation not found for this deal"
        });
    }

    res.status(200).json({
        success: true,
        calculation: calculation
    });
});


// =====================================================
// CREATE CALCULATION
// POST /api/deals/:id/calculation
// =====================================================

router.post("/:id/calculation", (req, res) => {

    const dealId = Number(req.params.id);

    // Validate deal ID
    if (isNaN(dealId)) {
        return res.status(400).json({
            success: false,
            message: "Invalid deal ID"
        });
    }

    // Check whether deal exists
    const deal = db.prepare(`
        SELECT *
        FROM deals
        WHERE id = ?
    `).get(dealId);

    if (!deal) {
        return res.status(404).json({
            success: false,
            message: "Deal not found"
        });
    }

    // Check whether calculation already exists
    const existingCalculation = db.prepare(`
        SELECT *
        FROM calculations
        WHERE deal_id = ?
    `).get(dealId);

    if (existingCalculation) {
        return res.status(409).json({
            success: false,
            message: "Calculation already exists for this deal",
            calculation: existingCalculation
        });
    }

    // Get deductions from request body
    const deductions = Number(req.body.deductions || 0);

    // Validate deductions
    if (deductions < 0) {
        return res.status(400).json({
            success: false,
            message: "Deductions cannot be negative"
        });
    }

    // Calculate gross amount
    const grossAmount =
        deal.quantity * deal.agreed_price;

    // Calculate net amount
    const netAmount =
        grossAmount - deductions;

    // Prevent negative net amount
    if (netAmount < 0) {
        return res.status(400).json({
            success: false,
            message: "Deductions cannot be greater than gross amount"
        });
    }

    // Calculate effective price
    const effectivePrice =
        deal.quantity > 0
            ? netAmount / deal.quantity
            : 0;

    // Insert calculation
    const result = db.prepare(`
        INSERT INTO calculations
        (
            deal_id,
            gross_amount,
            deductions,
            net_amount,
            effective_price
        )
        VALUES (?, ?, ?, ?, ?)
    `).run(
        dealId,
        grossAmount,
        deductions,
        netAmount,
        effectivePrice
    );

    // Get created calculation
    const calculation = db.prepare(`
        SELECT *
        FROM calculations
        WHERE id = ?
    `).get(result.lastInsertRowid);

    res.status(201).json({
        success: true,
        message: "Deal calculation created successfully",
        calculation: calculation
    });
});


module.exports = router;