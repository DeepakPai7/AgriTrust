const express = require("express");
const db = require("../database");

const router = express.Router();


// =====================================================
// GET ALL PRODUCTS
// GET /api/products
// =====================================================

router.get("/", (req, res) => {

    const farmerId = req.query.farmer_id
        ? Number(req.query.farmer_id)
        : null;

    const whereClause = farmerId ? "WHERE products.farmer_id = ?" : "";

    const products = farmerId
        ? db.prepare(`
            SELECT
                products.id,
                products.farmer_id,
                products.product_name,
                products.quantity,
                products.unit,
                products.price,
                products.location,
                products.notes,
                products.photo,
                products.created_at,
                farmers.name AS farmer_name
            FROM products
            JOIN farmers ON products.farmer_id = farmers.id
            ${whereClause}
            ORDER BY products.id DESC
        `).all(farmerId)
        : db.prepare(`
            SELECT
                products.id,
                products.farmer_id,
                products.product_name,
                products.quantity,
                products.unit,
                products.price,
                products.location,
                products.notes,
                products.photo,
                products.created_at,
                farmers.name AS farmer_name
            FROM products
            JOIN farmers ON products.farmer_id = farmers.id
            ${whereClause}
            ORDER BY products.id DESC
        `).all();

    res.status(200).json({
        success: true,
        count: products.length,
        products: products
    });
});


// =====================================================
// CREATE PRODUCT
// POST /api/products
// =====================================================

router.post("/", (req, res) => {

    const {
        farmer_id,
        product_name,
        quantity,
        unit,
        price,
        location,
        notes,
        photo,
        created_at
    } = req.body;


    // Check required fields
    if (
        !farmer_id ||
        !product_name ||
        !quantity ||
        !unit ||
        !price
    ) {
        return res.status(400).json({
            success: false,
            message: "farmer_id, product_name, quantity, unit and price are required"
        });
    }


    // Check whether farmer exists
    const farmer = db
        .prepare(`
            SELECT id, name
            FROM farmers
            WHERE id = ?
        `)
        .get(farmer_id);


    if (!farmer) {
        return res.status(404).json({
            success: false,
            message: "Farmer not found"
        });
    }


    // Insert product
    const result = db
        .prepare(`
            INSERT INTO products
            (
                farmer_id,
                product_name,
                quantity,
                unit,
                price,
                location,
                notes,
                photo,
                created_at
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `)
        .run(
            farmer_id,
            product_name,
            quantity,
            unit,
            price,
            location || null,
            notes || null,
            photo || null,
            created_at || null
        );


    // Return created product
    const newProduct = db
        .prepare(`
            SELECT
                products.id,
                products.farmer_id,
                products.product_name,
                products.quantity,
                products.unit,
                products.price,
                products.location,
                products.notes,
                products.photo,
                products.created_at,
                farmers.name AS farmer_name
            FROM products
            JOIN farmers ON products.farmer_id = farmers.id
            WHERE products.id = ?
        `)
        .get(result.lastInsertRowid);


    res.status(201).json({
        success: true,
        message: "Product added successfully",
        product: newProduct
    });
});


// =====================================================
// GET PRODUCT BY ID
// GET /api/products/:id
// =====================================================

router.get("/:id", (req, res) => {

    const id = Number(req.params.id);


    if (isNaN(id)) {
        return res.status(400).json({
            success: false,
            message: "Invalid product ID"
        });
    }


    const product = db
        .prepare(`
            SELECT
                products.id,
                products.farmer_id,
                products.product_name,
                products.quantity,
                products.unit,
                products.price,
                products.location,
                products.notes,
                products.photo,
                products.created_at,
                farmers.name AS farmer_name
            FROM products
            JOIN farmers ON products.farmer_id = farmers.id
            WHERE products.id = ?
        `)
        .get(id);


    if (!product) {
        return res.status(404).json({
            success: false,
            message: "Product not found"
        });
    }


    res.status(200).json({
        success: true,
        product: product
    });
});


module.exports = router;