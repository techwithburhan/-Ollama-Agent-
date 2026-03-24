db = db.getSiblingDB("ollama-agent");

db.createCollection("users");
db.createCollection("chats");
