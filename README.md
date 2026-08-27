# AgriTrust
# DealCheck — Common APIs

## 🔐 Authentication
POST /api/auth/signup
POST /api/auth/login

## 🌾 Products / Sell Records
GET  /api/products
POST /api/products
GET  /api/products/:id

## 📩 Buyer Requests
GET  /api/requests
POST /api/requests
PUT  /api/requests/:id

## 🤝 Deals
GET  /api/deals
POST /api/deals
GET  /api/deals/:id
PUT  /api/deals/:id

## 🧮 Deal Calculations
GET  /api/deals/:id/calculation
POST /api/deals/:id/calculation

## 💰 Settlement
GET  /api/deals/:id/settlement
PUT  /api/deals/:id/settlement

## 📈 Market Prices
GET /api/market-prices

## 📍 Location
GET /api/locations