# # # # # # #!/bin/bash
# # # # # # # ════════════════════════════════════════════════════════════════════
# # # # # # # Ollama Agent — Deploy Everything to Kubernetes
# # # # # # #
# # # # # # # Run this script to deploy the full app in the correct order
# # # # # # # Usage:
# # # # # # #   chmod +x apply-all.sh
# # # # # # #   ./apply-all.sh
# # # # # # # ════════════════════════════════════════════════════════════════════

# # # # # # set -e   # Stop the script immediately if any command fails

# # # # # # echo ""
# # # # # # echo "╔═══════════════════════════════════════════╗"
# # # # # # echo "║   🚀 Deploying Ollama Agent to K8s       ║"
# # # # # # echo "╚═══════════════════════════════════════════╝"
# # # # # # echo ""

# # # # # # # ── Step 1: Namespace and Storage ────────────────────────────────────
# # # # # # # Must be created first — everything else depends on them
# # # # # # echo "Step 1/5 → Creating namespace and storage..."
# # # # # # kubectl apply -f cluster/namespace.yaml       # Create the 'ollama-agent' namespace
# # # # # # kubectl apply -f cluster/storageclass.yaml    # Create AWS EBS storage type
# # # # # # echo "✅ Done"
# # # # # # sleep 2

# # # # # # # ── Step 2: MongoDB ───────────────────────────────────────────────────
# # # # # # # Deploy database before backend (backend needs DB to start)
# # # # # # echo ""
# # # # # # echo "Step 2/5 → Deploying MongoDB..."
# # # # # # kubectl apply -f mongodb/configmap.yaml             # Init script (creates collections)
# # # # # # kubectl apply -f mongodb/service.yaml               # Headless service for MongoDB
# # # # # # # kubectl apply -f mongodb/persistentvolumeclaim.yaml # Request 10GB disk
# # # # # # kubectl apply -f mongodb/pv-local.yaml # Request 10GB disk
# # # # # # kubectl apply -f mongodb/pvc-local.yaml # Request 10GB disk
# # # # # # kubectl apply -f mongodb/statefulset.yaml           # MongoDB pod

# # # # # # echo "Waiting for MongoDB to be ready (this may take ~60 seconds)..."
# # # # # # kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=120s
# # # # # # echo "✅ MongoDB is ready"
# # # # # # sleep 5

# # # # # # # ── Step 3: Backend ───────────────────────────────────────────────────
# # # # # # echo ""
# # # # # # echo "Step 3/5 → Deploying Backend..."
# # # # # # kubectl apply -f backend/secret.yaml         # Passwords and JWT secret
# # # # # # kubectl apply -f backend/configmap.yaml      # App settings (port, model, etc.)
# # # # # # kubectl apply -f backend/deployment.yaml     # Backend pods
# # # # # # kubectl apply -f backend/service.yaml        # Backend service
# # # # # # kubectl apply -f backend/hpa.yaml            # Auto-scaling

# # # # # # echo "Waiting for Backend to be ready..."
# # # # # # kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s
# # # # # # echo "✅ Backend is ready"
# # # # # # sleep 3

# # # # # # # ── Step 4: Frontend ──────────────────────────────────────────────────
# # # # # # echo ""
# # # # # # echo "Step 4/5 → Deploying Frontend..."
# # # # # # kubectl apply -f frontend/configmap.yaml     # Nginx config
# # # # # # kubectl apply -f frontend/deployment.yaml    # Frontend pods
# # # # # # kubectl apply -f frontend/service.yaml       # Frontend service
# # # # # # kubectl apply -f frontend/hpa.yaml           # Auto-scaling

# # # # # # echo "Waiting for Frontend to be ready..."
# # # # # # kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s
# # # # # # echo "✅ Frontend is ready"
# # # # # # sleep 2

# # # # # # # ── Step 5: Ingress ───────────────────────────────────────────────────
# # # # # # # Apply last — all services must exist before ingress can route to them
# # # # # # echo ""
# # # # # # echo "Step 5/5 → Applying Ingress (traffic routing)..."
# # # # # # kubectl apply -f cluster/ingress.yaml
# # # # # # echo "✅ Ingress applied"

# # # # # # # ── Done ──────────────────────────────────────────────────────────────
# # # # # # echo ""
# # # # # # echo "╔═══════════════════════════════════════════╗"
# # # # # # echo "║   ✅ Deployment complete!                ║"
# # # # # # echo "╚═══════════════════════════════════════════╝"
# # # # # # echo ""
# # # # # # echo "All running pods:"
# # # # # # kubectl get pods -n ollama-agent
# # # # # # echo ""
# # # # # # echo "All services:"
# # # # # # kubectl get services -n ollama-agent
# # # # # # echo ""
# # # # # # echo "Ingress (get your external IP/domain here):"
# # # # # # kubectl get ingress -n ollama-agent

# # # # # #!/bin/bash
# # # # # # ════════════════════════════════════════════════════════════════════
# # # # # # Ollama Agent — Deploy to LOCAL KIND Cluster
# # # # # #
# # # # # # BEFORE RUNNING THIS SCRIPT make sure:
# # # # # #   1. KIND cluster is running:
# # # # # #        kind create cluster --name ollama-agent
# # # # # #
# # # # # #   2. Nginx Ingress Controller is installed:
# # # # # #        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# # # # # #        kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
# # # # # #
# # # # # #   3. Ollama is running on your machine:
# # # # # #        ollama serve
# # # # # #        ollama pull llama2
# # # # # #
# # # # # #   4. Your Docker images exist on DockerHub:
# # # # # #        burhan503/ollama-agent-frontend:latest
# # # # # #        burhan503/ollama-agent-backend:latest
# # # # # #
# # # # # # Usage:
# # # # # #   chmod +x apply-all.sh
# # # # # #   ./apply-all.sh
# # # # # #
# # # # # # After deploy, open: http://localhost
# # # # # # ════════════════════════════════════════════════════════════════════

# # # # # set -e   # Stop immediately if any command fails

# # # # # echo ""
# # # # # echo "╔═══════════════════════════════════════════╗"
# # # # # echo "║   🚀 Deploying Ollama Agent (Local K8s)  ║"
# # # # # echo "╚═══════════════════════════════════════════╝"
# # # # # echo ""

# # # # # # Step 1: Namespace and Storage
# # # # # echo "Step 1/6 → Creating namespace and storage..."
# # # # # kubectl apply -f cluster/namespace.yaml
# # # # # kubectl apply -f cluster/storageclass.yaml
# # # # # echo "✅ Done"
# # # # # sleep 2
 
# # # # # # Step 2: Secret — MUST be before MongoDB
# # # # # # MongoDB reads MONGO_USERNAME and MONGO_PASSWORD from this secret at startup
# # # # # # If this runs after MongoDB → CreateContainerConfigError
# # # # # echo ""
# # # # # echo "Step 2/6 → Applying Secret..."
# # # # # kubectl apply -f backend/secret.yaml
# # # # # echo "✅ Secret created"
# # # # # sleep 1
 
# # # # # # Step 3: MongoDB
# # # # # echo ""
# # # # # echo "Step 3/6 → Deploying MongoDB..."
# # # # # kubectl apply -f mongodb/configmap.yaml
# # # # # kubectl apply -f mongodb/service.yaml
# # # # # kubectl apply -f mongodb/statefulset.yaml
 
# # # # # echo "Waiting for MongoDB (may take ~60 seconds)..."
# # # # # kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=180s
# # # # # echo "✅ MongoDB ready"
# # # # # sleep 5
 
# # # # # # Step 4: Backend
# # # # # echo ""
# # # # # echo "Step 4/6 → Deploying Backend..."
# # # # # kubectl apply -f backend/configmap.yaml
# # # # # kubectl apply -f backend/deployment.yaml
# # # # # kubectl apply -f backend/service.yaml
# # # # # kubectl apply -f backend/hpa.yaml
 
# # # # # echo "Waiting for Backend..."
# # # # # kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s
# # # # # echo "✅ Backend ready"
# # # # # sleep 3
 
# # # # # # Step 5: Frontend
# # # # # echo ""
# # # # # echo "Step 5/6 → Deploying Frontend..."
# # # # # kubectl apply -f frontend/configmap.yaml
# # # # # kubectl apply -f frontend/deployment.yaml
# # # # # kubectl apply -f frontend/service.yaml
# # # # # kubectl apply -f frontend/hpa.yaml
 
# # # # # echo "Waiting for Frontend..."
# # # # # kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s
# # # # # echo "✅ Frontend ready"
 
# # # # # # Step 6: Ingress
# # # # # echo ""
# # # # # echo "Step 6/6 → Applying Ingress..."
# # # # # kubectl apply -f cluster/ingress.yaml
# # # # # echo "✅ Done"
 
# # # # # echo ""
# # # # # echo "╔═══════════════════════════════════════════╗"
# # # # # echo "║   ✅ Deployment complete!                ║"
# # # # # echo "║   Open: http://localhost                 ║"
# # # # # echo "╚═══════════════════════════════════════════╝"
# # # # # echo ""
# # # # # kubectl get pods -n ollama-agent
# # # # # echo ""
# # # # # kubectl get services -n ollama-agent

# # # # #!/bin/bash
# # # # set -e

# # # # echo ""
# # # # echo "╔═══════════════════════════════════════════╗"
# # # # echo "║ 🚀 Full Setup: KIND + K8s + Ollama Stack ║"
# # # # echo "╚═══════════════════════════════════════════╝"
# # # # echo ""

# # # # # ── Step 0: Create KIND Cluster ─────────────────────────────
# # # # echo "Step 0/9 → Creating KIND cluster..."

# # # # cd ./kind-cluster-create

# # # # kind create cluster --name ollama-agent --config kind-config.yml || true

# # # # echo "✅ Cluster created"

# # # # # Verify cluster
# # # # echo ""
# # # # echo "🔍 Verifying cluster..."
# # # # kubectl cluster-info --context kind-ollama-agent
# # # # kubectl get nodes
# # # # echo "✅ Cluster ready"
# # # # sleep 3

# # # # # ── Step 1: Install Ingress Controller ──────────────────────
# # # # echo ""
# # # # echo "Step 1/9 → Installing NGINX Ingress..."

# # # # kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# # # # echo "Waiting for Ingress Controller..."
# # # # kubectl wait --namespace ingress-nginx \
# # # #   --for=condition=ready pod \
# # # #   --selector=app.kubernetes.io/component=controller \
# # # #   --timeout=120s

# # # # kubectl get pods -n ingress-nginx
# # # # echo "✅ Ingress ready"
# # # # sleep 3

# # # # # वापस project root me aao
# # # # cd ./cluster

# # # # # ── Step 2: Namespace + Storage ─────────────────────────────
# # # # echo ""
# # # # echo "Step 2/9 → Creating namespace and storage..."
# # # # kubectl apply -f cluster/namespace.yaml
# # # # kubectl apply -f cluster/storageclass.yaml
# # # # echo "✅ Done"
# # # # sleep 2

# # # # # ── Step 3: Ollama ──────────────────────────────────────────
# # # # echo ""
# # # # echo "Step 3/9 → Deploying Ollama..."
# # # # kubectl apply -f k8s/ollama/pvc.yaml
# # # # kubectl apply -f k8s/ollama/configmap.yaml
# # # # kubectl apply -f k8s/ollama/deployment.yaml
# # # # kubectl apply -f k8s/ollama/service.yaml

# # # # echo "Waiting for Ollama..."
# # # # kubectl rollout status deployment/ollama -n ollama-agent --timeout=180s
# # # # echo "✅ Ollama ready"

# # # # # Install model
# # # # OLLAMA_POD=$(kubectl get pods -n ollama-agent -l app=ollama -o jsonpath="{.items[0].metadata.name}")
# # # # echo "📦 Installing llama2 model..."
# # # # kubectl exec -it $OLLAMA_POD -n ollama-agent -- ollama pull llama2 || true

# # # # sleep 5

# # # # # ── Step 4: Secrets ─────────────────────────────────────────
# # # # echo ""
# # # # echo "Step 4/9 → Applying Secrets..."
# # # # kubectl apply -f backend/secret.yaml
# # # # echo "✅ Done"
# # # # sleep 1

# # # # # ── Step 5: MongoDB ─────────────────────────────────────────
# # # # echo ""
# # # # echo "Step 5/9 → Deploying MongoDB..."
# # # # kubectl apply -f mongodb/configmap.yaml
# # # # kubectl apply -f mongodb/service.yaml
# # # # kubectl apply -f mongodb/statefulset.yaml

# # # # echo "Waiting for MongoDB..."
# # # # kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=180s
# # # # echo "✅ MongoDB ready"
# # # # sleep 5

# # # # # ── Step 6: Backend ─────────────────────────────────────────
# # # # echo ""
# # # # echo "Step 6/9 → Deploying Backend..."
# # # # kubectl apply -f backend/configmap.yaml
# # # # kubectl apply -f backend/deployment.yaml
# # # # kubectl apply -f backend/service.yaml
# # # # kubectl apply -f backend/hpa.yaml

# # # # echo "Waiting for Backend..."
# # # # kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s
# # # # echo "✅ Backend ready"
# # # # sleep 3

# # # # # ── Step 7: Frontend ────────────────────────────────────────
# # # # echo ""
# # # # echo "Step 7/9 → Deploying Frontend..."
# # # # kubectl apply -f frontend/configmap.yaml
# # # # kubectl apply -f frontend/deployment.yaml
# # # # kubectl apply -f frontend/service.yaml
# # # # kubectl apply -f frontend/hpa.yaml

# # # # echo "Waiting for Frontend..."
# # # # kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s
# # # # echo "✅ Frontend ready"

# # # # # ── Step 8: Ingress ─────────────────────────────────────────
# # # # echo ""
# # # # echo "Step 8/9 → Applying Ingress..."
# # # # kubectl apply -f cluster/ingress.yaml
# # # # echo "✅ Done"

# # # # # ── Step 9: Final Check ─────────────────────────────────────
# # # # echo ""
# # # # echo "Step 9/9 → Final status..."
# # # # kubectl get all -n ollama-agent

# # # # echo ""
# # # # echo "🔍 Ollama Pods:"
# # # # kubectl get pods -n ollama-agent | grep ollama

# # # # echo ""
# # # # echo "╔═══════════════════════════════════════════╗"
# # # # echo "║   ✅ FULL DEPLOYMENT COMPLETE 🚀         ║"
# # # # echo "║   🌐 Open: http://localhost             ║"
# # # # echo "╚═══════════════════════════════════════════╝"

#!/bin/bash
set -e

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║ 🚀 Full Setup: KIND + K8s + Ollama Stack ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Always run from script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Step 0: Create KIND Cluster ─────────────────────────────
echo "Step 0/9 → Creating KIND cluster..."

kind create cluster --name ollama-agent --config kind-cluster-create/kind-config.yml || true

echo "🔍 Verifying cluster..."
kubectl cluster-info --context kind-ollama-agent
kubectl get nodes
echo "✅ Cluster ready"
sleep 3

# ── Step 1: Install Ingress ────────────────────────────────
echo ""
echo "Step 1/9 → Installing NGINX Ingress..."

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

kubectl get pods -n ingress-nginx
echo "✅ Ingress ready"
sleep 3

# ── Step 2: Namespace + Storage ─────────────────────────────
echo ""
echo "Step 2/9 → Creating namespace..."
kubectl apply -f cluster/namespace.yaml
kubectl apply -f cluster/storageclass.yaml
echo "✅ Done"
sleep 2

# ── Step 3: Ollama ──────────────────────────────────────────
echo ""
echo "Step 3/9 → Deploying Ollama..."
kubectl apply -f ollama/pvc.yaml
kubectl apply -f ollama/configmap.yaml
kubectl apply -f ollama/deployment.yaml
kubectl apply -f ollama/service.yaml

echo "Waiting for Ollama..."
kubectl rollout status deployment/ollama -n ollama-agent --timeout=180s

# Install model
OLLAMA_POD=$(kubectl get pods -n ollama-agent -l app=ollama -o jsonpath="{.items[0].metadata.name}")
echo "📦 Installing llama2 model..."
kubectl exec -it $OLLAMA_POD -n ollama-agent -- ollama pull llama2 || true

echo "✅ Ollama ready"
sleep 5

# ── Step 4: Secret ──────────────────────────────────────────
echo ""
echo "Step 4/9 → Applying Secret..."
kubectl apply -f backend/secret.yaml
echo "✅ Done"

# ── Step 5: MongoDB ─────────────────────────────────────────
echo ""
echo "Step 5/9 → Deploying MongoDB..."
kubectl apply -f mongodb/configmap.yaml
kubectl apply -f mongodb/service.yaml
kubectl apply -f mongodb/statefulset.yaml

kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=180s
echo "✅ MongoDB ready"
sleep 5

# ── Step 6: Backend ─────────────────────────────────────────
echo ""
echo "Step 6/9 → Deploying Backend..."
kubectl apply -f backend/configmap.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/hpa.yaml

kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s
echo "✅ Backend ready"
sleep 3

# ── Step 7: Frontend ────────────────────────────────────────
echo ""
echo "Step 7/9 → Deploying Frontend..."
kubectl apply -f frontend/configmap.yaml
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/hpa.yaml

kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s
echo "✅ Frontend ready"

# ── Step 8: Ingress ─────────────────────────────────────────
echo ""
echo "Step 8/9 → Applying Ingress..."
kubectl apply -f cluster/ingress.yaml
echo "✅ Done"

# ── Step 9: Final Check ─────────────────────────────────────
echo ""
echo "📊 Final Status:"
kubectl get all -n ollama-agent

echo ""
echo "🔍 Ollama Pods:"
kubectl get pods -n ollama-agent | grep ollama

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║   ✅ FULL DEPLOYMENT COMPLETE 🚀         ║"
echo "║   🌐 Open: http://localhost             ║"
echo "╚═══════════════════════════════════════════╝"

# # #!/bin/bash
# # # ============================================================
# # # OLLAMA AGENT — Full Kubernetes Deployment Script
# # # With Real Progress Bar for Ollama Model Download
# # # Usage: chmod +x apply-all.sh && ./apply-all.sh
# # # ============================================================

# # set -e

# # # ── Colors ──────────────────────────────────────────────────
# # RED='\033[0;31m'
# # GREEN='\033[0;32m'
# # YELLOW='\033[1;33m'
# # CYAN='\033[0;36m'
# # PURPLE='\033[0;35m'
# # WHITE='\033[1;37m'
# # NC='\033[0m' # No Color

# # # ── Script Directory ────────────────────────────────────────
# # SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# # cd "$SCRIPT_DIR"

# # # ── Helper Functions ────────────────────────────────────────

# # # Print section header
# # section() {
# #   echo ""
# #   echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
# #   echo -e "${CYAN}║${WHITE}  $1${CYAN}"
# #   echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
# #   echo ""
# # }

# # # Print step
# # step() {
# #   echo -e "${YELLOW}▶  $1${NC}"
# # }

# # # Print success
# # success() {
# #   echo -e "${GREEN}✅ $1${NC}"
# # }

# # # Print error
# # error() {
# #   echo -e "${RED}❌ $1${NC}"
# # }

# # # Print info
# # info() {
# #   echo -e "${PURPLE}ℹ  $1${NC}"
# # }

# # # ── PROGRESS BAR FUNCTION ───────────────────────────────────
# # # Yeh function Ollama Pod ke logs monitor karta hai
# # # Download progress real-time dikhata hai
# # show_ollama_progress() {
# #   local POD_NAME=$1
# #   local MODEL=$2
# #   local NAMESPACE="ollama-agent"

# #   echo ""
# #   echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
# #   echo -e "${WHITE}  📦 Downloading Model: ${YELLOW}${MODEL}${NC}"
# #   echo -e "${WHITE}  📍 Pod: ${PURPLE}${POD_NAME}${NC}"
# #   echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
# #   echo ""

# #   # Variables for progress tracking
# #   local PREV_PERCENT=0
# #   local SPIN=0
# #   local SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
# #   local START_TIME=$(date +%s)

# #   # Ollama pull command background mein chalao
# #   kubectl exec -n "$NAMESPACE" "$POD_NAME" -- \
# #     ollama pull "$MODEL" 2>&1 | \
# #   while IFS= read -r LINE; do

# #     CURRENT_TIME=$(date +%s)
# #     ELAPSED=$((CURRENT_TIME - START_TIME))
# #     MINS=$((ELAPSED / 60))
# #     SECS=$((ELAPSED % 60))
# #     SPIN=$(( (SPIN + 1) % 10 ))

# #     # ── Parse different Ollama output lines ─────────────────

# #     # "pulling manifest" line
# #     if echo "$LINE" | grep -q "pulling manifest"; then
# #       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Fetching model manifest...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}    "

# #     # "pulling <sha>" with percentage — main download line
# #     elif echo "$LINE" | grep -qE "[0-9]+%"; then
# #       PERCENT=$(echo "$LINE" | grep -oE "[0-9]+%" | tail -1 | tr -d '%')
# #       DOWNLOADED=$(echo "$LINE" | grep -oE "[0-9]+\.[0-9]+ [MGK]B" | head -1)
# #       TOTAL=$(echo "$LINE" | grep -oE "[0-9]+\.[0-9]+ [MGK]B" | tail -1)
# #       SPEED=$(echo "$LINE" | grep -oE "[0-9]+\.[0-9]+ [MGK]B/s" | head -1)

# #       if [ ! -z "$PERCENT" ]; then
# #         # Progress bar draw karo
# #         BAR_WIDTH=35
# #         FILLED=$(( PERCENT * BAR_WIDTH / 100 ))
# #         EMPTY=$(( BAR_WIDTH - FILLED ))

# #         # Bar string banao
# #         BAR=""
# #         for i in $(seq 1 $FILLED); do BAR="${BAR}█"; done
# #         for i in $(seq 1 $EMPTY);  do BAR="${BAR}░"; done

# #         # Color based on progress
# #         if [ "$PERCENT" -lt 30 ]; then
# #           COLOR=$RED
# #         elif [ "$PERCENT" -lt 70 ]; then
# #           COLOR=$YELLOW
# #         else
# #           COLOR=$GREEN
# #         fi

# #         # Progress line print karo (same line pe overwrite)
# #         printf "\r  ${COLOR}[${BAR}]${NC} ${WHITE}${PERCENT}%%${NC}  ${CYAN}${DOWNLOADED:-?}/${TOTAL:-?}${NC}  ${PURPLE}${SPEED:-calculating...}${NC}  ${YELLOW}[${MINS}m ${SECS}s]${NC}   "

# #         # New max percent save karo
# #         PREV_PERCENT=$PERCENT
# #       fi

# #     # "verifying sha256" line
# #     elif echo "$LINE" | grep -q "verifying sha256"; then
# #       echo ""
# #       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Verifying download integrity (SHA256)...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "

# #     # "writing manifest" line  
# #     elif echo "$LINE" | grep -q "writing manifest"; then
# #       echo ""
# #       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Writing model manifest...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "

# #     # "removing any unused layers" line
# #     elif echo "$LINE" | grep -q "removing any unused"; then
# #       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Cleaning up unused layers...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "

# #     # "success" line - download complete
# #     elif echo "$LINE" | grep -q "success"; then
# #       echo ""
# #       echo ""
# #       BAR=""
# #       for i in $(seq 1 35); do BAR="${BAR}█"; done
# #       echo -e "  ${GREEN}[${BAR}]${NC} ${WHITE}100%%${NC}"
# #       echo ""
# #       echo -e "  ${GREEN}✅ Model ${YELLOW}${MODEL}${GREEN} successfully downloaded!${NC}"
# #       echo -e "  ${WHITE}⏱  Total time: ${YELLOW}${MINS}m ${SECS}s${NC}"
# #       echo ""

# #     # Koi aur line - spinner dikhao
# #     else
# #       if [ ! -z "$LINE" ]; then
# #         printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}${LINE}${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "
# #       fi
# #     fi

# #   done

# #   echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
# # }

# # # ── Wait with spinner ───────────────────────────────────────
# # wait_with_spinner() {
# #   local MSG=$1
# #   local SECONDS_TO_WAIT=$2
# #   local SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
# #   local i=0

# #   for s in $(seq 1 $SECONDS_TO_WAIT); do
# #     printf "\r  ${CYAN}${SPINNER[$i]}${NC}  ${WHITE}${MSG} (${s}/${SECONDS_TO_WAIT}s)${NC}   "
# #     i=$(( (i + 1) % 10 ))
# #     sleep 1
# #   done
# #   echo ""
# # }

# # # ── Pod ready wait ──────────────────────────────────────────
# # wait_for_pod() {
# #   local LABEL=$1
# #   local NAMESPACE="ollama-agent"
# #   local SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
# #   local i=0
# #   local ELAPSED=0

# #   printf "  "
# #   while true; do
# #     READY=$(kubectl get pods -n "$NAMESPACE" -l "$LABEL" \
# #       --field-selector=status.phase=Running \
# #       -o jsonpath='{.items[*].status.containerStatuses[*].ready}' 2>/dev/null | tr ' ' '\n' | grep -c "true" || echo "0")

# #     TOTAL=$(kubectl get pods -n "$NAMESPACE" -l "$LABEL" \
# #       --no-headers 2>/dev/null | wc -l | tr -d ' ')

# #     if [ "$READY" -gt "0" ] && [ "$READY" = "$TOTAL" ] 2>/dev/null; then
# #       echo ""
# #       return 0
# #     fi

# #     printf "\r  ${CYAN}${SPINNER[$i]}${NC}  ${WHITE}Waiting for pod... ${YELLOW}[${READY}/${TOTAL} ready]${NC}  ${PURPLE}[${ELAPSED}s elapsed]${NC}   "
# #     i=$(( (i + 1) % 10 ))
# #     ELAPSED=$((ELAPSED + 2))
# #     sleep 2

# #     if [ "$ELAPSED" -gt "300" ]; then
# #       echo ""
# #       error "Pod did not become ready in 5 minutes!"
# #       info "Check pod status: kubectl get pods -n ollama-agent"
# #       info "Check pod logs:   kubectl logs -n ollama-agent -l $LABEL"
# #       exit 1
# #     fi
# #   done
# # }

# # # ════════════════════════════════════════════════════════════
# # # MAIN DEPLOYMENT
# # # ════════════════════════════════════════════════════════════

# # section "🚀 Ollama Agent — Full Kubernetes Deployment"
# # info "Script directory: $SCRIPT_DIR"
# # echo ""

# # # ── Step 0: KIND Cluster ─────────────────────────────────────
# # section "Step 0/9 → Creating KIND Cluster"
# # step "Creating KIND cluster: ollama-agent"
# # kind create cluster --name ollama-agent --config kind-cluster-create/kind-config.yml || true

# # step "Verifying cluster..."
# # kubectl cluster-info --context kind-ollama-agent
# # kubectl get nodes
# # success "Cluster ready!"
# # wait_with_spinner "Cluster stabilizing" 3

# # # ── Step 1: Ingress Controller ───────────────────────────────
# # section "Step 1/9 → Installing NGINX Ingress Controller"
# # step "Applying Ingress Controller manifest..."

# # kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# # step "Waiting for Ingress Controller to be ready..."
# # kubectl wait --namespace ingress-nginx \
# #   --for=condition=ready pod \
# #   --selector=app.kubernetes.io/component=controller \
# #   --timeout=120s

# # kubectl get pods -n ingress-nginx
# # success "Ingress Controller ready!"
# # wait_with_spinner "Ingress stabilizing" 3

# # # ── Step 2: Namespace + Storage ──────────────────────────────
# # section "Step 2/9 → Namespace & Storage"
# # step "Creating ollama-agent namespace..."
# # kubectl apply -f cluster/namespace.yaml

# # step "Creating StorageClass..."
# # kubectl apply -f cluster/storageclass.yaml

# # success "Namespace and storage created!"
# # wait_with_spinner "Waiting" 2

# # # ── Step 3: Ollama Deployment ────────────────────────────────
# # section "Step 3/9 → Deploying Ollama AI Engine"
# # step "Creating Ollama PVC (30GB model storage)..."
# # kubectl apply -f ollama/pvc.yaml

# # step "Applying Ollama ConfigMap..."
# # kubectl apply -f ollama/configmap.yaml

# # step "Deploying Ollama Pod..."
# # kubectl apply -f ollama/deployment.yaml
# # kubectl apply -f ollama/service.yaml

# # step "Waiting for Ollama Pod to start..."
# # wait_for_pod "app=ollama"
# # success "Ollama Pod is running!"

# # # ── Ollama Model Download with Progress Bar ──────────────────
# # echo ""
# # info "Getting Ollama Pod name..."
# # OLLAMA_POD=$(kubectl get pods -n ollama-agent -l app=ollama \
# #   -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)

# # if [ -z "$OLLAMA_POD" ]; then
# #   error "Could not find Ollama pod!"
# #   exit 1
# # fi

# # info "Pod found: $OLLAMA_POD"
# # echo ""

# # # Check if model already downloaded
# # MODEL_EXISTS=$(kubectl exec -n ollama-agent "$OLLAMA_POD" -- \
# #   ollama list 2>/dev/null | grep -c "llama2" || echo "0")

# # if [ "$MODEL_EXISTS" -gt "0" ]; then
# #   success "llama2 model already exists — skipping download!"
# # else
# #   step "Starting llama2 model download (~3.8GB)..."
# #   info "This may take 5-15 minutes depending on your internet speed"
# #   echo ""

# #   # Progress bar ke saath model download karo
# #   show_ollama_progress "$OLLAMA_POD" "llama2"
# # fi

# # # Verify model
# # step "Verifying installed models..."
# # kubectl exec -n ollama-agent "$OLLAMA_POD" -- ollama list
# # success "Ollama ready with models!"
# # wait_with_spinner "Ollama stabilizing" 5

# # # ── Step 4: Secret ───────────────────────────────────────────
# # section "Step 4/9 → Applying Backend Secret"
# # step "Creating JWT + MongoDB secret..."
# # kubectl apply -f backend/secret.yaml
# # success "Secret created!"
# # sleep 1

# # # ── Step 5: MongoDB ──────────────────────────────────────────
# # section "Step 5/9 → Deploying MongoDB"
# # step "Applying MongoDB ConfigMap..."
# # kubectl apply -f mongodb/configmap.yaml

# # step "Creating MongoDB Service..."
# # kubectl apply -f mongodb/service.yaml

# # step "Deploying MongoDB StatefulSet..."
# # kubectl apply -f mongodb/statefulset.yaml

# # step "Waiting for MongoDB to be ready..."
# # wait_for_pod "app=ollama-mongodb"
# # success "MongoDB ready!"

# # step "Verifying MongoDB collections..."
# # MONGO_POD=$(kubectl get pods -n ollama-agent -l app=ollama-mongodb \
# #   -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)

# # if [ ! -z "$MONGO_POD" ]; then
# #   kubectl exec -n ollama-agent "$MONGO_POD" -- \
# #     mongosh --quiet --eval "db.getSiblingDB('ollama-agent').getCollectionNames()" \
# #     2>/dev/null || true
# # fi
# # wait_with_spinner "MongoDB stabilizing" 5

# # # ── Step 6: Backend ──────────────────────────────────────────
# # section "Step 6/9 → Deploying Backend (Node.js)"
# # step "Applying Backend ConfigMap..."
# # kubectl apply -f backend/configmap.yaml

# # step "Deploying Backend Pods..."
# # kubectl apply -f backend/deployment.yaml
# # kubectl apply -f backend/service.yaml
# # kubectl apply -f backend/hpa.yaml

# # step "Waiting for Backend to be ready..."
# # wait_for_pod "app=ollama-backend"
# # success "Backend ready!"
# # wait_with_spinner "Backend stabilizing" 3

# # # ── Step 7: Frontend ─────────────────────────────────────────
# # section "Step 7/9 → Deploying Frontend (React + Nginx)"
# # step "Applying Frontend ConfigMap..."
# # kubectl apply -f frontend/configmap.yaml

# # step "Deploying Frontend Pods..."
# # kubectl apply -f frontend/deployment.yaml
# # kubectl apply -f frontend/service.yaml
# # kubectl apply -f frontend/hpa.yaml

# # step "Waiting for Frontend to be ready..."
# # wait_for_pod "app=ollama-frontend"
# # success "Frontend ready!"

# # # ── Step 8: Ingress Rules ────────────────────────────────────
# # section "Step 8/9 → Applying Ingress Routing"
# # step "Setting up traffic routing..."
# # kubectl apply -f cluster/ingress.yaml
# # success "Ingress configured!"

# # # ── Step 9: Final Status ─────────────────────────────────────
# # section "Step 9/9 → Final Status Check"

# # echo -e "${WHITE}All Pods:${NC}"
# # kubectl get pods -n ollama-agent
# # echo ""

# # echo -e "${WHITE}All Services:${NC}"
# # kubectl get services -n ollama-agent
# # echo ""

# # echo -e "${WHITE}HPA Status:${NC}"
# # kubectl get hpa -n ollama-agent 2>/dev/null || true
# # echo ""

# # echo -e "${WHITE}Ingress:${NC}"
# # kubectl get ingress -n ollama-agent 2>/dev/null || true

# # # ── Done ─────────────────────────────────────────────────────
# # echo ""
# # echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
# # echo -e "${GREEN}║   ✅  FULL DEPLOYMENT COMPLETE! 🚀               ║${NC}"
# # echo -e "${GREEN}╠═══════════════════════════════════════════════════╣${NC}"
# # echo -e "${GREEN}║                                                   ║${NC}"
# # echo -e "${GREEN}║   🌐 App URL:    ${WHITE}http://localhost${GREEN}              ║${NC}"
# # echo -e "${GREEN}║   🔊 Voice URL:  ${WHITE}https://localhost${GREEN}             ║${NC}"
# # echo -e "${GREEN}║                                                   ║${NC}"
# # echo -e "${GREEN}║   📡 Port Forward Commands:                       ║${NC}"
# # echo -e "${GREEN}║   ${CYAN}kubectl port-forward -n ingress-nginx \\${GREEN}       ║${NC}"
# # echo -e "${GREEN}║   ${CYAN}  service/ingress-nginx-controller 8080:80${GREEN}    ║${NC}"
# # echo -e "${GREEN}║                                                   ║${NC}"
# # echo -e "${GREEN}║   🤖 Created by ${YELLOW}@techwithburhan${GREEN}                ║${NC}"
# # echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
# # echo ""

# #!/bin/bash
# # ============================================================
# # OLLAMA AGENT — Full Kubernetes Deployment Script
# # With Real Progress Bar for Ollama Model Download
# # Fixed: Ingress Controller local file se install hoga
# # Usage: chmod +x apply-all.sh && ./apply-all.sh
# # ============================================================

# set -e

# # ── Colors ──────────────────────────────────────────────────
# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
# CYAN='\033[0;36m'
# PURPLE='\033[0;35m'
# WHITE='\033[1;37m'
# NC='\033[0m'

# SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# cd "$SCRIPT_DIR"

# # ── Helper Functions ────────────────────────────────────────
# section() {
#   echo ""
#   echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
#   echo -e "${CYAN}║${WHITE}  $1${NC}"
#   echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
#   echo ""
# }
# step()    { echo -e "${YELLOW}▶  $1${NC}"; }
# success() { echo -e "${GREEN}✅ $1${NC}"; }
# error()   { echo -e "${RED}❌ $1${NC}"; }
# info()    { echo -e "${PURPLE}ℹ  $1${NC}"; }

# # ── Wait with Spinner ───────────────────────────────────────
# wait_with_spinner() {
#   local MSG=$1
#   local SECONDS_TO_WAIT=$2
#   local SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
#   local i=0
#   for s in $(seq 1 $SECONDS_TO_WAIT); do
#     printf "\r  ${CYAN}${SPINNER[$i]}${NC}  ${WHITE}${MSG} (${s}/${SECONDS_TO_WAIT}s)${NC}   "
#     i=$(( (i + 1) % 10 ))
#     sleep 1
#   done
#   echo ""
# }

# # ── Pod Ready Wait ──────────────────────────────────────────
# wait_for_pod() {
#   local LABEL=$1
#   local NAMESPACE="ollama-agent"
#   local SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
#   local i=0
#   local ELAPSED=0
#   printf "  "
#   while true; do
#     READY=$(kubectl get pods -n "$NAMESPACE" -l "$LABEL" \
#       -o jsonpath='{.items[*].status.containerStatuses[*].ready}' 2>/dev/null \
#       | tr ' ' '\n' | grep -c "true" || echo "0")
#     TOTAL=$(kubectl get pods -n "$NAMESPACE" -l "$LABEL" \
#       --no-headers 2>/dev/null | wc -l | tr -d ' ')
#     if [ "$READY" -gt "0" ] && [ "$READY" = "$TOTAL" ] 2>/dev/null; then
#       echo ""
#       return 0
#     fi
#     printf "\r  ${CYAN}${SPINNER[$i]}${NC}  ${WHITE}Waiting... ${YELLOW}[${READY}/${TOTAL} ready]${NC}  ${PURPLE}[${ELAPSED}s]${NC}   "
#     i=$(( (i + 1) % 10 ))
#     ELAPSED=$((ELAPSED + 2))
#     sleep 2
#     if [ "$ELAPSED" -gt "300" ]; then
#       echo ""
#       error "Pod not ready in 5 minutes!"
#       info "kubectl get pods -n ollama-agent"
#       info "kubectl describe pod -n ollama-agent -l $LABEL"
#       exit 1
#     fi
#   done
# }

# # ── Ingress Install Function ────────────────────────────────
# # GitHub rate limit fix:
# # Method 1 → Helm se install (best)
# # Method 2 → kubectl apply with retry
# # Method 3 → Local file se install
# install_ingress() {
#   echo ""
#   info "Ingress install karne ki koshish kar raha hoon..."
#   echo ""

#   # ── Method 1: Helm (sabse reliable) ──────────────────────
#   if command -v helm &>/dev/null; then
#     step "Method 1: Helm se install kar raha hoon..."
#     helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
#     helm repo update
#     helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
#       --namespace ingress-nginx \
#       --create-namespace \
#       --set controller.service.type=NodePort \
#       --set controller.hostPort.enabled=true \
#       --set controller.hostPort.ports.http=80 \
#       --set controller.hostPort.ports.https=443 \
#       --wait --timeout=120s
#     success "Ingress installed via Helm!"
#     return 0
#   fi

#   # ── Method 2: kubectl apply with retry ───────────────────
#   step "Method 2: kubectl apply with retry (rate limit wait)..."
#   info "GitHub rate limit aaya tha - 60 second wait karke retry karunga"

#   local URLS=(
#     "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
#     "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/kind/deploy.yaml"
#     "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/kind/deploy.yaml"
#   )

#   for URL in "${URLS[@]}"; do
#     info "Trying: $URL"
#     # 60 second wait for rate limit reset
#     for attempt in 1 2 3; do
#       HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null || echo "000")
#       if [ "$HTTP_STATUS" = "200" ]; then
#         kubectl apply -f "$URL"
#         success "Ingress installed from URL!"
#         return 0
#       elif [ "$HTTP_STATUS" = "429" ]; then
#         info "Rate limited (429) - attempt $attempt/3 - waiting 60 seconds..."
#         wait_with_spinner "Rate limit wait" 60
#       else
#         info "HTTP $HTTP_STATUS - trying next URL..."
#         break
#       fi
#     done
#   done

#   # ── Method 3: Local file se (fallback) ───────────────────
#   step "Method 3: Local ingress file se install kar raha hoon..."

#   # Local ingress YAML file create karo
#   cat > /tmp/ingress-nginx-kind.yaml << 'INGRESS_EOF'
# apiVersion: v1
# kind: Namespace
# metadata:
#   name: ingress-nginx
#   labels:
#     app.kubernetes.io/name: ingress-nginx
# ---
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: ingress-nginx-controller
#   namespace: ingress-nginx
#   labels:
#     app.kubernetes.io/name: ingress-nginx
#     app.kubernetes.io/component: controller
# spec:
#   selector:
#     matchLabels:
#       app.kubernetes.io/name: ingress-nginx
#       app.kubernetes.io/component: controller
#   template:
#     metadata:
#       labels:
#         app.kubernetes.io/name: ingress-nginx
#         app.kubernetes.io/component: controller
#     spec:
#       hostNetwork: true
#       containers:
#         - name: controller
#           image: registry.k8s.io/ingress-nginx/controller:v1.9.4
#           args:
#             - /nginx-ingress-controller
#             - --publish-service=$(POD_NAMESPACE)/ingress-nginx-controller
#             - --election-id=ingress-nginx-leader
#             - --controller-class=k8s.io/ingress-nginx
#             - --ingress-class=nginx
#           env:
#             - name: POD_NAME
#               valueFrom:
#                 fieldRef:
#                   fieldPath: metadata.name
#             - name: POD_NAMESPACE
#               valueFrom:
#                 fieldRef:
#                   fieldPath: metadata.namespace
#           ports:
#             - name: http
#               containerPort: 80
#               hostPort: 80
#             - name: https
#               containerPort: 443
#               hostPort: 443
#           resources:
#             requests:
#               cpu: 100m
#               memory: 90Mi
#             limits:
#               cpu: 500m
#               memory: 300Mi
# ---
# apiVersion: v1
# kind: Service
# metadata:
#   name: ingress-nginx-controller
#   namespace: ingress-nginx
# spec:
#   type: NodePort
#   selector:
#     app.kubernetes.io/name: ingress-nginx
#     app.kubernetes.io/component: controller
#   ports:
#     - name: http
#       port: 80
#       targetPort: 80
#       nodePort: 30080
#     - name: https
#       port: 443
#       targetPort: 443
#       nodePort: 30443
# ---
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: ingress-nginx
#   namespace: ingress-nginx
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRole
# metadata:
#   name: ingress-nginx
# rules:
#   - apiGroups: [""]
#     resources: ["configmaps","endpoints","nodes","pods","secrets","namespaces"]
#     verbs: ["list","watch","get"]
#   - apiGroups: ["coordination.k8s.io"]
#     resources: ["leases"]
#     verbs: ["list","watch","get","update","create"]
#   - apiGroups: [""]
#     resources: ["events"]
#     verbs: ["create","patch"]
#   - apiGroups: ["networking.k8s.io"]
#     resources: ["ingresses","ingressclasses"]
#     verbs: ["get","list","watch"]
#   - apiGroups: ["networking.k8s.io"]
#     resources: ["ingresses/status"]
#     verbs: ["update"]
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
#   name: ingress-nginx
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: ingress-nginx
# subjects:
#   - kind: ServiceAccount
#     name: ingress-nginx
#     namespace: ingress-nginx
# INGRESS_EOF

#   kubectl apply -f /tmp/ingress-nginx-kind.yaml
#   success "Ingress installed from local embedded config!"
#   return 0
# }

# # ── Progress Bar for Ollama ─────────────────────────────────
# show_ollama_progress() {
#   local POD_NAME=$1
#   local MODEL=$2
#   local NAMESPACE="ollama-agent"

#   echo ""
#   echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
#   echo -e "${WHITE}  📦 Downloading: ${YELLOW}${MODEL}${NC}"
#   echo -e "${WHITE}  📍 Pod: ${PURPLE}${POD_NAME}${NC}"
#   echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
#   echo ""

#   local SPIN=0
#   local SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
#   local START_TIME=$(date +%s)

#   kubectl exec -n "$NAMESPACE" "$POD_NAME" -- \
#     ollama pull "$MODEL" 2>&1 | \
#   while IFS= read -r LINE; do
#     CURRENT_TIME=$(date +%s)
#     ELAPSED=$((CURRENT_TIME - START_TIME))
#     MINS=$((ELAPSED / 60))
#     SECS=$((ELAPSED % 60))
#     SPIN=$(( (SPIN + 1) % 10 ))

#     if echo "$LINE" | grep -q "pulling manifest"; then
#       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Fetching manifest...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}    "

#     elif echo "$LINE" | grep -qE "[0-9]+%"; then
#       PERCENT=$(echo "$LINE" | grep -oE "[0-9]+%" | tail -1 | tr -d '%')
#       DOWNLOADED=$(echo "$LINE" | grep -oE "[0-9]+\.[0-9]+ [MGK]B" | head -1)
#       TOTAL=$(echo "$LINE" | grep -oE "[0-9]+\.[0-9]+ [MGK]B" | tail -1)
#       SPEED=$(echo "$LINE" | grep -oE "[0-9]+\.[0-9]+ [MGK]B/s" | head -1)

#       if [ ! -z "$PERCENT" ]; then
#         BAR_WIDTH=35
#         FILLED=$(( PERCENT * BAR_WIDTH / 100 ))
#         EMPTY=$(( BAR_WIDTH - FILLED ))
#         BAR=""
#         for i in $(seq 1 $FILLED); do BAR="${BAR}█"; done
#         for i in $(seq 1 $EMPTY);  do BAR="${BAR}░"; done

#         if   [ "$PERCENT" -lt 30 ]; then COLOR=$RED
#         elif [ "$PERCENT" -lt 70 ]; then COLOR=$YELLOW
#         else COLOR=$GREEN
#         fi

#         printf "\r  ${COLOR}[${BAR}]${NC} ${WHITE}${PERCENT}%%${NC}  ${CYAN}${DOWNLOADED:-?}/${TOTAL:-?}${NC}  ${PURPLE}${SPEED:-...}${NC}  ${YELLOW}[${MINS}m ${SECS}s]${NC}   "
#       fi

#     elif echo "$LINE" | grep -q "verifying sha256"; then
#       echo ""
#       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Verifying SHA256...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "

#     elif echo "$LINE" | grep -q "writing manifest"; then
#       echo ""
#       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Writing manifest...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "

#     elif echo "$LINE" | grep -q "removing any unused"; then
#       printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}Cleaning up...${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "

#     elif echo "$LINE" | grep -q "success"; then
#       echo ""
#       echo ""
#       BAR=""
#       for i in $(seq 1 35); do BAR="${BAR}█"; done
#       echo -e "  ${GREEN}[${BAR}] 100%%${NC}"
#       echo ""
#       echo -e "  ${GREEN}✅ ${YELLOW}${MODEL}${GREEN} download complete!${NC}"
#       echo -e "  ${WHITE}⏱  Total: ${YELLOW}${MINS}m ${SECS}s${NC}"
#       echo ""
#     else
#       if [ ! -z "$LINE" ]; then
#         printf "\r  ${CYAN}${SPINNER[$SPIN]}${NC}  ${WHITE}${LINE:0:60}${NC}  ${PURPLE}[${MINS}m ${SECS}s]${NC}   "
#       fi
#     fi
#   done

#   echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
# }

# # ════════════════════════════════════════════════════════════
# # MAIN DEPLOYMENT
# # ════════════════════════════════════════════════════════════

# section "🚀 Ollama Agent — Full Kubernetes Deployment"
# info "Script dir: $SCRIPT_DIR"

# # ── Step 0: KIND Cluster ─────────────────────────────────────
# section "Step 0/9 → Creating KIND Cluster"
# step "Creating KIND cluster..."
# kind create cluster --name ollama-agent \
#   --config kind-cluster-create/kind-config.yml || true

# step "Verifying cluster..."
# kubectl cluster-info --context kind-ollama-agent
# kubectl get nodes
# success "Cluster ready!"
# wait_with_spinner "Stabilizing" 3

# # ── Step 1: Ingress Controller ───────────────────────────────
# section "Step 1/9 → Installing NGINX Ingress Controller"
# install_ingress

# step "Waiting for Ingress Controller pod..."
# kubectl wait --namespace ingress-nginx \
#   --for=condition=ready pod \
#   --selector=app.kubernetes.io/component=controller \
#   --timeout=120s || \
# kubectl wait --namespace ingress-nginx \
#   --for=condition=ready pod \
#   --selector=app.kubernetes.io/name=ingress-nginx \
#   --timeout=120s || true

# kubectl get pods -n ingress-nginx
# success "Ingress ready!"
# wait_with_spinner "Stabilizing" 3

# # ── Step 2: Namespace + Storage ──────────────────────────────
# section "Step 2/9 → Namespace & Storage"
# step "Creating namespace..."
# kubectl apply -f cluster/namespace.yaml
# kubectl apply -f cluster/storageclass.yaml
# success "Done!"
# wait_with_spinner "Waiting" 2

# # ── Step 3: Ollama ───────────────────────────────────────────
# section "Step 3/9 → Deploying Ollama AI Engine"
# step "Creating Ollama PVC..."
# kubectl apply -f ollama/pvc.yaml
# step "Applying Ollama config..."
# kubectl apply -f ollama/configmap.yaml
# step "Deploying Ollama..."
# kubectl apply -f ollama/deployment.yaml
# kubectl apply -f ollama/service.yaml

# step "Waiting for Ollama Pod..."
# wait_for_pod "app=ollama"
# success "Ollama Pod running!"

# info "Getting Ollama pod name..."
# OLLAMA_POD=$(kubectl get pods -n ollama-agent -l app=ollama \
#   -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)

# if [ -z "$OLLAMA_POD" ]; then
#   error "Ollama pod not found!"
#   exit 1
# fi

# info "Pod: $OLLAMA_POD"

# # Model already exists check
# MODEL_EXISTS=$(kubectl exec -n ollama-agent "$OLLAMA_POD" -- \
#   ollama list 2>/dev/null | grep -c "llama2" || echo "0")

# if [ "$MODEL_EXISTS" -gt "0" ]; then
#   success "llama2 already installed — skipping!"
# else
#   step "Downloading llama2 (~3.8GB)..."
#   info "This takes 5-15 min depending on internet speed"
#   show_ollama_progress "$OLLAMA_POD" "llama2"
# fi

# step "Installed models:"
# kubectl exec -n ollama-agent "$OLLAMA_POD" -- ollama list
# success "Ollama ready!"
# wait_with_spinner "Stabilizing" 5

# # ── Step 4: Secret ───────────────────────────────────────────
# section "Step 4/9 → Backend Secret"
# step "Applying secret..."
# kubectl apply -f backend/secret.yaml
# success "Secret created!"
# sleep 1

# # ── Step 5: MongoDB ──────────────────────────────────────────
# section "Step 5/9 → Deploying MongoDB"
# step "Applying MongoDB resources..."
# kubectl apply -f mongodb/configmap.yaml
# kubectl apply -f mongodb/service.yaml
# kubectl apply -f mongodb/statefulset.yaml

# step "Waiting for MongoDB..."
# wait_for_pod "app=ollama-mongodb"
# success "MongoDB ready!"
# wait_with_spinner "Stabilizing" 5

# # ── Step 6: Backend ──────────────────────────────────────────
# section "Step 6/9 → Deploying Backend"
# step "Applying Backend resources..."
# kubectl apply -f backend/configmap.yaml
# kubectl apply -f backend/deployment.yaml
# kubectl apply -f backend/service.yaml
# kubectl apply -f backend/hpa.yaml

# step "Waiting for Backend..."
# wait_for_pod "app=ollama-backend"
# success "Backend ready!"
# wait_with_spinner "Stabilizing" 3

# # ── Step 7: Frontend ─────────────────────────────────────────
# section "Step 7/9 → Deploying Frontend"
# step "Applying Frontend resources..."
# kubectl apply -f frontend/configmap.yaml
# kubectl apply -f frontend/deployment.yaml
# kubectl apply -f frontend/service.yaml
# kubectl apply -f frontend/hpa.yaml

# step "Waiting for Frontend..."
# wait_for_pod "app=ollama-frontend"
# success "Frontend ready!"

# # ── Step 8: Ingress Rules ────────────────────────────────────
# section "Step 8/9 → Ingress Routing"
# step "Applying ingress rules..."
# kubectl apply -f cluster/ingress.yaml
# success "Ingress configured!"

# # ── Step 9: Final Status ─────────────────────────────────────
# section "Step 9/9 → Final Status"
# echo -e "${WHITE}All Pods:${NC}"
# kubectl get pods -n ollama-agent
# echo ""
# echo -e "${WHITE}All Services:${NC}"
# kubectl get services -n ollama-agent
# echo ""
# echo -e "${WHITE}HPA:${NC}"
# kubectl get hpa -n ollama-agent 2>/dev/null || true

# # ── Done ─────────────────────────────────────────────────────
# echo ""
# echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
# echo -e "${GREEN}║   ✅  DEPLOYMENT COMPLETE! 🚀                    ║${NC}"
# echo -e "${GREEN}╠═══════════════════════════════════════════════════╣${NC}"
# echo -e "${GREEN}║                                                   ║${NC}"
# echo -e "${GREEN}║   🌐 Open:  ${WHITE}http://localhost:8080${GREEN}              ║${NC}"
# echo -e "${GREEN}║                                                   ║${NC}"
# echo -e "${GREEN}║   📡 Port Forward:                                ║${NC}"
# echo -e "${GREEN}║   ${CYAN}kubectl port-forward -n ingress-nginx \\${GREEN}       ║${NC}"
# echo -e "${GREEN}║   ${CYAN}  svc/ingress-nginx-controller 8080:80${GREEN}        ║${NC}"
# echo -e "${GREEN}║                                                   ║${NC}"
# echo -e "${GREEN}║   🤖 Created by ${YELLOW}@techwithburhan${GREEN}                ║${NC}"
# echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
# echo ""