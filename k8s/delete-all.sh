#!/bin/bash
# ════════════════════════════════════════════════════════════════════
# Ollama Agent — Delete Everything from Kubernetes
#
# Usage:
#   chmod +x delete-all.sh
#   ./delete-all.sh            → Delete app but KEEP MongoDB data (safe)
#   ./delete-all.sh --full     → Delete everything INCLUDING data (careful!)
# ════════════════════════════════════════════════════════════════════

FULL_DELETE=false

# Check if --full flag was passed
if [ "$1" == "--full" ]; then
  FULL_DELETE=true
fi

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║   🗑️  Removing Ollama Agent from K8s     ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Warn user if they are about to delete data
if [ "$FULL_DELETE" = true ]; then
  echo "⚠️  WARNING: --full will DELETE all MongoDB data permanently!"
  read -p "    Type DELETE to confirm: " CONFIRM
  if [ "$CONFIRM" != "DELETE" ]; then
    echo "Cancelled. Nothing was deleted."
    exit 1
  fi
fi

# ── Step 1: Remove Ingress ────────────────────────────────────────────
echo "Step 1/5 → Removing Ingress..."
kubectl delete -f cluster/ingress.yaml --ignore-not-found=true
echo "✅ Done"

# ── Step 2: Remove Frontend ───────────────────────────────────────────
echo ""
echo "Step 2/5 → Removing Frontend..."
kubectl delete -f frontend/hpa.yaml        --ignore-not-found=true
kubectl delete -f frontend/service.yaml    --ignore-not-found=true
kubectl delete -f frontend/deployment.yaml --ignore-not-found=true
kubectl delete -f frontend/configmap.yaml  --ignore-not-found=true
echo "✅ Done"

# ── Step 3: Remove Backend ────────────────────────────────────────────
echo ""
echo "Step 3/5 → Removing Backend..."
kubectl delete -f backend/hpa.yaml         --ignore-not-found=true
kubectl delete -f backend/service.yaml     --ignore-not-found=true
kubectl delete -f backend/deployment.yaml  --ignore-not-found=true
kubectl delete -f backend/configmap.yaml   --ignore-not-found=true
kubectl delete -f backend/secret.yaml      --ignore-not-found=true
echo "✅ Done"

# ── Step 4: Remove MongoDB ────────────────────────────────────────────
echo ""
echo "Step 4/5 → Removing MongoDB..."
kubectl delete -f mongodb/statefulset.yaml --ignore-not-found=true

echo "Waiting for MongoDB pod to stop..."
kubectl wait --for=delete pod/ollama-mongodb-0 -n ollama-agent --timeout=60s 2>/dev/null || true

kubectl delete -f mongodb/service.yaml    --ignore-not-found=true
kubectl delete -f mongodb/configmap.yaml  --ignore-not-found=true

# Only delete data if --full was passed
if [ "$FULL_DELETE" = true ]; then
  echo "Deleting MongoDB data (PVCs)..."
  kubectl delete -f mongodb/persistentvolumeclaim.yaml --ignore-not-found=true
  kubectl delete pvc -l app=ollama-mongodb -n ollama-agent --ignore-not-found=true
  echo "MongoDB data deleted"
else
  echo "MongoDB data (PVC) kept — your chat history is safe"
  echo "Run with --full to also delete data"
fi
echo "✅ Done"

# ── Step 5: Remove Namespace ──────────────────────────────────────────
echo ""
echo "Step 5/5 → Removing namespace and storage..."
kubectl delete -f cluster/storageclass.yaml --ignore-not-found=true
kubectl delete -f cluster/namespace.yaml    --ignore-not-found=true
echo "✅ Done"

# ── Done ──────────────────────────────────────────────────────────────
echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║   ✅ Removal complete                    ║"
echo "╚═══════════════════════════════════════════╝"