const Database = require("better-sqlite3");

// Create or open the SQLite database
const db = new Database("../database/agritrust.db");

console.log("SQLite database connected");

// =====================================================
// CREATE TABLES
// =====================================================

db.exec(`
    CREATE TABLE IF NOT EXISTS farmers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        location TEXT,
        farm_details TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS buyers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        location TEXT,
        company_name TEXT,
        gst_pan TEXT,
        company_address TEXT,
        crops_interested TEXT,
        preferred_locations TEXT,
        contact_phone TEXT,
        payment_method TEXT,
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
        notes TEXT,
        photo TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (farmer_id) REFERENCES farmers(id)
    );

    CREATE TABLE IF NOT EXISTS requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        buyer_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        offered_price REAL,
        status TEXT DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (buyer_id) REFERENCES buyers(id),
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
        FOREIGN KEY (buyer_id) REFERENCES buyers(id),
        FOREIGN KEY (farmer_id) REFERENCES farmers(id),
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
// MIGRATIONS: ADD PROFILE COLUMNS
// =====================================================

// CREATE TABLE IF NOT EXISTS cannot add columns to an existing table, so add
// profile columns here with a guarded ALTER TABLE for each missing one.

function tableHasColumn(table, column) {
    return db
        .prepare(`PRAGMA table_info(${table})`)
        .all()
        .some((c) => c.name === column);
}

function addColumnIfMissing(table, column, definition) {
    if (!tableHasColumn(table, column)) {
        db.prepare(`ALTER TABLE ${table} ADD COLUMN ${column} ${definition}`).run();
    }
}

// Farmer profile fields (beyond the base name/email/password/location).
addColumnIfMissing("farmers", "phone", "TEXT");
addColumnIfMissing("farmers", "language", "TEXT");
addColumnIfMissing("farmers", "address", "TEXT");
addColumnIfMissing("farmers", "land_area", "TEXT");
addColumnIfMissing("farmers", "land_unit", "TEXT");
addColumnIfMissing("farmers", "soil_type", "TEXT");
addColumnIfMissing("farmers", "crops", "TEXT");
addColumnIfMissing("farmers", "irrigation", "TEXT");
addColumnIfMissing("farmers", "latitude", "TEXT");
addColumnIfMissing("farmers", "longitude", "TEXT");
addColumnIfMissing("farmers", "bank_account", "TEXT");
addColumnIfMissing("farmers", "ifsc", "TEXT");
addColumnIfMissing("farmers", "settlement_method", "TEXT");

// Buyer profile fields not already present in the buyers table.
addColumnIfMissing("buyers", "bank_account", "TEXT");
addColumnIfMissing("buyers", "ifsc", "TEXT");

// Back-fill the legacy farm_details JSON into the new farmer columns so
// existing rows keep their farming profile visible.
const farmersWithoutProfile = db
    .prepare("SELECT id, farm_details FROM farmers WHERE farm_details IS NOT NULL")
    .all();

const backfillFarmer = db.prepare(`
    UPDATE farmers
    SET land_area = ?,
        land_unit = COALESCE(land_unit, ?),
        soil_type = COALESCE(soil_type, ?),
        crops = COALESCE(crops, ?),
        irrigation = COALESCE(irrigation, ?)
    WHERE id = ?
`);

for (const farmer of farmersWithoutProfile) {
    let details = null;
    try {
        details = JSON.parse(farmer.farm_details);
    } catch (_) {
        details = null;
    }
    if (!details) continue;

    // Split a combined legacy value like "15 acres" into number + unit so the
    // UI's number field and unit dropdown can both be populated.
    let landArea = null;
    let landUnit = null;
    if (typeof details.land_area === "string") {
        const match = details.land_area.match(/^([\d.]+)\s*(.*)$/);
        if (match && match[2]) {
            landArea = match[1];
            landUnit = match[2];
        } else {
            landArea = details.land_area;
        }
    }

    backfillFarmer.run(
        landArea,
        landUnit,
        details.soil || null,
        Array.isArray(details.crops) ? details.crops.join(", ") : details.crops || null,
        details.irrigation || null,
        farmer.id
    );
}

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
// SAMPLE TEST ACCOUNTS
// =====================================================

const farmerCount = db
    .prepare("SELECT COUNT(*) AS count FROM farmers")
    .get();

if (farmerCount.count === 0) {
    db.prepare(`
        INSERT INTO farmers
        (name, email, password, location, farm_details)
        VALUES (?, ?, ?, ?, ?)
    `).run(
        "Ravi Kumar",
        "ravi@gmail.com",
        "123456",
        "Mysore",
        JSON.stringify({
            land_area: "15 acres",
            soil: "Red Soil",
            crops: ["Paddy", "Sugarcane", "Maize"],
            irrigation: "Borewell"
        })
    );
}

const buyerCount = db
    .prepare("SELECT COUNT(*) AS count FROM buyers")
    .get();

if (buyerCount.count === 0) {
    db.prepare(`
        INSERT INTO buyers
        (
            name,
            email,
            password,
            location,
            company_name,
            gst_pan,
            company_address,
            crops_interested,
            preferred_locations,
            contact_phone,
            payment_method
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
        "Arjun Kumar",
        "arjun@gmail.com",
        "123456",
        "Bengaluru",
        "GreenEarth Organics",
        "29AAACG1234H1Z5",
        "142, APMC Yard, Yeshwanthpur, Bengaluru, Karnataka 560022",
        "Paddy,Maize,Wheat",
        "Karnataka, Maharashtra",
        "9876543210",
        "bank_transfer"
    );
}

// =====================================================
// EXPORT DATABASE
// =====================================================

module.exports = db;