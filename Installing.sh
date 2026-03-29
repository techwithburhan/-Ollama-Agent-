#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════╗
# ║         Ollama Agent — DevOps Environment Setup                 ║
# ║         Docker + KIND + kubectl installer                       ║
# ║         by @techwithburhan                                      ║
# ╚══════════════════════════════════════════════════════════════════╝

set -e

# ── Colors ────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────
ok()   { echo -e "  ${GREEN}✅ $1${RESET}"; }
info() { echo -e "  ${CYAN}ℹ️  $1${RESET}"; }
warn() { echo -e "  ${YELLOW}⚠️  $1${RESET}"; }
fail() { echo -e "  ${RED}❌ $1${RESET}"; exit 1; }
step() { echo -e "\n${BOLD}${BLUE}┌─────────────────────────────────────────────────┐${RESET}"; \
         echo -e "${BOLD}${BLUE}│  $1${RESET}"; \
         echo -e "${BOLD}${BLUE}└─────────────────────────────────────────────────┘${RESET}"; }

# ── Banner ────────────────────────────────────────────────────────
clear
echo ""
echo -e "${BOLD}${MAGENTA}"
echo "  ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗"
echo "  ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝"
echo "  ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗"
echo "  ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║"
echo "  ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║"
echo "  ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝"
echo -e "${RESET}"
echo -e "${BOLD}${CYAN}  ╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}  ║   🚀  Environment Setup Script                    ║${RESET}"
echo -e "${BOLD}${CYAN}  ║   🐳  Docker  +  ☸️  KIND  +  🔧  kubectl          ║${RESET}"
echo -e "${BOLD}${CYAN}  ║   👨‍💻  by @techwithburhan                          ║${RESET}"
echo -e "${BOLD}${CYAN}  ╚════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── System check ──────────────────────────────────────────────────
step "🖥️  Step 1/6 — System Check"

OS=$(uname -s)
ARCH=$(uname -m)
info "OS   : $OS"
info "Arch : $ARCH"
info "User : $USER"

if [ "$OS" != "Linux" ]; then
  fail "This script is for Linux only. Use Docker Desktop for macOS/Windows."
fi
ok "Linux detected — continuing"

# ── System update ─────────────────────────────────────────────────
step "📦  Step 2/6 — System Update & Upgrade"

info "Updating package lists..."
sudo apt-get update -y > /dev/null 2>&1
ok "Package lists updated"

info "Upgrading installed packages (this may take a minute)..."
sudo apt-get upgrade -y > /dev/null 2>&1
ok "System upgraded"

# ── Docker ────────────────────────────────────────────────────────
step "🐳  Step 3/6 — Installing Docker"

if command -v docker &>/dev/null; then
  EXISTING_DOCKER=$(docker --version 2>/dev/null)
  warn "Docker already installed: $EXISTING_DOCKER"
  info "Skipping Docker installation"
else
  info "Installing docker.io..."
  sudo apt-get install -y docker.io > /dev/null 2>&1
  ok "Docker installed"

  info "Installing docker-compose-v2..."
  sudo apt-get install -y docker-compose-v2 > /dev/null 2>&1
  ok "Docker Compose v2 installed"
fi

info "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker > /dev/null 2>&1
ok "Docker service started and enabled"

info "Adding $USER to docker group..."
sudo usermod -aG docker "$USER"
ok "User '$USER' added to docker group"

echo ""
echo -e "  ${YELLOW}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "  ${YELLOW}║  ⚠️  Docker group change needs a new shell session  ║${RESET}"
echo -e "  ${YELLOW}║  Run: newgrp docker  (after this script completes) ║${RESET}"
echo -e "  ${YELLOW}╚════════════════════════════════════════════════════╝${RESET}"

# ── KIND ──────────────────────────────────────────────────────────
step "☸️   Step 4/6 — Installing KIND (Kubernetes IN Docker)"

KIND_VERSION="v0.20.0"

if command -v kind &>/dev/null; then
  EXISTING_KIND=$(kind --version 2>/dev/null)
  warn "KIND already installed: $EXISTING_KIND"
  info "Skipping KIND installation"
else
  if [ "$ARCH" = "x86_64" ]; then
    KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
  elif [ "$ARCH" = "aarch64" ]; then
    KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-arm64"
  else
    fail "Unsupported architecture: $ARCH"
  fi

  info "Downloading KIND ${KIND_VERSION} for ${ARCH}..."
  curl -Lo ./kind "$KIND_URL" --progress-bar
  chmod +x ./kind
  sudo cp ./kind /usr/local/bin/kind
  rm -f ./kind
  ok "KIND installed to /usr/local/bin/kind"
fi

# ── kubectl ───────────────────────────────────────────────────────
step "🔧  Step 5/6 — Installing kubectl"

KUBECTL_VERSION="v1.30.0"
INSTALL_DIR="/usr/local/bin"

if command -v kubectl &>/dev/null; then
  EXISTING_KUBECTL=$(kubectl version --client --short 2>/dev/null | head -1)
  warn "kubectl already installed: $EXISTING_KUBECTL"
  info "Skipping kubectl installation"
else
  info "Downloading kubectl ${KUBECTL_VERSION}..."
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" --progress-bar
  chmod +x kubectl
  sudo mv kubectl "$INSTALL_DIR/"
  ok "kubectl installed to ${INSTALL_DIR}/kubectl"
fi

# Make cluster setup script executable if it exists
if [ -f "kind_cluster.sh" ]; then
  sudo chmod 777 kind_cluster.sh
  ok "kind_cluster.sh made executable"
fi

# ── Verify everything ─────────────────────────────────────────────
step "✅  Step 6/6 — Verifying Installations"

echo ""
echo -e "  ${BOLD}${WHITE}Tool Versions:${RESET}"
echo -e "  ${BOLD}────────────────────────────────────────────${RESET}"

# Docker
if command -v docker &>/dev/null; then
  DOCKER_VER=$(docker --version)
  echo -e "  🐳  ${GREEN}${DOCKER_VER}${RESET}"
else
  echo -e "  🐳  ${RED}Docker — NOT FOUND${RESET}"
fi

# Docker Compose
if command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
  COMPOSE_VER=$(docker compose version)
  echo -e "  🐙  ${GREEN}${COMPOSE_VER}${RESET}"
else
  echo -e "  🐙  ${YELLOW}Docker Compose — not verified (may need newgrp docker)${RESET}"
fi

# KIND
if command -v kind &>/dev/null; then
  KIND_VER=$(kind --version)
  echo -e "  ☸️   ${GREEN}${KIND_VER}${RESET}"
else
  echo -e "  ☸️   ${RED}KIND — NOT FOUND${RESET}"
fi

# kubectl
if command -v kubectl &>/dev/null; then
  KUBECTL_VER=$(kubectl version --client 2>/dev/null | grep "Client Version" | awk '{print $3}')
  echo -e "  🔧  ${GREEN}kubectl version ${KUBECTL_VER}${RESET}"
else
  echo -e "  🔧  ${RED}kubectl — NOT FOUND${RESET}"
fi

echo -e "  ${BOLD}────────────────────────────────────────────${RESET}"

# ── Done ──────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}"
echo "  ╔════════════════════════════════════════════════════╗"
echo "  ║                                                    ║"
echo "  ║   🎉  All tools installed successfully!           ║"
echo "  ║                                                    ║"
echo "  ║   📋  Next Steps:                                 ║"
echo "  ║                                                    ║"
echo "  ║   1️⃣   Run:  newgrp docker                        ║"
echo "  ║         (activates docker group in current shell) ║"
echo "  ║                                                    ║"
echo "  ║   2️⃣   Run:  ./apply.sh                           ║"
echo "  ║         (creates KIND cluster + deploys app)      ║"
echo "  ║                                                    ║"
echo "  ║   🌐  App will be at: http://localhost:3000       ║"
echo "  ║                                                    ║"
echo "  ╚════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo ""
echo -e "  ${CYAN}GitHub : github.com/techwithburhan${RESET}"
echo -e "  ${CYAN}YouTube: @TechWithBurhanHQ${RESET}"
echo ""
