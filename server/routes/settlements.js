const express = require("express");
const db = require("../database");

const router = express.Router();


// =====================================================
// GET SETTLEMENT FOR A DEAL
// GET /api/deals/:id/settlement
// =====================================================

router.get("/:id/settlement", (req, res) => {

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

    // Find settlement
    const settlement = db.prepare(`
        SELECT *
        FROM settlements
        WHERE deal_id = ?
    `).get(dealId);

    if (!settlement) {
        return res.status(404).json({
            success: false,
            message: "Settlement not found for this deal"
        });
    }

    res.status(200).json({
        success: true,
        settlement: settlement
    });
});


// =====================================================
// UPDATE / CREATE SETTLEMENT
// PUT /api/deals/:id/settlement
// =====================================================

router.put("/:id/settlement", (req, res) => {

    const dealId = Number(req.params.id);

    const {
        delivered_quantity,
        payment_amount,
        status
    } = req.body;


    // Validate deal ID
    if (isNaN(dealId)) {
        return res.status(400).json({
            success: false,
            message: "Invalid deal ID"
        });
    }


    // Check deal
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


    // Validate delivered quantity
    if (
        delivered_quantity === undefined ||
        delivered_quantity === null
    ) {
        return res.status(400).json({
            success: false,
            message: "delivered_quantity is required"
        });
    }


    if (Number(delivered_quantity) < 0) {
        return res.status(400).json({
            success: false,
            message: "Delivered quantity cannot be negative"
        });
    }


    // Validate payment amount
    if (
        payment_amount === undefined ||
        payment_amount === null
    ) {
        return res.status(400).json({
            success: false,
            message: "payment_amount is required"
        });
    }


    if (Number(payment_amount) < 0) {
        return res.status(400).json({
            success: false,
            message: "Payment amount cannot be negative"
        });
    }


    // Allowed statuses
    const allowedStatuses = [
        "pending",
        "paid",
        "completed"
    ];


    if (
        status &&
        !allowedStatuses.includes(status)
    ) {
        return res.status(400).json({
            success: false,
            message: "Status must be pending, paid or completed"
        });
    }


    // Expected amount based on the deal
    const expectedAmount =
        deal.quantity * deal.agreed_price;


    // Difference between expected and actual payment
    const difference =
        expectedAmount - Number(payment_amount);


    // Check if settlement already exists
    const existingSettlement = db.prepare(`
        SELECT *
        FROM settlements
        WHERE deal_id = ?
    `).get(dealId);


    let settlement;


    if (existingSettlement) {

        // Update existing settlement
        db.prepare(`
            UPDATE settlements
            SET
                delivered_quantity = ?,
                payment_amount = ?,
                difference = ?,
                status = ?
            WHERE deal_id = ?
        `).run(
            Number(delivered_quantity),
            Number(payment_amount),
            difference,
            status || existingSettlement.status,
            dealId
        );

    } else {

        // Create settlement
        db.prepare(`
            INSERT INTO settlements
            (
                deal_id,
                delivered_quantity,
                payment_amount,
                difference,
                status
            )
            VALUES (?, ?, ?, ?, ?)
        `).run(
            dealId,
            Number(delivered_quantity),
            Number(payment_amount),
            difference,
            status || "pending"
        );
    }


    // Get final settlement
    settlement = db.prepare(`
        SELECT *
        FROM settlements
        WHERE deal_id = ?
    `).get(dealId);


    res.status(200).json({
        success: true,
        message: existingSettlement
            ? "Settlement updated successfully"
            : "Settlement created successfully",
        settlement: settlement
    });
});


module.exports = router;