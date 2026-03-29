# #!/bin/bash

# echo ""
# echo "╔══════════════════════════════════════════════╗"
# echo "║   🗑️  Destroying Ollama Agent Deployment    ║"
# echo "╚══════════════════════════════════════════════╝"
# echo ""

# kubectl delete -f cluster/ingress.yaml --ignore-not-found
# kubectl delete -f frontend/hpa.yaml --ignore-not-found
# kubectl delete -f frontend/service.yaml --ignore-not-found
# kubectl delete -f frontend/deployment.yaml --ignore-not-found
# kubectl delete -f frontend/configmap.yaml --ignore-not-found
# kubectl delete -f backend/hpa.yaml --ignore-not-found
# kubectl delete -f backend/service.yaml --ignore-not-found
# kubectl delete -f backend/deployment.yaml --ignore-not-found
# kubectl delete -f backend/configmap.yaml --ignore-not-found
# kubectl delete -f backend/secret.yaml --ignore-not-found
# kubectl delete -f ollama/deployment.yaml --ignore-not-found
# kubectl delete -f ollama/nodeport.yaml --ignore-not-found
# kubectl delete -f ollama/service.yaml --ignore-not-found
# kubectl delete -f ollama/configmap.yaml --ignore-not-found
# kubectl delete -f ollama/pvc.yaml --ignore-not-found
# kubectl delete -f mongodb/statefulset.yaml --ignore-not-found
# kubectl delete -f mongodb/service.yaml --ignore-not-found
# kubectl delete -f mongodb/persistentvolumeclaim.yaml --ignore-not-found
# kubectl delete -f mongodb/configmap.yaml --ignore-not-found
# kubectl delete -f cluster/storageclass.yaml --ignore-not-found
# kubectl delete -f cluster/namespace.yaml --ignore-not-found

# echo ""
# echo "✅ All resources deleted."
# echo ""


#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   💣  Ollama Agent — Destroy Everything                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "  ⚠️  This will delete:"
echo "  🗂️   All Kubernetes resources (pods, services, volumes)"
echo "  🐳  KIND cluster 'ollama-agent'"
echo "  📦  All Docker containers, images & volumes"
echo ""
echo "  ❗ This action is IRREVERSIBLE"
echo ""

# ── Confirmation prompt ───────────────────────────────
read -p "  Are you sure you want to destroy everything? (yes/no): " CONFIRM
echo ""

if [ "$CONFIRM" != "yes" ]; then
  echo "  ❌ Cancelled. Nothing was deleted."
  echo ""
  exit 0
fi

echo "  🔥 Starting destruction..."
echo ""

# ── Stop port-forwards ────────────────────────────────
echo "┌─────────────────────────────────────────┐"
echo "│  🔌 Stopping port-forwards...           │"
echo "└─────────────────────────────────────────┘"
lsof -ti:3000  | xargs kill -9 2>/dev/null && echo "  ✅ Port 3000 released"  || echo "  ➖ Port 3000 was free"
lsof -ti:5005  | xargs kill -9 2>/dev/null && echo "  ✅ Port 5005 released"  || echo "  ➖ Port 5005 was free"
lsof -ti:11434 | xargs kill -9 2>/dev/null && echo "  ✅ Port 11434 released" || echo "  ➖ Port 11434 was free"
pkill -f "kubectl port-forward" 2>/dev/null && echo "  ✅ kubectl port-forwards killed" || echo "  ➖ No port-forwards running"
echo ""

# ── Delete Kubernetes resources ───────────────────────
echo "┌─────────────────────────────────────────┐"
echo "│  🗑️  Deleting Kubernetes resources...   │"
echo "└─────────────────────────────────────────┘"

echo "  🌐 Ingress..."
kubectl delete -f cluster/ingress.yaml --ignore-not-found 2>/dev/null
echo "  ✅ Ingress deleted"

echo "  🖥️  Frontend..."
kubectl delete -f frontend/hpa.yaml        --ignore-not-found 2>/dev/null
kubectl delete -f frontend/service.yaml    --ignore-not-found 2>/dev/null
kubectl delete -f frontend/deployment.yaml --ignore-not-found 2>/dev/null
kubectl delete -f frontend/configmap.yaml  --ignore-not-found 2>/dev/null
echo "  ✅ Frontend deleted"

echo "  ⚙️  Backend..."
kubectl delete -f backend/hpa.yaml        --ignore-not-found 2>/dev/null
kubectl delete -f backend/service.yaml    --ignore-not-found 2>/dev/null
kubectl delete -f backend/deployment.yaml --ignore-not-found 2>/dev/null
kubectl delete -f backend/configmap.yaml  --ignore-not-found 2>/dev/null
kubectl delete -f backend/secret.yaml     --ignore-not-found 2>/dev/null
echo "  ✅ Backend deleted"

echo "  🤖 Ollama..."
kubectl delete -f ollama/deployment.yaml --ignore-not-found 2>/dev/null
kubectl delete -f ollama/nodeport.yaml   --ignore-not-found 2>/dev/null
kubectl delete -f ollama/service.yaml    --ignore-not-found 2>/dev/null
kubectl delete -f ollama/configmap.yaml  --ignore-not-found 2>/dev/null
kubectl delete -f ollama/pvc.yaml        --ignore-not-found 2>/dev/null
echo "  ✅ Ollama deleted"

echo "  🍃 MongoDB..."
kubectl delete -f mongodb/statefulset.yaml         --ignore-not-found 2>/dev/null
kubectl delete -f mongodb/service.yaml             --ignore-not-found 2>/dev/null
kubectl delete -f mongodb/persistentvolumeclaim.yaml --ignore-not-found 2>/dev/null
kubectl delete -f mongodb/configmap.yaml           --ignore-not-found 2>/dev/null
echo "  ✅ MongoDB deleted"

echo "  🏗️  Cluster config..."
kubectl delete -f cluster/storageclass.yaml --ignore-not-found 2>/dev/null
kubectl delete -f cluster/namespace.yaml    --ignore-not-found 2>/dev/null
echo "  ✅ Namespace & StorageClass deleted"
echo ""

# ── Delete KIND cluster ───────────────────────────────
echo "┌─────────────────────────────────────────┐"
echo "│  ☸️  Deleting KIND cluster...            │"
echo "└─────────────────────────────────────────┘"
if kind get clusters 2>/dev/null | grep -q "^ollama-agent$"; then
  kind delete cluster --name ollama-agent
  echo "  ✅ KIND cluster 'ollama-agent' deleted"
else
  echo "  ➖ KIND cluster 'ollama-agent' not found — skipping"
fi
echo ""

# ── Docker cleanup ────────────────────────────────────
echo "┌─────────────────────────────────────────┐"
echo "│  🐳 Cleaning up Docker...               │"
echo "└─────────────────────────────────────────┘"

echo "  🛑 Stopping all containers..."
docker stop $(docker ps -q) 2>/dev/null && echo "  ✅ Containers stopped" || echo "  ➖ No running containers"

echo "  🗑️  Removing all containers..."
docker rm $(docker ps -aq) 2>/dev/null && echo "  ✅ Containers removed" || echo "  ➖ No containers to remove"

echo "  🖼️  Removing all images..."
docker rmi -f $(docker images -q) 2>/dev/null && echo "  ✅ Images removed" || echo "  ➖ No images to remove"

echo "  💾 Removing all volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null && echo "  ✅ Volumes removed" || echo "  ➖ No volumes to remove"

echo "  🧹 Running docker system prune..."
docker system prune -f 2>/dev/null
echo "  ✅ Docker cleaned"
echo ""

# ── Done ──────────────────────────────────────────────
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   ✅ Everything destroyed successfully!                 ║"
echo "║                                                          ║"
echo "║   💡 To redeploy run:  ./apply.sh                       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""