const express = require("express");
const db = require("../database");

const router = express.Router();

// POST /api/auth/signup
router.post("/signup", (req, res) => {

    const { name, email, password, role, location } = req.body;

    // Check required fields
    if (!name || !email || !password || !role) {
        return res.status(400).json({
            success: false,
            message: "Name, email, password and role are required"
        });
    }

    // Check whether email already exists
    const existingUser = db
        .prepare("SELECT id FROM users WHERE email = ?")
        .get(email);

    if (existingUser) {
        return res.status(409).json({
            success: false,
            message: "Email already registered"
        });
    }

    // Insert new user
    const result = db
        .prepare(`
            INSERT INTO users
            (name, email, password, role, location)
            VALUES (?, ?, ?, ?, ?)
        `)
        .run(name, email, password, role, location || null);

    // Return successful response
    res.status(201).json({
        success: true,
        message: "User registered successfully",
        user: {
            id: result.lastInsertRowid,
            name,
            email,
            role,
            location: location || null
        }
    });
});
// POST /api/auth/login
router.post("/login", (req, res) => {

    const { email, password } = req.body;

    // Check required fields
    if (!email || !password) {
        return res.status(400).json({
            success: false,
            message: "Email and password are required"
        });
    }

    // Find user by email
    const user = db
        .prepare("SELECT * FROM users WHERE email = ?")
        .get(email);

    // User does not exist
    if (!user) {
        return res.status(401).json({
            success: false,
            message: "Invalid email or password"
        });
    }

    // Check password
    if (user.password !== password) {
        return res.status(401).json({
            success: false,
            message: "Invalid email or password"
        });
    }

    // Successful login
    res.status(200).json({
        success: true,
        message: "Login successful",
        user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            location: user.location
        }
    });
});

module.exports = router;