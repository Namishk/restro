const express = require("express");
const { Pool } = require("pg");

const app = express();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || "postgresql://restro_user:password@localhost:5432/restro_db",
    ssl: { rejectUnauthorized: false }
});

// Test connection
pool.connect((err, client, release) => {
    if (err) {
        console.error("Error connecting to PostgreSQL:", err);
    } else {
        console.log("Connected to PostgreSQL database");
        release();
    }
});

app.get("/restros", (req, res) => {
    pool.query("SELECT * FROM restros", (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result.rows);
    });
});

app.get("/dishes", (req, res) => {
    pool.query("SELECT * FROM dishes", (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result.rows);
    });
});

app.get("/orders", (req, res) => {
    pool.query("SELECT * FROM orders", (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result.rows);
    });
});

app.get("/search/dishes", (req, res) => {
    const { name, minPrice, maxPrice } = req.query;

    if (!name || !minPrice || !maxPrice) {
        return res.status(400).json({ error: "Missing required query parameters: name, minPrice, maxPrice" });
    }

    const query = `
        SELECT 
            r.id AS "restaurantId",
            r.name AS "restaurantName",
            r.city,
            d.name AS "dishName",
            d.price AS "dishPrice",
            COUNT(o.id) AS "orderCount"
        FROM dishes d
        JOIN restros r ON d.restro_id = r.id
        LEFT JOIN orders o ON d.id = o.dish_id
        WHERE d.name ILIKE $1 
          AND d.price >= $2 
          AND d.price <= $3
        GROUP BY r.id, d.id
        ORDER BY "orderCount" DESC
        LIMIT 10;
    `;

    pool.query(query, [`%${name}%`, minPrice, maxPrice], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ restaurants: result.rows });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
