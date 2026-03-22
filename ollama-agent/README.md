# 🤖 Ollama Agent — Complete Setup Documentation

> **Created by @techwithburhan**
> A full-stack offline AI chat application powered by Ollama, React, Node.js & MongoDB

---

## 📁 Project Structure

```
ollama-agent/
├── frontend/                  # React.js frontend
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── context/
│   │   │   └── AuthContext.js
│   │   ├── pages/
│   │   │   ├── Login.js
│   │   │   ├── Signup.js
│   │   │   └── Chat.js
│   │   ├── App.js
│   │   ├── index.js
│   │   └── index.css
│   └── package.json
│
├── backend/                   # Node.js + Express backend
│   ├── models/
│   │   ├── User.js
│   │   └── Chat.js
│   ├── routes/
│   │   ├── auth.js
│   │   └── chat.js
│   ├── middleware/
│   │   └── auth.js
│   ├── server.js
│   ├── .env
│   └── package.json
│
└── README.md
```

---

## ✅ Prerequisites

Before starting, make sure you have the following installed:

| Tool | Version | Download |
|------|---------|----------|
| Node.js | v18+ | https://nodejs.org |
| MongoDB | v6+ | https://mongodb.com |
| Ollama | Latest | https://ollama.ai |
| Git | Any | https://git-scm.com |

---

## 🚀 Step 1 — Install & Start Ollama

### Install Ollama
```bash
# Linux / macOS
curl -fsSL https://ollama.ai/install.sh | sh

# Windows
# Download from: https://ollama.ai/download/windows
```

### Pull a Model (choose one)
```bash
# Llama 2 (recommended, 3.8GB)
ollama pull llama2

# Mistral (faster, 4.1GB)
ollama pull mistral

# Llama 3 (best quality, 4.7GB)
ollama pull llama3

# Phi-2 (smallest, 1.7GB — good for low-RAM)
ollama pull phi
```

### Start Ollama Server
```bash
ollama serve
```

### Verify Ollama is Running
Open your browser and go to: http://localhost:11434
You should see: **"Ollama is running"**

Or test via terminal:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Hello!",
  "stream": false
}'
```

---

## 🗄️ Step 2 — Install & Start MongoDB

### Option A: Local MongoDB
```bash
# macOS (with Homebrew)
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community

# Ubuntu / Debian
sudo apt-get install -y mongodb
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Windows
# Download from: https://www.mongodb.com/try/download/community
# Run as a service after installation
```

### Option B: MongoDB Atlas (Cloud — Free)
1. Go to https://cloud.mongodb.com
2. Create a free cluster
3. Get your connection string:
   `mongodb+srv://username:password@cluster.mongodb.net/ollama-agent`
4. Replace `MONGO_URI` in `.env` with this string

### Verify MongoDB is Running
```bash
mongosh
# You should see the MongoDB shell prompt
# Type: show dbs
# Type: exit
```

---

## ⚙️ Step 3 — Setup Backend (Node.js)

### Navigate to backend folder
```bash
cd ollama-agent/backend
```

### Install Dependencies
```bash
npm install
```

### Configure Environment Variables
Edit the `.env` file:
```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/ollama-agent
JWT_SECRET=your_super_secret_key_make_it_long_and_random_12345
OLLAMA_API=http://localhost:11434/api
OLLAMA_MODEL=llama2
```

> ⚠️ **Important:** Change `JWT_SECRET` to a long random string in production!

### Start the Backend

**Development mode (auto-restart on changes):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

You should see:
```
✅ MongoDB Connected
🚀 Server running on http://localhost:5000
```

### Test Backend API
```bash
# Health check
curl http://localhost:5000

# Test signup
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"123456"}'
```

---

## 🎨 Step 4 — Setup Frontend (React.js)

### Navigate to frontend folder
```bash
cd ollama-agent/frontend
```

### Install Dependencies
```bash
npm install
```

> This installs: React, React Router, Axios, GSAP, Lucide React, React Markdown

### Start the Frontend
```bash
npm start
```

The browser will automatically open: **http://localhost:3000**

---

## 🔗 Step 5 — Connect Frontend to Backend

The `package.json` already has a proxy configured:
```json
"proxy": "http://localhost:5000"
```

This means all `/api/...` calls from React will automatically go to `http://localhost:5000/api/...`

**No extra configuration needed!** ✅

---

## 🌐 API Endpoints Reference

### Auth Routes

| Method | Endpoint | Description | Body |
|--------|----------|-------------|------|
| POST | `/api/auth/signup` | Create new account | `{username, email, password}` |
| POST | `/api/auth/login` | Login to account | `{email, password}` |
| GET | `/api/auth/me` | Get current user | — (needs token) |

### Chat Routes (All require Bearer token)

| Method | Endpoint | Description | Body |
|--------|----------|-------------|------|
| POST | `/api/chat/message` | Send message to Ollama | `{message, chatId?, model?}` |
| GET | `/api/chat/history` | Get all chat history | — |
| GET | `/api/chat/:chatId` | Load specific chat | — |
| DELETE | `/api/chat/:chatId` | Delete a chat | — |
| GET | `/api/chat/models/list` | List Ollama models | — |

---

## 🧪 Testing the Full Flow

1. Open **http://localhost:3000**
2. Click **"Create one"** to sign up with a new account
3. Fill in username, email, password → Click **"Create account"**
4. You'll be redirected to the chat page
5. Type a message and press **Enter**
6. Watch the AI respond in real-time with streaming!

---

## 🐞 Troubleshooting

### ❌ "Ollama is not running" error
```bash
# Make sure Ollama is running
ollama serve

# Check if port 11434 is open
curl http://localhost:11434
```

### ❌ MongoDB connection error
```bash
# Check if MongoDB is running
sudo systemctl status mongodb   # Linux
brew services list | grep mongo  # macOS

# Restart MongoDB
sudo systemctl restart mongodb
```

### ❌ "CORS error" in browser
Make sure both servers are running:
- Backend: http://localhost:5000
- Frontend: http://localhost:3000

### ❌ Model not found error
```bash
# List installed models
ollama list

# Pull the model mentioned in your .env
ollama pull llama2
```

### ❌ Port already in use
```bash
# Kill process on port 5000
lsof -ti:5000 | xargs kill -9   # macOS/Linux
netstat -ano | findstr :5000     # Windows (then Task Manager > End task)

# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

### ❌ npm install fails
```bash
# Clear npm cache and retry
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

---

## 🔧 Changing the AI Model

### Method 1: From the UI
Use the **model dropdown** in the top header of the chat page

### Method 2: Via .env
Edit `backend/.env`:
```env
OLLAMA_MODEL=mistral
```

### Available models to pull:
```bash
ollama pull llama2      # General purpose
ollama pull llama3      # Best quality
ollama pull mistral     # Fast & good
ollama pull codellama   # Code focused
ollama pull gemma       # Google's model
ollama pull phi         # Smallest/fastest
```

---

## 🚀 Running Everything at Once

Create a script `start.sh` in the root folder:
```bash
#!/bin/bash
echo "Starting Ollama Agent..."

# Start Ollama
ollama serve &
echo "✅ Ollama started"

# Start MongoDB
sudo systemctl start mongodb
echo "✅ MongoDB started"

# Start Backend
cd backend && npm run dev &
echo "✅ Backend started on port 5000"

# Start Frontend
cd ../frontend && npm start &
echo "✅ Frontend started on port 3000"

echo "🚀 All services running!"
echo "Open: http://localhost:3000"
```

Make it executable:
```bash
chmod +x start.sh
./start.sh
```

---

## 📦 Production Build

### Build React for production:
```bash
cd frontend
npm run build
```

### Serve the build with Express:
Add this to `backend/server.js`:
```javascript
const path = require('path');

// Serve static files from React build
app.use(express.static(path.join(__dirname, '../frontend/build')));

// Catch-all route for React
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/build', 'index.html'));
});
```

Now your entire app runs on http://localhost:5000 🎉

---

## 🔐 Security Notes for Production

1. **Change JWT_SECRET** to a long random string:
   ```bash
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```

2. **Use environment variables** — never commit `.env` to Git

3. **Add `.env` to `.gitignore`**:
   ```
   node_modules/
   .env
   frontend/build/
   ```

4. **Use HTTPS** in production with Nginx + Let's Encrypt

5. **Rate limit your API** — add `express-rate-limit`:
   ```bash
   npm install express-rate-limit
   ```

---

## 📞 Tech Stack Summary

| Layer | Technology |
|-------|-----------|
| Frontend | React.js 18, React Router v6 |
| Styling | CSS Variables, Glassmorphism |
| Animations | GSAP 3 |
| Backend | Node.js, Express.js |
| Database | MongoDB + Mongoose |
| Auth | JWT (JSON Web Tokens) + bcryptjs |
| AI Engine | Ollama (local LLM) |
| HTTP Client | Axios |
| Streaming | Server-Sent Events (SSE) |

---

## 👨‍💻 Created By

**@techwithburhan**

> Built with ❤️ using React, Node.js, MongoDB & Ollama
