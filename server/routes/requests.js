const express = require("express");
const db = require("../database");

const router = express.Router();


// =====================================================
// GET ALL BUYER REQUESTS
// GET /api/requests
// =====================================================

router.get("/", (req, res) => {

    const farmerId = req.query.farmer_id
        ? Number(req.query.farmer_id)
        : null;
    const buyerId = req.query.buyer_id
        ? Number(req.query.buyer_id)
        : null;

    const getRequests = (extraWhere) => {
        if (farmerId && buyerId) {
            return db.prepare(`
                SELECT
                    requests.id,
                    requests.buyer_id,
                    requests.quantity,
                    requests.offered_price,
                    requests.status,
                    requests.created_at,

                    buyers.name AS buyer_name,

                    products.product_name,
                    products.price AS product_price,
                    products.unit,
                    products.location,
                    products.farmer_id

                FROM requests

                JOIN buyers
                    ON requests.buyer_id = buyers.id

                JOIN products
                    ON requests.product_id = products.id

                WHERE products.farmer_id = ? AND requests.buyer_id = ?
                ${extraWhere}
                ORDER BY requests.id DESC
            `).all(farmerId, buyerId);
        }
        if (farmerId) {
            return db.prepare(`
                SELECT
                    requests.id,
                    requests.buyer_id,
                    requests.quantity,
                    requests.offered_price,
                    requests.status,
                    requests.created_at,

                    buyers.name AS buyer_name,

                    products.product_name,
                    products.price AS product_price,
                    products.unit,
                    products.location,
                    products.farmer_id

                FROM requests

                JOIN buyers
                    ON requests.buyer_id = buyers.id

                JOIN products
                    ON requests.product_id = products.id

                WHERE products.farmer_id = ?
                ${extraWhere}
                ORDER BY requests.id DESC
            `).all(farmerId);
        }
        if (buyerId) {
            return db.prepare(`
                SELECT
                    requests.id,
                    requests.buyer_id,
                    requests.quantity,
                    requests.offered_price,
                    requests.status,
                    requests.created_at,

                    buyers.name AS buyer_name,

                    products.product_name,
                    products.price AS product_price,
                    products.unit,
                    products.location,
                    products.farmer_id

                FROM requests

                JOIN buyers
                    ON requests.buyer_id = buyers.id

                JOIN products
                    ON requests.product_id = products.id

                WHERE requests.buyer_id = ?
                ${extraWhere}
                ORDER BY requests.id DESC
            `).all(buyerId);
        }
        return db.prepare(`
            SELECT
                requests.id,
                requests.buyer_id,
                requests.quantity,
                requests.offered_price,
                requests.status,
                requests.created_at,

                buyers.name AS buyer_name,

                products.product_name,
                products.price AS product_price,
                products.unit,
                products.location,
                products.farmer_id

            FROM requests

            JOIN buyers
                ON requests.buyer_id = buyers.id

            JOIN products
                ON requests.product_id = products.id

            ${extraWhere}
            ORDER BY requests.id DESC
        `).all();
    };

    const requests = getRequests("");

    res.status(200).json({
        success: true,
        count: requests.length,
        requests: requests
    });
});


// =====================================================
// CREATE BUYER REQUEST
// POST /api/requests
// =====================================================

router.post("/", (req, res) => {

    const {
        buyer_id,
        product_id,
        quantity,
        offered_price
    } = req.body;


    // Check required fields
    if (
        !buyer_id ||
        !product_id ||
        !quantity
    ) {
        return res.status(400).json({
            success: false,
            message: "buyer_id, product_id and quantity are required"
        });
    }


    // Check buyer
    const buyer = db.prepare(`
        SELECT id, name
        FROM buyers
        WHERE id = ?
    `).get(buyer_id);


    if (!buyer) {
        return res.status(404).json({
            success: false,
            message: "Buyer not found"
        });
    }


    // Check product
    const product = db.prepare(`
        SELECT *
        FROM products
        WHERE id = ?
    `).get(product_id);


    if (!product) {
        return res.status(404).json({
            success: false,
            message: "Product not found"
        });
    }


    // Make sure requested quantity is available
    if (quantity > product.quantity) {
        return res.status(400).json({
            success: false,
            message: `Only ${product.quantity} ${product.unit} is available`
        });
    }


    // Insert request
    const result = db.prepare(`
        INSERT INTO requests
        (
            buyer_id,
            product_id,
            quantity,
            offered_price,
            status
        )
        VALUES (?, ?, ?, ?, ?)
    `).run(
        buyer_id,
        product_id,
        quantity,
        offered_price || product.price,
        "pending"
    );


    // Get newly created request
    const newRequest = db.prepare(`
            SELECT
                requests.id,
                requests.quantity,
                requests.offered_price,
                requests.status,
                requests.created_at,

                buyers.name AS buyer_name,

                products.product_name,
                products.price AS product_price,
                products.unit,
                products.location,
                products.farmer_id

            FROM requests

            JOIN buyers
                ON requests.buyer_id = buyers.id

            JOIN products
                ON requests.product_id = products.id

            WHERE requests.id = ?
        `).get(result.lastInsertRowid);


    res.status(201).json({
        success: true,
        message: "Buyer request created successfully",
        request: newRequest
    });
});


// =====================================================
// UPDATE BUYER REQUEST
// PUT /api/requests/:id
// =====================================================

router.put("/:id", (req, res) => {

    const id = Number(req.params.id);

    const {
        status,
        offered_price,
        quantity
    } = req.body;


    // Validate ID
    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid request ID"
        });
    }


    // Find request
    const existingRequest = db.prepare(`
        SELECT *
        FROM requests
        WHERE id = ?
    `).get(id);


    if (!existingRequest) {
        return res.status(404).json({
            success: false,
            message: "Request not found"
        });
    }


    // Allowed statuses
    const allowedStatuses = [
        "pending",
        "accepted",
        "rejected"
    ];


    if (
        status &&
        !allowedStatuses.includes(status)
    ) {
        return res.status(400).json({
            success: false,
            message: "Status must be pending, accepted or rejected"
        });
    }


    // Keep old values if not supplied
    const newStatus =
        status || existingRequest.status;

    const newPrice =
        offered_price !== undefined
            ? offered_price
            : existingRequest.offered_price;

    const newQuantity =
        quantity !== undefined
            ? quantity
            : existingRequest.quantity;


    // Update request
    db.prepare(`
        UPDATE requests
        SET
            quantity = ?,
            offered_price = ?,
            status = ?
        WHERE id = ?
    `).run(
        newQuantity,
        newPrice,
        newStatus,
        id
    );


    // Return updated request
    const updatedRequest = db.prepare(`
            SELECT
                requests.id,
                requests.quantity,
                requests.offered_price,
                requests.status,
                requests.created_at,

                buyers.name AS buyer_name,

                products.product_name,
                products.price AS product_price,
                products.unit,
                products.location,
                products.farmer_id

            FROM requests

            JOIN buyers
                ON requests.buyer_id = buyers.id

            JOIN products
                ON requests.product_id = products.id

            WHERE requests.id = ?
        `).get(id);


    res.status(200).json({
        success: true,
        message: "Buyer request updated successfully",
        request: updatedRequest
    });
});


module.exports = router;