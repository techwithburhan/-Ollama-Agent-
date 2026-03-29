Great question! Based on your README, here's exactly what to implement on AWS to make this project live and enterprise-grade.

---

## 🏗️ Your Target AWS Architecture

```
Internet
    │
    ▼
Route 53 (DNS)
    │
    ▼
CloudFront (CDN + WAF)
    │
    ▼
Application Load Balancer (ALB)
    │
    ├──── /api/*  ──► EC2 Auto Scaling Group (Backend + Kubernetes)
    │
    └──── /*      ──► S3 Static Website (React Build)
                           │
                    EC2 (Ollama + MongoDB)
                    Private Subnet
```

---

## ☁️ Step 1 — EC2 Instance Setup

### What to Use

```
Instance:  t2.large (2 vCPU, 8GB RAM) ← llama2/mistral ke liye
OS:        Ubuntu 22.04 LTS
Storage:   50GB gp3 EBS (Ollama models ke liye)
Region:    us-east-1 (cheapest)
```

### Create EC2 via AWS Console

```bash
# Launch EC2
# AMI: Ubuntu 22.04
# Type: t2.large
# Storage: 50GB gp3
# Key pair: create + download .pem

# Connect
ssh -i ollama-agent.pem ubuntu@YOUR_EC2_IP

# Setup script
sudo apt-get update && sudo apt-get upgrade -y

# Docker install
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu
newgrp docker

# Docker Compose
sudo apt-get install -y docker-compose-plugin

# Ollama
curl -fsSL https://ollama.ai/install.sh | sh
OLLAMA_HOST=0.0.0.0 ollama serve &
ollama pull tinyllama

# KIND + kubectl
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Clone and deploy
git clone https://github.com/techwithburhan/ollama-agent.git
cd ollama-agent
chmod +x apply.sh && ./apply.sh
```

---

## 🔐 Step 2 — Security Groups (Firewall Rules)

**Create 2 separate Security Groups:**

### SG-1: ALB Security Group (Public)

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |

### SG-2: EC2 Security Group (Private)

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | **Your IP only** | SSH |
| 80 | TCP | **SG-1 only** | From ALB |
| 443 | TCP | **SG-1 only** | From ALB |
| 3000 | TCP | **SG-1 only** | Frontend |
| 5005 | TCP | **SG-1 only** | Backend API |
| 11434 | TCP | **127.0.0.1/32** | Ollama — NEVER public |
| 27017 | TCP | **127.0.0.1/32** | MongoDB — NEVER public |

> ⚠️ **Critical rule:** Ollama port 11434 and MongoDB 27017 must NEVER be open to internet. If someone gets access to Ollama, they can run unlimited AI on your server for free.

---

## ⚖️ Step 3 — Application Load Balancer (ALB)

ALB ek entry point deta hai — HTTP/HTTPS traffic manage karta hai.

### Create ALB

```
AWS Console → EC2 → Load Balancers → Create
Type: Application Load Balancer
Scheme: Internet-facing
Listeners:
  - HTTP:80  → redirect to HTTPS:443
  - HTTPS:443 → forward to Target Group

Target Group:
  - Type: Instances
  - Protocol: HTTP
  - Port: 80 (or 8080 for Ingress)
  - Health check: GET /api/health
  - Register: your EC2 instance
```

### ALB Routing Rules

```
HTTPS:443 → Default → Target Group (frontend)
HTTPS:443 → /api/*  → Target Group (backend port 5005)
HTTP:80   → Redirect → HTTPS:443
```

**Resume bullet:**
```
• Configured AWS ALB with path-based routing — /api/* to 
  backend, /* to frontend — with HTTP→HTTPS redirect
```

---

## 🌐 Step 4 — Route 53 (Custom Domain)

Route 53 se custom domain attach karo tumhare ALB pe.

### Steps

```bash
# 1. Buy domain in Route 53 (~$12/year for .com)
# Or transfer existing domain

# 2. Create Hosted Zone
AWS Console → Route 53 → Hosted Zones → Create
Domain: yourdomain.com

# 3. Create A Record
Name: yourdomain.com
Type: A - Alias
Alias to: Application Load Balancer
Region: us-east-1
Select your ALB

# 4. Create CNAME for www
Name: www.yourdomain.com
Type: CNAME
Value: yourdomain.com
```

**After this your app is live at:**
```
https://yourdomain.com        ← Frontend
https://yourdomain.com/api/   ← Backend
```

**Resume bullet:**
```
• Configured Route 53 with A-record alias to ALB for 
  custom domain routing with automatic DNS failover
```

---

## 🔒 Step 5 — SSL Certificate (ACM — Free)

HTTPS ke liye free SSL certificate AWS Certificate Manager se.

```bash
# AWS Console → Certificate Manager → Request
Domain: yourdomain.com
Also add: *.yourdomain.com (wildcard)
Validation: DNS validation

# AWS automatically adds CNAME records to Route 53
# Certificate active in 2-5 minutes

# Attach to ALB
ALB → Listeners → HTTPS:443 → Edit → Default SSL Certificate → Select ACM cert
```

**Resume bullet:**
```
• Provisioned free SSL/TLS certificate via AWS ACM and 
  attached to ALB — enabling HTTPS with automatic renewal
```

---

## 🛡️ Step 6 — WAF (Web Application Firewall)

WAF aapki app ko attacks se protect karta hai — SQL injection, XSS, DDoS.

### Create WAF Web ACL

```
AWS Console → WAF & Shield → Web ACLs → Create
Name: ollama-agent-waf
Region: us-east-1 (for ALB)

Add Managed Rules (free):
✅ AWSManagedRulesCommonRuleSet     ← XSS, SQL injection, general
✅ AWSManagedRulesKnownBadInputsRuleSet  ← Bad bots, log4j
✅ AWSManagedRulesAmazonIpReputationList ← Known bad IPs

Custom Rules (add these):
✅ Rate limit: 2000 req/5min per IP  ← DDoS protection
✅ Block: requests from countries you don't serve (optional)
✅ Allow: your IP always (whitelist)

Associate WAF to: your ALB
```

**Why WAF for your project specifically:**
```
Your Ollama API is expensive to run (CPU/RAM)
Without WAF: bot floods /api/chat → server crashes + high bill
With WAF: rate limiting blocks after 2000 req/5min per IP
```

**Resume bullet:**
```
• Implemented AWS WAF with managed rule sets (OWASP Top 10) 
  and custom rate limiting (2000 req/5min) to protect Ollama 
  API from DDoS and abuse
```

---

## 📈 Step 7 — Auto Scaling Group

EC2 Auto Scaling ensures high availability — agar ek EC2 crash ho toh automatically naya launch hoga.

### Create Auto Scaling Group

```bash
# Step 1: Create AMI from your configured EC2
EC2 → Instances → Select your EC2 → Actions → Image → Create Image
Name: ollama-agent-ami

# Step 2: Create Launch Template
EC2 → Launch Templates → Create
AMI: your ollama-agent-ami
Instance type: t2.large
Security Group: SG-2 (EC2)
User Data (startup script):
#!/bin/bash
cd /home/ubuntu/ollama-agent
OLLAMA_HOST=0.0.0.0 ollama serve &
sleep 10
ollama pull tinyllama
./apply.sh

# Step 3: Create Auto Scaling Group
EC2 → Auto Scaling Groups → Create
Launch Template: above
VPC: your VPC
Subnets: at least 2 AZs (us-east-1a, us-east-1b)
Load Balancer: attach your ALB Target Group

Scaling Policy:
  Min: 1 instance
  Desired: 1 instance
  Max: 3 instances
  Scale out: CPU > 70% → add 1 instance
  Scale in:  CPU < 30% → remove 1 instance
  
Health checks:
  EC2 health check: enabled
  ELB health check: enabled
  Grace period: 300 seconds (app startup time)
```

**Resume bullet:**
```
• Configured EC2 Auto Scaling Group with ALB health checks — 
  automatically replaces failed instances and scales 1→3 EC2s 
  based on CPU utilization thresholds
```

---

## 🌍 Step 8 — CloudFront (CDN)

CloudFront React static files globally cache karega — faster loading worldwide.

```bash
AWS Console → CloudFront → Create Distribution

Origin: your ALB DNS name

Behaviors:
  /api/*:
    Cache: Disabled (dynamic content)
    Forward headers: Authorization, Content-Type
    Allowed methods: GET, POST, DELETE, OPTIONS, HEAD, PUT, PATCH
  
  /* (default):
    Cache: Enabled (React static files)
    TTL: 86400 (1 day)
    Compress: Yes

Settings:
  Alternate domain: yourdomain.com
  SSL Certificate: your ACM cert
  HTTP version: HTTP/2
  
WAF: attach your Web ACL
```

> **Important for SSE streaming:**
> CloudFront buffers responses by default. For `/api/chat` (SSE), set:
> ```
> Cache Policy: Disabled
> Origin Request Policy: Forward all headers
> ```

**Resume bullet:**
```
• Deployed CloudFront CDN distribution with ALB origin — 
  caching React assets at edge locations, reducing latency by 
  ~60% for global users
```

---

## 💾 Step 9 — S3 for Frontend (Optional but Impressive)

React build files S3 pe host karo — EC2 pe load nahi padega.

```bash
# Build React
cd frontend
npm run build

# Create S3 bucket
aws s3 mb s3://ollama-agent-frontend

# Enable static website hosting
aws s3 website s3://ollama-agent-frontend \
  --index-document index.html \
  --error-document index.html

# Upload build files
aws s3 sync build/ s3://ollama-agent-frontend \
  --cache-control "max-age=31536000" \
  --exclude "index.html"

aws s3 cp build/index.html s3://ollama-agent-frontend/index.html \
  --cache-control "no-cache"

# Point CloudFront to S3 instead of ALB for frontend
```

---

## 🔑 Step 10 — AWS Secrets Manager

JWT Secret aur MongoDB URI ko EC2 .env mein nahi — Secrets Manager mein rakho.

```bash
# Store secrets
aws secretsmanager create-secret \
  --name "ollama-agent/jwt-secret" \
  --secret-string "your_jwt_secret_here"

aws secretsmanager create-secret \
  --name "ollama-agent/mongo-uri" \
  --secret-string "mongodb://localhost:27017/ollama-agent"

# Fetch in backend at startup
# Add to server.js:
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");

const client = new SecretsManagerClient({ region: "us-east-1" });
const secret = await client.send(new GetSecretValueCommand({
  SecretId: "ollama-agent/jwt-secret"
}));
process.env.JWT_SECRET = secret.SecretString;
```

**IAM Role for EC2:**
```
EC2 → IAM Role → Create
Policy: SecretsManagerReadWrite (scoped to your secrets only)
Attach to EC2 instance
```

**Resume bullet:**
```
• Integrated AWS Secrets Manager to securely store JWT and 
  database credentials — fetched at runtime via IAM role, 
  eliminating hardcoded secrets from codebase
```

---

## 📊 Step 11 — CloudWatch Monitoring

```bash
# EC2 metrics dashboard
CloudWatch → Dashboards → Create → ollama-agent

Widgets to add:
✅ EC2 CPUUtilization
✅ EC2 NetworkIn/Out
✅ ALB RequestCount
✅ ALB HTTPCode_ELB_5XX (errors)
✅ ALB TargetResponseTime

# Alarms
CloudWatch → Alarms → Create

Alarm 1: High CPU
  Metric: EC2 CPUUtilization
  Threshold: > 80%
  Action: Send SNS email to your email

Alarm 2: High Error Rate
  Metric: ALB HTTPCode_ELB_5XX
  Threshold: > 10
  Action: Send SNS email

Alarm 3: Ollama Down
  Metric: ALB HealthyHostCount
  Threshold: < 1
  Action: Send SNS email + trigger Auto Scaling
```

---

## 📋 Complete AWS Resume Section

Here's how to write all of this on your resume:

```
Ollama Agent — Offline AI Chat Application (AWS Production Deployment)
Tech: React • Node.js • MongoDB • Ollama • Docker • Kubernetes • AWS

• Deployed containerized full-stack AI application on AWS EC2 (t2.large)
  running Kubernetes (KIND) — managing 6 services across 3 namespaces

• Configured AWS ALB with path-based routing (/api/* → backend, 
  /* → frontend) and HTTP→HTTPS redirect

• Provisioned free SSL/TLS certificate via AWS ACM attached to ALB
  for HTTPS with automatic renewal

• Registered custom domain with Route 53 — A-record alias to ALB
  for zero-downtime DNS failover

• Implemented AWS WAF with OWASP managed rules and custom rate limiting
  (2000 req/5min per IP) protecting Ollama API from DDoS and abuse

• Built EC2 Auto Scaling Group with ALB health checks — automatically 
  replaces unhealthy instances and scales 1→3 nodes at 70% CPU

• Deployed CloudFront CDN distribution for React static assets —
  reducing global latency with edge caching

• Stored JWT and MongoDB credentials in AWS Secrets Manager — 
  fetched at runtime via IAM role, eliminating plaintext secrets

• Configured CloudWatch dashboards and alarms for CPU, error rates,
  and ALB health with SNS email notifications
```

---

## 🎯 Implementation Priority

Do it in this order — each step adds a new resume line:

| Week | Task | Resume Impact |
|------|------|--------------|
| Week 1 | EC2 + Security Groups + app running live | ⭐⭐⭐ |
| Week 1 | ALB + HTTPS redirect | ⭐⭐⭐ |
| Week 2 | ACM certificate + HTTPS | ⭐⭐⭐ |
| Week 2 | Route 53 custom domain | ⭐⭐⭐⭐ |
| Week 3 | WAF + rate limiting | ⭐⭐⭐⭐ |
| Week 3 | Auto Scaling Group | ⭐⭐⭐⭐⭐ |
| Week 4 | CloudFront CDN | ⭐⭐⭐⭐ |
| Week 4 | Secrets Manager | ⭐⭐⭐⭐ |
| Week 5 | CloudWatch dashboards + alarms | ⭐⭐⭐ |

**Start with Week 1** — just EC2 + ALB + your app live with a real URL gives you the most immediate impact. Everything after is layers on top. 🚀
