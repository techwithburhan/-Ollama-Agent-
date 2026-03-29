#!/bin/bash
set -e

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   🚀 Deploying Ollama Agent (Local K8s)     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Step 0: Create KIND Cluster ───────────────────────
echo "Step 0/7 → Creating KIND cluster..."

# Check if cluster already exists
if kind get clusters 2>/dev/null | grep -q "^ollama-agent$"; then
  echo "⚠️  KIND cluster 'ollama-agent' already exists — skipping creation"
else
  kind create cluster --name ollama-agent --config cluster-create/kind-config.yaml
  echo "✅ KIND cluster created"
fi

echo ""
echo "Verifying cluster..."
kubectl cluster-info --context kind-ollama-agent
echo ""
kubectl get nodes
echo ""
sleep 3

# ── Install Nginx Ingress Controller ─────────────────
echo "Installing Nginx Ingress Controller for KIND..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress controller to be ready (up to 120s)..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo "✅ Ingress controller ready"
sleep 2

# ── Step 1: Namespace and Storage ────────────────────
echo ""
echo "Step 1/7 → Creating namespace and storage..."
kubectl apply -f cluster/namespace.yaml
kubectl apply -f cluster/storageclass.yaml
echo "✅ Done"
sleep 2

# ── Step 2: Secret ────────────────────────────────────
echo ""
echo "Step 2/7 → Applying Secret..."
kubectl apply -f backend/secret.yaml
echo "✅ Secret created"
sleep 1

# ── Step 3: MongoDB ───────────────────────────────────
echo ""
echo "Step 3/7 → Deploying MongoDB..."
kubectl apply -f mongodb/configmap.yaml
kubectl apply -f mongodb/persistentvolumeclaim.yaml
kubectl apply -f mongodb/service.yaml
kubectl apply -f mongodb/statefulset.yaml
echo "Waiting for MongoDB (may take ~60 seconds)..."
kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=180s
echo "✅ MongoDB ready"
sleep 5

# ── Step 4: Ollama ────────────────────────────────────
echo ""
echo "Step 4/7 → Deploying Ollama (tinyllama download ~600MB)..."
kubectl apply -f ollama/pvc.yaml
kubectl apply -f ollama/configmap.yaml
kubectl apply -f ollama/service.yaml
kubectl apply -f ollama/nodeport.yaml
kubectl apply -f ollama/deployment.yaml
echo ""
echo "⏳ tinyllama downloading — watch progress in another terminal:"
echo "   kubectl logs -f -n ollama-agent \$(kubectl get pod -n ollama-agent -l app=ollama -o jsonpath='{.items[0].metadata.name}') -c pull-tinyllama"
echo ""
echo "Waiting for Ollama (may take 3-10 min on first run)..."
kubectl rollout status deployment/ollama -n ollama-agent --timeout=600s
echo "✅ Ollama ready"
sleep 5

# ── Step 5: Backend ───────────────────────────────────
echo ""
echo "Step 5/7 → Deploying Backend..."
kubectl apply -f backend/configmap.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/hpa.yaml
echo "Waiting for Backend..."
kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s
echo "✅ Backend ready"
sleep 3

# ── Step 6: Frontend ──────────────────────────────────
echo ""
echo "Step 6/7 → Deploying Frontend..."
kubectl apply -f frontend/configmap.yaml
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/hpa.yaml
echo "Waiting for Frontend..."
kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s
echo "✅ Frontend ready"

# ── Step 7: Ingress ───────────────────────────────────
echo ""
echo "Step 7/7 → Applying Ingress..."
kubectl apply -f cluster/ingress.yaml
echo "✅ Done"

# ── Summary ───────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ Deployment complete!                   ║"
echo "║                                              ║"
echo "║   App:     http://localhost                  ║"
echo "║   Ollama:  http://localhost:31434            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
kubectl get pods -n ollama-agent
echo ""
kubectl get services -n ollama-agent

# ── Port Forwards ─────────────────────────────────────
echo ""
echo "Starting port-forwards in background..."

# Kill any existing port-forwards on these ports first
echo "Checking for existing processes on ports 3000 and 5005..."
lsof -ti:3000 | xargs kill -9 2>/dev/null && echo "  Killed process on port 3000" || echo "  Port 3000 is free"
lsof -ti:5005 | xargs kill -9 2>/dev/null && echo "  Killed process on port 5005" || echo "  Port 5005 is free"
lsof -ti:11434 | xargs kill -9 2>/dev/null && echo "  Killed process on port 11434" || echo "  Port 11434 is free"
sleep 1

# Start port-forwards in background
kubectl port-forward svc/ollama-frontend-service 3000:80 -n ollama-agent > /tmp/pf-frontend.log 2>&1 &
echo "✅ Frontend   → http://localhost:3000"

kubectl port-forward svc/ollama-backend-service 5005:5005 -n ollama-agent > /tmp/pf-backend.log 2>&1 &
echo "✅ Backend    → http://localhost:5005"

kubectl port-forward svc/ollama-service 11434:11434 -n ollama-agent > /tmp/pf-ollama.log 2>&1 &
echo "✅ Ollama     → http://localhost:11434"

sleep 2

# Quick health check
echo ""
echo "Testing backend health..."
curl -s http://localhost:5005/api/health && echo "" || echo "⚠️  Backend not responding yet — give it a few more seconds"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   🌐 Open http://localhost:3000             ║"
echo "║                                              ║"
echo "║   To stop port-forwards:                    ║"
echo "║   ./port-forward.sh stop                    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
