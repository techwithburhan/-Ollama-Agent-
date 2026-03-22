const express = require("express");
const axios = require("axios");
const Chat = require("../models/Chat");
const { protect } = require("../middleware/auth");

const router = express.Router();

// @POST /api/chat/message - Send message to Ollama
router.post("/message", protect, async (req, res) => {
  try {
    const { message, chatId, model } = req.body;
    const ollamaModel = model || process.env.OLLAMA_MODEL || "llama2";

    // Set headers for streaming
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");

    // Call Ollama API
    const ollamaResponse = await axios({
      method: "post",
      url: `${process.env.OLLAMA_API}/generate`,
      data: {
        model: ollamaModel,
        prompt: message,
        stream: true,
      },
      responseType: "stream",
    });

    let fullResponse = "";

    ollamaResponse.data.on("data", (chunk) => {
      try {
        const lines = chunk.toString().split("\n").filter(Boolean);
        for (const line of lines) {
          const parsed = JSON.parse(line);
          if (parsed.response) {
            fullResponse += parsed.response;
            res.write(`data: ${JSON.stringify({ token: parsed.response, done: false })}\n\n`);
          }
          if (parsed.done) {
            res.write(`data: ${JSON.stringify({ token: "", done: true })}\n\n`);
          }
        }
      } catch (e) {
        // Skip malformed chunks
      }
    });

    ollamaResponse.data.on("end", async () => {
      // Save to MongoDB
      try {
        if (chatId) {
          await Chat.findByIdAndUpdate(chatId, {
            $push: {
              messages: [
                { role: "user", content: message },
                { role: "assistant", content: fullResponse },
              ],
            },
          });
        } else {
          await Chat.create({
            userId: req.user._id,
            title: message.substring(0, 50),
            messages: [
              { role: "user", content: message },
              { role: "assistant", content: fullResponse },
            ],
          });
        }
      } catch (dbErr) {
        console.error("DB save error:", dbErr.message);
      }
      res.end();
    });

    ollamaResponse.data.on("error", (err) => {
      res.write(`data: ${JSON.stringify({ error: err.message })}\n\n`);
      res.end();
    });
  } catch (error) {
    if (error.code === "ECONNREFUSED") {
      return res.status(503).json({
        message: "Ollama is not running. Please start Ollama first.",
      });
    }
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// @GET /api/chat/history - Get user chat history
router.get("/history", protect, async (req, res) => {
  try {
    const chats = await Chat.find({ userId: req.user._id })
      .sort({ updatedAt: -1 })
      .select("title createdAt updatedAt");
    res.json({ chats });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// @GET /api/chat/:chatId - Get specific chat
router.get("/:chatId", protect, async (req, res) => {
  try {
    const chat = await Chat.findOne({
      _id: req.params.chatId,
      userId: req.user._id,
    });
    if (!chat) return res.status(404).json({ message: "Chat not found" });
    res.json({ chat });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// @DELETE /api/chat/:chatId - Delete a chat
router.delete("/:chatId", protect, async (req, res) => {
  try {
    await Chat.findOneAndDelete({
      _id: req.params.chatId,
      userId: req.user._id,
    });
    res.json({ message: "Chat deleted" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// @GET /api/chat/models/list - Get available Ollama models
router.get("/models/list", protect, async (req, res) => {
  try {
    const response = await axios.get(`${process.env.OLLAMA_API.replace('/api', '')}/api/tags`);
    res.json({ models: response.data.models || [] });
  } catch (error) {
    res.status(503).json({ message: "Could not fetch models from Ollama" });
  }
});

module.exports = router;
