Got it 👍 Burhan — main tumhare commands ko clean karke ek professional README.md bana deta hoon jo GitHub pe bhi use kar sakte ho.

⸻

📄 README.md

# 🤖 Ollama Agent Backend

This is the backend service for the Ollama Agent project. It runs inside a Docker container and connects to Ollama for AI-powered responses.

---

## 🚀 Getting Started

### 1️⃣ Create `.env` File

Make sure you have a `.env` file in your project root:

```env
PORT=5005
MONGO_URI=mongodb://localhost:27017/ollama-agent
JWT_SECRET=your_secret_key
OLLAMA_BASE_URL=http://host.docker.internal:11434
MODEL=llama3


⸻

2️⃣ Run Backend using Docker

docker run -p 5005:5005 --env-file .env ollama-agent-backend


⸻

🔁 Restart / Fix Port Issues

If port 5005 is already in use, stop existing container:

docker stop $(docker ps -q --filter "publish=5005")

Then run again:

docker run -p 5005:5005 --env-file .env ollama-agent-backend


⸻

🧠 Ollama Setup (Important)

Make sure Ollama is running on your system:

ollama serve

Pull and run model:

ollama pull llama3
ollama run llama3


⸻

🔍 Verify Backend

Open in browser or use curl:

curl http://localhost:5005


⸻

⚠️ Common Issues

❌ Ollama not connecting
	•	Ensure Ollama is running on http://localhost:11434
	•	Inside Docker, use:

host.docker.internal:11434



⸻

❌ Port already in use

docker stop $(docker ps -q --filter "publish=5005")


⸻

🧹 Useful Commands

# Stop container running on port 5005
docker stop $(docker ps -q --filter "publish=5005")

# Run backend
docker run -p 5005:5005 --env-file .env ollama-agent-backend

# Clear terminal
clear

# Edit env file
vim .env


⸻

📌 Notes
	•	Backend runs on: http://localhost:5005
	•	Ollama runs on: http://localhost:11434
	•	Ensure both are running for full functionality

⸻

💡 Future Improvements
	•	Add Docker Compose
	•	Kubernetes deployment
	•	CI/CD pipeline

⸻

👨‍💻 Author

Burhan
Tech with Burhan 🚀

---

## 🔥 Extra सुझाव (Pro Level)

Agar tum isko aur strong banana chahte ho (resume + GitHub ke liye):

- `docker-compose.yml` add karo  
- health check endpoint add karo  
- README me architecture diagram daalo  

---

Agar chaho to main next step me tumhare liye:

✅ **Docker Compose setup**  
✅ **Kubernetes YAML (resume ready)**  
✅ **System design explanation (interview ke liye)**  

bhi bana deta hoon 🚀
