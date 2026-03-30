// const express = require("express");
// const mongoose = require("mongoose");
// const cors = require("cors");
// require("dotenv").config();

// const authRoutes = require("./routes/auth");
// const chatRoutes = require("./routes/chat");

// const app = express();

// // ✅ CORS — fully open for local development
// app.use((req, res, next) => {
//   res.header("Access-Control-Allow-Origin", "*");
//   res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
//   res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
//   if (req.method === "OPTIONS") {
//     return res.sendStatus(200);
//   }
//   next();
// });

// app.use(express.json());

// // ✅ MongoDB Connection
// mongoose
//   .connect(process.env.MONGO_URI)
//   .then(() => console.log("✅ MongoDB Connected"))
//   .catch((err) => console.error("❌ MongoDB Error:", err));

// // ✅ Routes
// app.use("/api/auth", authRoutes);
// app.use("/api/chat", chatRoutes);

// // ✅ Health check
// app.get("/", (req, res) => {
//   res.json({ message: "Ollama Agent API is running 🚀" });
// });

// // ✅ Global error handler
// app.use((err, req, res, next) => {
//   console.error("❌ Server Error:", err.message);
//   res.status(500).json({ message: "Internal server error", error: err.message });
// });

// const PORT = process.env.PORT || 5005;
// app.listen(PORT, () => {
//   console.log(`🚀 Server running on http://localhost:${PORT}`);
// });

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const chatRoutes = require("./routes/chat");

const app = express();

// ✅ CORS — reads allowed origins from env var, supports multiple origins
const rawOrigins = process.env.CORS_ORIGINS || "";
const allowedOrigins = rawOrigins
  .split(",")
  .map((o) => o.trim())
  .filter(Boolean);

// Always allow these as fallback (relative-origin requests from nginx proxy have no origin header)
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (server-to-server, curl, mobile apps)
    if (!origin) return callback(null, true);
    if (allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    console.warn(`⚠️  CORS blocked origin: ${origin}`);
    return callback(new Error(`CORS policy: origin ${origin} not allowed`));
  },
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
  optionsSuccessStatus: 200, // Some browsers (IE11) choke on 204
};

app.use(cors(corsOptions));

// ✅ Handle preflight OPTIONS for all routes
app.options("*", cors(corsOptions));

app.use(express.json());

// ✅ MongoDB Connection
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.error("❌ MongoDB Error:", err));

// ✅ Routes
app.use("/api/auth", authRoutes);
app.use("/api/chat", chatRoutes);

// ✅ Health check
app.get("/", (req, res) => {
  res.json({ message: "Ollama Agent API is running 🚀" });
});

// ✅ Global error handler
app.use((err, req, res, next) => {
  console.error("❌ Server Error:", err.message);
  res.status(500).json({ message: "Internal server error", error: err.message });
});

const PORT = process.env.PORT || 5005;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`✅ Allowed CORS origins: ${allowedOrigins.join(", ") || "ALL (open)"}`);
});