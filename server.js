// server.js
const express = require("express");
const mysql = require("mysql2/promise");
const dotenv = require("dotenv");

dotenv.config();
const app = express();
app.use(express.json());

// create MySQL connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

// test route
app.get("/foods", async (req, res) => {
  const [rows] = await pool.query("SELECT * FROM food WHERE data_type = 'foundation_food' AND description LIKE '%beef%'");
  res.json(rows);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
