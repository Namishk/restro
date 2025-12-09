const express = require("express");
const mysql = require("mysql2");

const app = express();

const db = mysql.createPool({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "password",
    database: process.env.DB_NAME || "restro_db",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test connection
db.getConnection((err, connection) => {
    if (err) {
        console.error("Error connecting to MySQL:", err);
    } else {
        console.log("Connected to MySQL database");
        connection.release();
    }
});

app.get("/restros", (req, res) => {
    db.query("SELECT * FROM restros", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get("/dishes", (req, res) => {
    db.query("SELECT * FROM dishes", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get("/orders", (req, res) => {
    db.query("SELECT * FROM orders", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

app.get("/search/dishes", (req, res) => {
    const { name, minPrice, maxPrice } = req.query;

    if (!name || !minPrice || !maxPrice) {
        return res.status(400).json({ error: "Missing required query parameters: name, minPrice, maxPrice" });
    }

    const query = `
        SELECT 
            r.id AS restaurantId,
            r.name AS restaurantName,
            r.city,
            d.name AS dishName,
            d.price AS dishPrice,
            COUNT(o.id) AS orderCount
        FROM dishes d
        JOIN restros r ON d.restro_id = r.id
        LEFT JOIN orders o ON d.id = o.dish_id
        WHERE d.name LIKE ? 
          AND d.price >= ? 
          AND d.price <= ?
        GROUP BY r.id, d.id
        ORDER BY orderCount DESC
        LIMIT 10;
    `;

    db.query(query, [`%${name}%`, minPrice, maxPrice], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ restaurants: results });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
