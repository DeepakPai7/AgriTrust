# AgriTrust

# agritrust — Common APIs

## 🔐 Authentication

```text
POST /api/auth/signup
POST /api/auth/login
```

## 🌾 Products / Sell Records

```text
GET  /api/products
POST /api/products
GET  /api/products/:id
```

## 📩 Buyer Requests

```text
GET  /api/requests
POST /api/requests
PUT  /api/requests/:id
```

## 🤝 Deals

```text
GET  /api/deals
POST /api/deals
GET  /api/deals/:id
PUT  /api/deals/:id
```

## 🧮 Deal Calculations

```text
GET  /api/deals/:id/calculation
POST /api/deals/:id/calculation
```

## 💰 Settlement

```text
GET  /api/deals/:id/settlement
PUT  /api/deals/:id/settlement
```

## 📈 Market Prices

```text
GET /api/market-prices
```

## 📍 Location

```text
GET /api/locations
```