# ============================================================
# OLLAMA AGENT - FRONTEND DOCKERFILE
# Multistage Build - 2 stages use honge
# Stage 1: React app build karega (Node.js use karke)
# Stage 2: Built files ko Nginx se serve karega
# Final image size: ~400MB se ghata ke ~25MB ho jayegi
# ============================================================


# ============================================================
# STAGE 1 - BUILDER STAGE
# Yahan React app ko build karenge
# Yeh stage sirf build ke liye hai - production mein nahi jayegi
# ============================================================

# Node.js 18 ka alpine version use karo
# alpine = bohot chhota Linux (5MB) - normal Ubuntu (200MB) se kam
# AS builder = is stage ka naam diya taaki Stage 2 mein refer kar sakein
FROM node:18-alpine AS builder

# ---- Metadata - Image ke baare mein information ----
LABEL maintainer="techwithburhan"
LABEL project="ollama-agent-frontend"
LABEL version="1.0.0"
LABEL description="Ollama Agent React Frontend - Multistage Docker Build"

# Working directory set karo container ke andar
# Matlab saari files /app folder mein jayengi
# Agar folder nahi hai toh Docker khud bana dega
WORKDIR /app

# ---- Dependencies Install Karna ----

# Pehle SIRF package.json copy karo (source code nahi)
# Kyun? Docker caching ki wajah se
# Agar package.json nahi badla toh npm install dobara nahi chalega
# Isse build time bohot fast ho jata hai
COPY package*.json ./

# npm install chalao saari dependencies install karne ke liye
# --legacy-peer-deps flag isliye lagaya kyunki
# react-scripts aur kuch packages mein peer dependency conflicts hain
# tumhare Node.js v24 ke saath - yeh flag unhe ignore kar deta hai
RUN npm install --legacy-peer-deps

# ---- Source Code Copy Karna ----

# Ab baaki saara source code copy karo
# Yeh pehle wali COPY se alag step hai intentionally
# Agar sirf src/ mein changes hue toh npm install dobara nahi chalega
# Docker layer caching ka smart use
COPY . .

# ---- Environment Variables ----

# REACT_APP_ prefix wale variables React build mein bake ho jaate hain
# ARG = build time pe pass kar sakte ho (--build-arg se)
# ENV = container ke andar available hoga

# Backend ka URL - default localhost hai
# AWS pe deploy karte waqt apna EC2 IP dena
# Example: docker build --build-arg REACT_APP_API_URL=http://54.123.456.789:5005
ARG REACT_APP_API_URL=http://localhost:5005
ENV REACT_APP_API_URL=$REACT_APP_API_URL

# App ka naam set karo
ENV REACT_APP_NAME="Ollama Agent"

# Production mode set karo
# Development wale .env variables yahan kaam nahi karte
# DANGEROUSLY_DISABLE_HOST_CHECK sirf npm start ke liye tha
# npm run build mein yeh variables needed nahi hain
ENV NODE_ENV=production

# ---- React App Build Karna ----

# npm run build chalao
# Yeh command React app ko optimize karke /app/build folder mein daalti hai
# JavaScript minify hoga, CSS compress hogi, images optimize hongi
# Yahi final files Nginx serve karega
RUN npm run build

# Build successfully hua ya nahi check karo
# Agar build folder nahi bana toh error throw karega
RUN test -d /app/build && echo "✅ Build successful!" || (echo "❌ Build failed!" && exit 1)


# ============================================================
# STAGE 2 - PRODUCTION STAGE
# Yahan sirf built files ko serve karenge Nginx se
# Node.js, npm, node_modules - kuch bhi nahi hoga yahan
# Isliye final image bohot chhoti hogi
# ============================================================

# Nginx ka alpine version - web server hai yeh
# Bilkul Apache jaisa but bohot fast aur lightweight
# Sirf ~5MB ka hai
FROM nginx:1.25-alpine AS production

# Working directory Nginx ke default folder pe set karo
WORKDIR /usr/share/nginx/html

# Default Nginx config hatao
# Kyunki humein custom config chahiye React Router ke liye
# Agar yeh nahi hatate toh React routing kaam nahi karegi
RUN rm -rf /etc/nginx/conf.d/default.conf

# Apna custom Nginx config copy karo
# nginx.conf file tumhare frontend/ folder mein honi chahiye
# Yeh file React Router ko properly handle karti hai
COPY nginx.conf /etc/nginx/conf.d/default.conf

# ---- Stage 1 se Built Files Copy Karna ----
# Yeh multistage build ka magic hai!
# --from=builder matlab Stage 1 (builder) se copy karo
# /app/build = Stage 1 mein jahan React build hua tha
# /usr/share/nginx/html = Nginx yahan se files serve karta hai
# Node.js, npm, node_modules - kuch bhi copy nahi hoga!
COPY --from=builder /app/build /usr/share/nginx/html

# ---- Security Settings ----

# Root user se nahi chalana chahiye production mein
# nginx user already exist karta hai alpine image mein
# Files ka ownership nginx user ko do
RUN chown -R nginx:nginx /usr/share/nginx/html

# ---- Health Check ----

# Har 30 second mein check karo app chal rahi hai ya nahi
# Agar 3 baar fail hua toh container unhealthy mark ho jaayega
# Kubernetes aur docker-compose isse use karte hain
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=10s \
            --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80 || exit 1

# ---- Port Expose Karna ----

# Container ka port 80 expose karo
# Nginx by default port 80 pe listen karta hai
# Yeh sirf documentation ke liye hai - actual port mapping
# docker run -p 3000:80 se hoti hai
EXPOSE 80

# ---- Container Start Karna ----

# Nginx start karo foreground mein
# "daemon off" isliye kyunki Docker ko foreground process chahiye
# Agar daemon mode mein chala toh container turant band ho jayega
CMD ["nginx", "-g", "daemon off;"]


# ============================================================
# BUILD COMMANDS - Yeh commands terminal mein chalao
# ============================================================

# Local build (development ke liye):
# docker build -t ollama-agent-frontend .

# AWS EC2 ke liye build:
# docker build \
#   --build-arg REACT_APP_API_URL=http://YOUR_EC2_IP:5005 \
#   -t ollama-agent-frontend .

# Container run karo:
# docker run -d -p 3000:80 --name frontend ollama-agent-frontend

# DockerHub pe push karo:
# docker tag ollama-agent-frontend techwithburhan/ollama-agent-frontend:latest
# docker push techwithburhan/ollama-agent-frontend:latest

# ============================================================
# IMAGE SIZE COMPARISON
# Without multistage: ~450MB (Node.js + node_modules included)
# With multistage:    ~25MB  (sirf Nginx + built files)
# Size reduction:     ~94% chhoti image!
# ============================================================
