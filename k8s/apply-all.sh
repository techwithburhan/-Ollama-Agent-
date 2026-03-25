# #!/bin/bash
# # ════════════════════════════════════════════════════════════════════
# # Ollama Agent — Deploy Everything to Kubernetes
# #
# # Run this script to deploy the full app in the correct order
# # Usage:
# #   chmod +x apply-all.sh
# #   ./apply-all.sh
# # ════════════════════════════════════════════════════════════════════

# set -e   # Stop the script immediately if any command fails

# echo ""
# echo "╔═══════════════════════════════════════════╗"
# echo "║   🚀 Deploying Ollama Agent to K8s       ║"
# echo "╚═══════════════════════════════════════════╝"
# echo ""

# # ── Step 1: Namespace and Storage ────────────────────────────────────
# # Must be created first — everything else depends on them
# echo "Step 1/5 → Creating namespace and storage..."
# kubectl apply -f cluster/namespace.yaml       # Create the 'ollama-agent' namespace
# kubectl apply -f cluster/storageclass.yaml    # Create AWS EBS storage type
# echo "✅ Done"
# sleep 2

# # ── Step 2: MongoDB ───────────────────────────────────────────────────
# # Deploy database before backend (backend needs DB to start)
# echo ""
# echo "Step 2/5 → Deploying MongoDB..."
# kubectl apply -f mongodb/configmap.yaml             # Init script (creates collections)
# kubectl apply -f mongodb/service.yaml               # Headless service for MongoDB
# # kubectl apply -f mongodb/persistentvolumeclaim.yaml # Request 10GB disk
# kubectl apply -f mongodb/pv-local.yaml # Request 10GB disk
# kubectl apply -f mongodb/pvc-local.yaml # Request 10GB disk
# kubectl apply -f mongodb/statefulset.yaml           # MongoDB pod

# echo "Waiting for MongoDB to be ready (this may take ~60 seconds)..."
# kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=120s
# echo "✅ MongoDB is ready"
# sleep 5

# # ── Step 3: Backend ───────────────────────────────────────────────────
# echo ""
# echo "Step 3/5 → Deploying Backend..."
# kubectl apply -f backend/secret.yaml         # Passwords and JWT secret
# kubectl apply -f backend/configmap.yaml      # App settings (port, model, etc.)
# kubectl apply -f backend/deployment.yaml     # Backend pods
# kubectl apply -f backend/service.yaml        # Backend service
# kubectl apply -f backend/hpa.yaml            # Auto-scaling

# echo "Waiting for Backend to be ready..."
# kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s
# echo "✅ Backend is ready"
# sleep 3

# # ── Step 4: Frontend ──────────────────────────────────────────────────
# echo ""
# echo "Step 4/5 → Deploying Frontend..."
# kubectl apply -f frontend/configmap.yaml     # Nginx config
# kubectl apply -f frontend/deployment.yaml    # Frontend pods
# kubectl apply -f frontend/service.yaml       # Frontend service
# kubectl apply -f frontend/hpa.yaml           # Auto-scaling

# echo "Waiting for Frontend to be ready..."
# kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s
# echo "✅ Frontend is ready"
# sleep 2

# # ── Step 5: Ingress ───────────────────────────────────────────────────
# # Apply last — all services must exist before ingress can route to them
# echo ""
# echo "Step 5/5 → Applying Ingress (traffic routing)..."
# kubectl apply -f cluster/ingress.yaml
# echo "✅ Ingress applied"

# # ── Done ──────────────────────────────────────────────────────────────
# echo ""
# echo "╔═══════════════════════════════════════════╗"
# echo "║   ✅ Deployment complete!                ║"
# echo "╚═══════════════════════════════════════════╝"
# echo ""
# echo "All running pods:"
# kubectl get pods -n ollama-agent
# echo ""
# echo "All services:"
# kubectl get services -n ollama-agent
# echo ""
# echo "Ingress (get your external IP/domain here):"
# kubectl get ingress -n ollama-agent

#!/bin/bash
# ════════════════════════════════════════════════════════════════════
# Ollama Agent — Deploy to LOCAL KIND Cluster
#
# BEFORE RUNNING THIS SCRIPT make sure:
#   1. KIND cluster is running:
#        kind create cluster --name ollama-agent
#
#   2. Nginx Ingress Controller is installed:
#        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
#        kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
#
#   3. Ollama is running on your machine:
#        ollama serve
#        ollama pull llama2
#
#   4. Your Docker images exist on DockerHub:
#        burhan503/ollama-agent-frontend:latest
#        burhan503/ollama-agent-backend:latest
#
# Usage:
#   chmod +x apply-all.sh
#   ./apply-all.sh
#
# After deploy, open: http://localhost
# ════════════════════════════════════════════════════════════════════

set -e   # Stop immediately if any command fails

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║   🚀 Deploying Ollama Agent (Local K8s)  ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Step 1: Namespace and Storage
echo "Step 1/6 → Creating namespace and storage..."
kubectl apply -f cluster/namespace.yaml
kubectl apply -f cluster/storageclass.yaml
echo "✅ Done"
sleep 2
 
# Step 2: Secret — MUST be before MongoDB
# MongoDB reads MONGO_USERNAME and MONGO_PASSWORD from this secret at startup
# If this runs after MongoDB → CreateContainerConfigError
echo ""
echo "Step 2/6 → Applying Secret..."
kubectl apply -f backend/secret.yaml
echo "✅ Secret created"
sleep 1
 
# Step 3: MongoDB
echo ""
echo "Step 3/6 → Deploying MongoDB..."
kubectl apply -f mongodb/configmap.yaml
kubectl apply -f mongodb/service.yaml
kubectl apply -f mongodb/statefulset.yaml
 
echo "Waiting for MongoDB (may take ~60 seconds)..."
kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=180s
echo "✅ MongoDB ready"
sleep 5
 
# Step 4: Backend
echo ""
echo "Step 4/6 → Deploying Backend..."
kubectl apply -f backend/configmap.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/hpa.yaml
 
echo "Waiting for Backend..."
kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s
echo "✅ Backend ready"
sleep 3
 
# Step 5: Frontend
echo ""
echo "Step 5/6 → Deploying Frontend..."
kubectl apply -f frontend/configmap.yaml
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/hpa.yaml
 
echo "Waiting for Frontend..."
kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s
echo "✅ Frontend ready"
 
# Step 6: Ingress
echo ""
echo "Step 6/6 → Applying Ingress..."
kubectl apply -f cluster/ingress.yaml
echo "✅ Done"
 
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║   ✅ Deployment complete!                ║"
echo "║   Open: http://localhost                 ║"
echo "╚═══════════════════════════════════════════╝"
echo ""
kubectl get pods -n ollama-agent
echo ""
kubectl get services -n ollama-agent