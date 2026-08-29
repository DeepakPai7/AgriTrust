const express = require("express");
const db = require("../database");

const router = express.Router();


// =====================================================
// GET ALL DEALS
// GET /api/deals
// =====================================================

router.get("/", (req, res) => {

    const farmerId = req.query.farmer_id
        ? Number(req.query.farmer_id)
        : null;

    const buyerId = req.query.buyer_id
        ? Number(req.query.buyer_id)
        : null;

    // Filter deals to the requested user when supplied, so a farmer or buyer
    // only sees their own deals.
    const whereClause = [];
    const params = [];

    if (farmerId) {
        whereClause.push("deals.farmer_id = ?");
        params.push(farmerId);
    }

    if (buyerId) {
        whereClause.push("deals.buyer_id = ?");
        params.push(buyerId);
    }

    const whereSql = whereClause.length
        ? `WHERE ${whereClause.join(" AND ")}`
        : "";

    const deals = db.prepare(`
        SELECT
            deals.id,
            deals.buyer_id,
            deals.farmer_id,
            deals.product_id,
            deals.quantity,
            deals.agreed_price,
            deals.status,
            deals.created_at,

            buyer.name AS buyer_name,
            farmer.name AS farmer_name,
            products.product_name,
            products.unit,
            products.location

        FROM deals

        JOIN buyers AS buyer
            ON deals.buyer_id = buyer.id

        JOIN farmers AS farmer
            ON deals.farmer_id = farmer.id

        JOIN products
            ON deals.product_id = products.id

        ${whereSql}
        ORDER BY deals.id DESC
    `).all(...params);


    res.status(200).json({
        success: true,
        count: deals.length,
        deals: deals
    });
});


// =====================================================
// CREATE DEAL
// POST /api/deals
// =====================================================

router.post("/", (req, res) => {

    const {
        request_id,
        quantity,
        agreed_price
    } = req.body;


    // Check request ID
    if (!request_id) {
        return res.status(400).json({
            success: false,
            message: "request_id is required"
        });
    }


    // Find the request
    const request = db.prepare(`
        SELECT
            requests.*,
            products.farmer_id,
            products.product_name,
            products.unit,
            products.quantity AS available_quantity
        FROM requests

        JOIN products
            ON requests.product_id = products.id

        WHERE requests.id = ?
    `).get(request_id);


    if (!request) {
        return res.status(404).json({
            success: false,
            message: "Buyer request not found"
        });
    }


    // Only accepted requests can become deals
    if (request.status !== "accepted") {
        return res.status(400).json({
            success: false,
            message: "Only accepted requests can be converted into deals"
        });
    }


    // Check whether a deal already exists for this request
    const existingDeal = db.prepare(`
        SELECT id
        FROM deals
        WHERE buyer_id = ?
        AND farmer_id = ?
        AND product_id = ?
        AND quantity = ?
    `).get(
        request.buyer_id,
        request.farmer_id,
        request.product_id,
        quantity || request.quantity
    );


    if (existingDeal) {
        return res.status(409).json({
            success: false,
            message: "A deal already exists for this request"
        });
    }


    // Use request values if optional values are not provided
    const dealQuantity =
        quantity !== undefined
            ? quantity
            : request.quantity;

    const dealPrice =
        agreed_price !== undefined
            ? agreed_price
            : request.offered_price;


    // Validate quantity
    if (dealQuantity <= 0) {
        return res.status(400).json({
            success: false,
            message: "Quantity must be greater than zero"
        });
    }


    // Validate price
    if (dealPrice === null || dealPrice === undefined || dealPrice <= 0) {
        return res.status(400).json({
            success: false,
            message: "Agreed price must be greater than zero"
        });
    }


    // Check available product quantity
    if (dealQuantity > request.available_quantity) {
        return res.status(400).json({
            success: false,
            message: `Only ${request.available_quantity} ${request.unit} is available`
        });
    }


    // Create deal
    const result = db.prepare(`
        INSERT INTO deals
        (
            buyer_id,
            farmer_id,
            product_id,
            quantity,
            agreed_price,
            status
        )
        VALUES (?, ?, ?, ?, ?, ?)
    `).run(
        request.buyer_id,
        request.farmer_id,
        request.product_id,
        dealQuantity,
        dealPrice,
        "confirmed"
    );


    // Get newly created deal
    const newDeal = db.prepare(`
        SELECT
            deals.id,
            deals.buyer_id,
            deals.farmer_id,
            deals.product_id,
            deals.quantity,
            deals.agreed_price,
            deals.status,
            deals.created_at,

            buyer.name AS buyer_name,
            farmer.name AS farmer_name,
            products.product_name,
            products.unit,
            products.location

        FROM deals

        JOIN buyers AS buyer
            ON deals.buyer_id = buyer.id

        JOIN farmers AS farmer
            ON deals.farmer_id = farmer.id

        JOIN products
            ON deals.product_id = products.id

        WHERE deals.id = ?
    `).get(result.lastInsertRowid);


    res.status(201).json({
        success: true,
        message: "Deal created successfully",
        deal: newDeal
    });
});


// =====================================================
// GET DEAL BY ID
// GET /api/deals/:id
// =====================================================

router.get("/:id", (req, res) => {

    const id = Number(req.params.id);


    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid deal ID"
        });
    }


    const deal = db.prepare(`
        SELECT
            deals.id,
            deals.buyer_id,
            deals.farmer_id,
            deals.product_id,
            deals.quantity,
            deals.agreed_price,
            deals.status,
            deals.created_at,

            buyer.name AS buyer_name,
            farmer.name AS farmer_name,
            products.product_name,
            products.unit,
            products.location

        FROM deals

        JOIN buyers AS buyer
            ON deals.buyer_id = buyer.id

        JOIN farmers AS farmer
            ON deals.farmer_id = farmer.id

        JOIN products
            ON deals.product_id = products.id

        WHERE deals.id = ?
    `).get(id);


    if (!deal) {
        return res.status(404).json({
            success: false,
            message: "Deal not found"
        });
    }


    res.status(200).json({
        success: true,
        deal: deal
    });
});


// =====================================================
// UPDATE DEAL
// PUT /api/deals/:id
// =====================================================

router.put("/:id", (req, res) => {

    const id = Number(req.params.id);

    const {
        quantity,
        agreed_price,
        status
    } = req.body;


    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid deal ID"
        });
    }


    // Find existing deal
    const existingDeal = db.prepare(`
        SELECT *
        FROM deals
        WHERE id = ?
    `).get(id);


    if (!existingDeal) {
        return res.status(404).json({
            success: false,
            message: "Deal not found"
        });
    }


    // Allowed statuses
    const allowedStatuses = [
        "pending",
        "confirmed",
        "completed",
        "cancelled"
    ];


    if (
        status &&
        !allowedStatuses.includes(status)
    ) {
        return res.status(400).json({
            success: false,
            message: "Status must be pending, confirmed, completed or cancelled"
        });
    }


    // Keep existing values when not supplied
    const newQuantity =
        quantity !== undefined
            ? quantity
            : existingDeal.quantity;

    const newPrice =
        agreed_price !== undefined
            ? agreed_price
            : existingDeal.agreed_price;

    const newStatus =
        status || existingDeal.status;


    if (newQuantity <= 0) {
        return res.status(400).json({
            success: false,
            message: "Quantity must be greater than zero"
        });
    }


    if (newPrice <= 0) {
        return res.status(400).json({
            success: false,
            message: "Agreed price must be greater than zero"
        });
    }


    // Update deal
    db.prepare(`
        UPDATE deals
        SET
            quantity = ?,
            agreed_price = ?,
            status = ?
        WHERE id = ?
    `).run(
        newQuantity,
        newPrice,
        newStatus,
        id
    );


    // Return updated deal
    const updatedDeal = db.prepare(`
        SELECT
            deals.id,
            deals.buyer_id,
            deals.farmer_id,
            deals.product_id,
            deals.quantity,
            deals.agreed_price,
            deals.status,
            deals.created_at,

            buyer.name AS buyer_name,
            farmer.name AS farmer_name,
            products.product_name,
            products.unit,
            products.location

        FROM deals

        JOIN buyers AS buyer
            ON deals.buyer_id = buyer.id

        JOIN farmers AS farmer
            ON deals.farmer_id = farmer.id

        JOIN products
            ON deals.product_id = products.id

        WHERE deals.id = ?
    `).get(id);


    res.status(200).json({
        success: true,
        message: "Deal updated successfully",
        deal: updatedDeal
    });
});


module.exports = router;