const express = require("express");
const cors = require("cors");

const db = require("./database");
const authRoutes = require("./routes/auth");
const dealRoutes = require("./routes/deals");
const calculationRoutes = require("./routes/calculations");
const app = express();
const locationRoutes = require("./routes/locations");
const marketPriceRoutes = require("./routes/marketPrices");
const settlementRoutes = require("./routes/settlements");
const productRoutes = require("./routes/products");
const requestRoutes = require("./routes/requests");
app.use(cors());
app.use(express.json());

// Authentication routes
app.use("/api/auth", authRoutes);
app.use("/api/locations", locationRoutes);
app.use("/api/products", productRoutes);
app.use("/api/requests", requestRoutes);
app.use("/api/deals", dealRoutes);
app.use("/api/deals", calculationRoutes);
app.use("/api/deals", settlementRoutes);
app.use("/api/market-prices", marketPriceRoutes);
// Test route
app.get("/", (req, res) => {
    res.json({
        success: true,
        message: "AgriTrust backend is running"
    });
});

const PORT = 3000;

app.listen(PORT, () => {
    console.log(`AgriTrust backend running on port ${PORT}`);
});