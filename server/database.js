const Database = require("better-sqlite3");

// Create or open the SQLite database
const db = new Database("../database/agritrust.db");

console.log("SQLite database connected");

// =====================================================
// CREATE TABLES
// =====================================================

db.exec(`
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        location TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        price REAL NOT NULL,
        location TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (farmer_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        buyer_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        offered_price REAL,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (buyer_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
    );

    CREATE TABLE IF NOT EXISTS deals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        buyer_id INTEGER NOT NULL,
        farmer_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        agreed_price REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (buyer_id) REFERENCES users(id),
        FOREIGN KEY (farmer_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
    );

    CREATE TABLE IF NOT EXISTS calculations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deal_id INTEGER UNIQUE NOT NULL,
        gross_amount REAL DEFAULT 0,
        deductions REAL DEFAULT 0,
        net_amount REAL DEFAULT 0,
        effective_price REAL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (deal_id) REFERENCES deals(id)
    );

    CREATE TABLE IF NOT EXISTS settlements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deal_id INTEGER UNIQUE NOT NULL,
        delivered_quantity REAL DEFAULT 0,
        payment_amount REAL DEFAULT 0,
        difference REAL DEFAULT 0,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (deal_id) REFERENCES deals(id)
    );

    CREATE TABLE IF NOT EXISTS market_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL,
        market_name TEXT NOT NULL,
        price REAL NOT NULL,
        unit TEXT NOT NULL,
        location TEXT,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        district TEXT,
        state TEXT NOT NULL,
        type TEXT DEFAULT 'market'
    );
`);

// =====================================================
// SAMPLE MARKET PRICE DATA
// =====================================================

const marketPriceCount = db
    .prepare("SELECT COUNT(*) AS count FROM market_prices")
    .get();

if (marketPriceCount.count === 0) {

    const insertPrice = db.prepare(`
        INSERT INTO market_prices
        (
            product_name,
            market_name,
            price,
            unit,
            location
        )
        VALUES (?, ?, ?, ?, ?)
    `);

    insertPrice.run(
        "Onion",
        "Mysore Market",
        30,
        "kg",
        "Mysore"
    );

    insertPrice.run(
        "Tomato",
        "Bangalore Market",
        35,
        "kg",
        "Bangalore"
    );

    insertPrice.run(
        "Rice",
        "Mysore Market",
        55,
        "kg",
        "Mysore"
    );
}

// =====================================================
// SAMPLE LOCATION DATA
// =====================================================

const locationCount = db
    .prepare("SELECT COUNT(*) AS count FROM locations")
    .get();

if (locationCount.count === 0) {

    const insertLocation = db.prepare(`
        INSERT INTO locations
        (
            name,
            district,
            state,
            type
        )
        VALUES (?, ?, ?, ?)
    `);

    insertLocation.run(
        "Mysore Market",
        "Mysore",
        "Karnataka",
        "market"
    );

    insertLocation.run(
        "Bangalore Market",
        "Bangalore Urban",
        "Karnataka",
        "market"
    );

    insertLocation.run(
        "Hubli Market",
        "Dharwad",
        "Karnataka",
        "market"
    );
}

// =====================================================
// EXPORT DATABASE
// =====================================================

module.exports = db;