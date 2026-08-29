const express = require("express");
const db = require("../database");

const router = express.Router();

// =====================================================
// REGISTRATION TABLES
// =====================================================

// Farmers and buyers are stored in their own tables. The "role" selects
// which table a new account goes into and which table login looks at.

// Name of the registration table for a given role.
function tableForRole(role) {
    return role === "buyer" ? "buyers" : "farmers";
}

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

    if (role !== "farmer" && role !== "buyer") {
        return res.status(400).json({
            success: false,
            message: "Role must be either farmer or buyer"
        });
    }

    const table = tableForRole(role);

    // Check whether email already exists in this role's table
    const existingUser = db
        .prepare(`SELECT id FROM ${table} WHERE email = ?`)
        .get(email);

    if (existingUser) {
        return res.status(409).json({
            success: false,
            message: "Email already registered"
        });
    }

    // Insert new user into the role-specific table
    const result = db
        .prepare(`
            INSERT INTO ${table}
            (name, email, password, location)
            VALUES (?, ?, ?, ?)
        `)
        .run(name, email, password, location || null);

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

    const { email, password, role } = req.body;

    // Check required fields
    if (!email || !password || !role) {
        return res.status(400).json({
            success: false,
            message: "Email, password and role are required"
        });
    }

    if (role !== "farmer" && role !== "buyer") {
        return res.status(400).json({
            success: false,
            message: "Role must be either farmer or buyer"
        });
    }

    // Login only checks the table matching the selected role. A farmer
    // email cannot log in through the buyer portal and vice versa.
    const table = tableForRole(role);

    const user = db
        .prepare(`SELECT * FROM ${table} WHERE email = ?`)
        .get(email);

    // User does not exist in this role's table
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
            role,
            location: user.location
        }
    });
});

module.exports = router;