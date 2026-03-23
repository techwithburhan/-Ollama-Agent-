<img width="1470" height="835" alt="Screenshot 2026-03-22 at 1 23 58 PM" src="https://github.com/user-attachments/assets/9e638dcd-0f76-4f6d-bb43-f20a6af988b6" />


<img width="1470" height="835" alt="Screenshot 2026-03-22 at 1 18 05 PM" src="https://github.com/user-attachments/assets/7e09b56d-310f-4b9a-a765-b34af103e845" />


<div align="center">

# 🤖 Ollama Agent

### Your Fully Offline AI Chat Assistant

![React](https://img.shields.io/badge/React-18.2-61DAFB?style=for-the-badge&logo=react&logoColor=black)
![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-6+-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-Local_LLM-FF6B35?style=for-the-badge)
![JWT](https://img.shields.io/badge/JWT-Auth-000000?style=for-the-badge&logo=jsonwebtokens)
![GSAP](https://img.shields.io/badge/GSAP-3.12-88CE02?style=for-the-badge)

**A production-ready, full-stack offline AI chat application — no API costs, no data leaks, runs 100% on your machine.**

[🚀 Quick Start](#-quick-start) • [📸 Features](#-features) • [📁 Structure](#-project-structure) • [🌐 API Docs](#-api-reference) • [☁️ AWS EC2](#️-aws-ec2-deployment) • [🐳 Docker](#-docker---coming-soon) • [☸️ Kubernetes](#️-kubernetes---coming-soon)

---

</div>

## 📖 About the Project

**Ollama Agent** is a fully offline, full-stack AI chat application that lets you run powerful Large Language Models (LLMs) directly on your own machine — no internet required, no API costs, and complete data privacy.

Built with a modern **glassmorphism UI**, real-time **streaming responses**, **voice input/output**, and **document attachment** — it delivers a ChatGPT-like experience entirely on your local system.

Whether you are a developer exploring local AI, a student learning full-stack development, or an enterprise user who needs a private AI assistant — Ollama Agent gives you a production-ready foundation to build on.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔒 **100% Offline & Private** | Your data never leaves your machine |
| ⚡ **Real-time Streaming** | Token-by-token responses via Server-Sent Events (SSE) |
| 🎤 **Voice Input** | Speak your prompts — Speech-to-Text built into the browser |
| 🔊 **Text-to-Speech** | AI responses read aloud automatically |
| 📎 **Document Attachment** | Attach PDF, TXT, CSV, JSON, code files and ask questions |
| 🤖 **Multi-Model Support** | Switch between llama2, mistral, llama3, codellama, gemma, phi |
| 💬 **Chat History** | Conversations saved to MongoDB per user |
| 🔐 **JWT Authentication** | Secure signup/login with bcrypt password hashing |
| 🎨 **Glassmorphism UI** | Dark theme with GSAP animations and glowing accents |
| 🗂️ **Chat Management** | Create, load, and delete past conversations |
| 📱 **Responsive Layout** | Collapsible sidebar + full-height chat area |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | React.js 18, React Router v6 |
| **Animations** | GSAP 3 |
| **Styling** | CSS Variables, Glassmorphism |
| **Backend** | Node.js, Express.js |
| **Database** | MongoDB, Mongoose |
| **Auth** | JWT + bcryptjs |
| **AI Engine** | Ollama (Local LLM) |
| **Voice Input** | Web Speech API (browser native) |
| **Voice Output** | SpeechSynthesis API (browser native) |
| **File Reading** | FileReader API (browser native) |
| **HTTP Client** | Axios |
| **Streaming** | Server-Sent Events (SSE) |

---

## 📁 Project Structure

```
ollama-agent/
├── frontend/                      # React.js 18 Frontend
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── context/
│   │   │   └── AuthContext.js     # Global auth state + JWT
│   │   ├── pages/
│   │   │   ├── Login.js           # Login page with GSAP animations
│   │   │   ├── Signup.js          # Signup page with GSAP animations
│   │   │   └── Chat.js            # Main chat (voice + attachments)
│   │   ├── App.js                 # Router + protected routes
│   │   ├── index.js               # React entry point
│   │   └── index.css              # Glassmorphism + CSS variables
│   └── package.json
│
├── backend/                       # Node.js + Express.js Backend
│   ├── models/
│   │   ├── User.js                # User schema (bcrypt hashing)
│   │   └── Chat.js                # Chat + message schema
│   ├── routes/
│   │   ├── auth.js                # /signup /login /me endpoints
│   │   └── chat.js                # /message /history /models endpoints
│   ├── middleware/
│   │   └── auth.js                # JWT protect middleware
│   ├── server.js                  # Express app entry point
│   ├── .env                       # Environment variables (never commit!)
│   └── package.json
│
└── README.md
```

---

## ✅ Prerequisites

Make sure the following are installed before you begin:

| Tool | Min Version | Download |
|------|------------|---------|
| Node.js | v18+ | https://nodejs.org |
| MongoDB | v6+ | https://mongodb.com/try/download/community |
| Ollama | Latest | https://ollama.ai |
| Git | Any | https://git-scm.com |

---

## 🚀 Quick Start

### Step 1 — Install & Run Ollama

```bash
# macOS / Linux
curl -fsSL https://ollama.ai/install.sh | sh

# Windows → Download from: https://ollama.ai/download/windows
```

**Pull a model** (choose one based on your RAM):

```bash
ollama pull llama2        # General purpose — 3.8 GB  ✅ Recommended
ollama pull mistral       # Fast & efficient — 4.1 GB
ollama pull llama3        # Best quality    — 4.7 GB
ollama pull codellama     # Code focused    — 3.8 GB
ollama pull phi           # Smallest/fastest — 1.7 GB  (Low RAM)
```

**Start the Ollama server:**

```bash
ollama serve
```

> ✅ Verify: Open http://localhost:11434 — you should see **"Ollama is running"**

---

### Step 2 — Start MongoDB

```bash
# macOS (Homebrew)
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community

# Ubuntu / Debian
sudo apt-get install -y mongodb
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Verify MongoDB is running
mongosh
```

> 💡 **Cloud option:** Use [MongoDB Atlas](https://cloud.mongodb.com) free tier and paste the connection string into your `.env` file.

---

### Step 3 — Setup Backend

```bash
cd ollama-agent/backend

# Install dependencies
npm install

# Generate a secure JWT secret key
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**Edit `backend/.env`:**

```env
PORT=5005
MONGO_URI=mongodb://localhost:27017/ollama-agent
JWT_SECRET=paste_your_generated_64byte_hex_key_here
OLLAMA_API=http://localhost:11434/api
OLLAMA_MODEL=llama2:latest
```

> ⚠️ **Never commit `.env` to Git.** It is already in `.gitignore`.

**Start the backend:**

```bash
# Development (auto-restart on changes)
npm run dev

# Production
npm start
```

**Expected output:**
```
✅ MongoDB Connected
🚀 Server running on http://localhost:5005
```

---

### Step 4 — Setup Frontend

```bash
cd ollama-agent/frontend

# Install dependencies
npm install

# Fix macOS proxy issue (create frontend/.env)
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true" > .env
echo "WDS_SOCKET_HOST=127.0.0.1" >> .env
echo "WDS_SOCKET_PORT=3000" >> .env

# Start the frontend
npm start
```

> ✅ Browser opens automatically at **http://localhost:3000**

---

### Step 5 — Run Everything

Open **3 terminals** and run:

```bash
# Terminal 1 — Ollama
ollama serve

# Terminal 2 — Backend
cd ollama-agent/backend && npm run dev

# Terminal 3 — Frontend
cd ollama-agent/frontend && npm start
```

Then open **http://localhost:3000**, sign up, and start chatting! 🎉

---

## 🌐 API Reference

### Auth Routes (Public)

| Method | Endpoint | Description | Body |
|--------|----------|-------------|------|
| `POST` | `/api/auth/signup` | Create new account | `{username, email, password}` |
| `POST` | `/api/auth/login` | Login | `{email, password}` |
| `GET` | `/api/auth/me` | Get current user | Bearer token required |

### Chat Routes (Bearer Token Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/chat/message` | Send message to Ollama (SSE streaming) |
| `GET` | `/api/chat/history` | Get all chats for the user |
| `GET` | `/api/chat/:chatId` | Load a specific chat |
| `DELETE` | `/api/chat/:chatId` | Delete a chat |
| `GET` | `/api/chat/models/list` | List available Ollama models |

**Test with curl:**

```bash
# Signup
curl -X POST http://localhost:5005/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"123456"}'

# Login
curl -X POST http://localhost:5005/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}'
```

---

## ☁️ AWS EC2 Deployment

### Recommended Instance Types

| Model | RAM Needed | EC2 Instance | vCPUs | Est. Cost/mo |
|-------|-----------|--------------|-------|--------------|
| phi (1.7 GB) | 4 GB | `t3.medium` | 2 | ~$30 |
| llama2 / mistral | 8 GB | `t3.large` | 2 | ~$60 |
| llama3 / codellama | 16 GB | `t3.xlarge` | 4 | ~$120 |
| Multiple models | 32 GB | `m5.2xlarge` | 8 | ~$280 |

### Minimum Specs

```
RAM     : 8 GB minimum (16 GB recommended)
vCPUs   : 2 minimum (4 recommended)
Storage : 30 GB gp3 EBS (50 GB recommended)
OS      : Ubuntu 22.04 LTS (x86_64)
```

### Security Group Inbound Rules

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | Your IP only | SSH |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |
| 3000 | TCP | 0.0.0.0/0 | React (dev) |
| 5005 | TCP | 0.0.0.0/0 | Backend (dev) |
| 11434 | TCP | 127.0.0.1/32 | Ollama (local only) |

### EC2 Setup Script (Ubuntu 22.04)

```bash
# Connect to EC2
ssh -i your-key.pem ubuntu@your-ec2-public-ip

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MongoDB
sudo apt-get install -y mongodb
sudo systemctl start mongodb && sudo systemctl enable mongodb

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve &
ollama pull llama2

# Clone & run project
git clone https://github.com/techwithburhan/ollama-agent.git
cd ollama-agent/backend && npm install && npm start &
cd ../frontend && npm install && npm run build
```

---

## 🐳 Docker — Coming Soon

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🚧  Docker setup guide, Dockerfile, and                   ║
║       docker-compose.yml will be added here.                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## ☸️ Kubernetes — Coming Soon

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🚧  Kubernetes manifests, Helm charts, and                ║
║       EKS/GKE deployment steps will be added here.          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

This structure follows best practices for scalable microservices architecture:
	•	🔹 Separation of frontend, backend, and database
	•	🔹 Kubernetes-native deployment strategy
	•	🔹 Auto-scaling with HPA
	•	🔹 Secure configuration using ConfigMaps & Secrets
	•	🔹 Persistent storage for stateful workloads

ollama-agent/
├── frontend/
├── backend/
└── k8s/
    ├── frontend/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── hpa.yaml
    │   └── configmap.yaml
    ├── backend/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── hpa.yaml
    │   ├── configmap.yaml
    │   └── secret.yaml
    ├── mongodb/
    │   ├── statefulset.yaml
    │   ├── service.yaml
    │   └── persistentvolumeclaim.yaml
    └── cluster/
        ├── namespace.yaml
        ├── ingress.yaml
        └── storageclass.yaml

```
## 📋 What Each File Does

| 📄 File                         | 📌 Purpose |
|--------------------------------|----------|
| `deployment.yaml`              | Runs application pods and manages replicas, container image, and resource limits |
| `service.yaml`                 | Exposes pods internally (ClusterIP) or externally (NodePort/LoadBalancer) |
| `hpa.yaml`                     | Automatically scales pods based on CPU or memory usage |
| `configmap.yaml`               | Stores non-sensitive configuration (e.g., API URLs, environment variables) |
| `secret.yaml`                  | Stores sensitive data (e.g., JWT secret, MongoDB URI) securely |
| `statefulset.yaml`             | Deploys MongoDB with stable identity and persistent storage |
| `persistentvolumeclaim.yaml`   | Requests and reserves storage for MongoDB data |
| `ingress.yaml`                 | Acts as a single entry point and routes traffic to services |
| `namespace.yaml`               | Creates an isolated Kubernetes namespace for the application |
| `storageclass.yaml`            | Defines storage provisioning (e.g., AWS EBS volumes) |

---

## 🏗️ Terraform — Coming Soon

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🚧  Terraform IaC scripts for AWS infrastructure          ║
║       (EC2, VPC, ALB, Route53) will be added here.          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 🎯 Interview Questions — Coming Soon

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🚧  Curated interview Q&A covering Node.js, React,        ║
║       MongoDB, Docker, Kubernetes, and AI/LLM topics        ║
║       will be added here.                                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 🐞 Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `EADDRINUSE :5000` | Port in use (AirPlay on macOS) | `lsof -ti:5000 \| xargs kill -9` or change PORT in `.env` |
| `allowedHosts` error | Node.js version mismatch | Add `DANGEROUSLY_DISABLE_HOST_CHECK=true` to `frontend/.env` |
| `net::ERR_FAILED` on login | CORS blocked on macOS | Use manual `res.header()` CORS instead of `cors()` package |
| Login fails with correct password | Email case mismatch | Use `email.toLowerCase().trim()` in login route |
| Ollama not responding | Server not running | Run `ollama serve` in a separate terminal |
| MongoDB connection error | Service stopped | `brew services start mongodb-community` (macOS) |
| Model not found | Not pulled yet | `ollama pull llama2:latest` |
| Chat not streaming | Proxy misconfigured | Use full URL `http://localhost:5005` in fetch() calls |

---

## 📦 Production Build

```bash
# Build React for production
cd frontend && npm run build

# Add to backend/server.js to serve the build
const path = require('path');
app.use(express.static(path.join(__dirname, '../frontend/build')));
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/build', 'index.html'));
});
```

Now your entire app runs on a single port: **http://localhost:5005** 🎉

---

## 🔐 Security Checklist

- [ ] Change `JWT_SECRET` to a randomly generated 64-byte hex string
- [ ] Never commit `.env` to Git (already in `.gitignore`)
- [ ] Keep Ollama API on `localhost` only (not exposed publicly)
- [ ] Use HTTPS in production (Nginx + Let's Encrypt)
- [ ] Restrict MongoDB to localhost in production
- [ ] Add rate limiting: `npm install express-rate-limit`

---
## Ollama Agent Project
```code
├── ✅ Full Stack Application
│   ├── ⚛️ Frontend: React.js
│   ├── 🖥️ Backend: Node.js + Express
│   └── 🗄️ Database: MongoDB
│
├── 🐳 Containerization
│   ├── Docker (Multi-stage builds)
│   └── docker-compose (Local Development)
│
├── 🔁 CI/CD Pipeline
│   └── GitHub Actions (Build, Test, Deploy)
│
├── ☸️ Kubernetes Deployment
│   ├── Deployment
│   ├── Service
│   ├── HPA (Auto Scaling)
│   ├── Ingress
│   └── Secrets
│
├── ☁️ Infrastructure (IaC)
│   └── Terraform (AWS Provisioning)
│
├── 🌍 Cloud Deployment
│   └── AWS (EC2 / EKS)
│
└── 📊 Monitoring
    ├── Prometheus
    └── Grafana
```
---

## ⭐ Support the Project

If you found this project helpful:

- 👍 **Give a thumbs up** on YouTube
- 🔔 **Subscribe** to the channel
- 🔗 **Follow** on LinkedIn
- ⭐ **Star** this GitHub repository

> Every bit of support helps create more free DevOps & AI content! 🙏

---

## 📲 Connect with @techwithburhan

<div align="center">

| Platform | Link |
|----------|------|
| 🎬 YouTube — DevOps \| AI \| AWS Cloud | [youtube.com/@TechWithBurhanHQ](https://www.youtube.com/@TechWithBurhanHQ) |
| 🎬 YouTube — CCNA \| CCNP \| Networking | [youtube.com/@codewithburhan1](https://youtube.com/@codewithburhan1) |
| 💼 LinkedIn | [linkedin.com/in/techwithburhan](https://linkedin.com/in/techwithburhan) |
| 📸 Instagram | [instagram.com/techwithburhan](https://instagram.com/techwithburhan) |
| 🌐 Agency Website | [techdeployers.com](https://techdeployers.com) |
| 🐙 GitHub | [github.com/techwithburhan](https://github.com/techwithburhan) |

</div>

---

<div align="center">

**Built with ❤️ by [@techwithburhan](https://github.com/techwithburhan)**

*React • Node.js • MongoDB • Ollama • GSAP*

</div>
