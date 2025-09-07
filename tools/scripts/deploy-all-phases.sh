#!/bin/bash
set -e

echo "🚀 Deploying ALL PHASES: Complete Homelab Stack"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if minikube is running
if ! minikube status | grep -q "Running"; then
    echo -e "${RED}❌ Minikube is not running. Please run: ./tools/scripts/setup-minikube.sh${NC}"
    exit 1
fi

# Check if kubectl is working
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Complete Homelab Deployment Plan:${NC}"
echo "  Phase 1: ✅ Core Infrastructure (already deployed)"
echo "  Phase 2: 🔐 Authentication & Platform Services"
echo "  Phase 3: 🎬 Media Services"
echo "  Phase 4: 📋 Productivity Tools"
echo "  Phase 5: 📊 Monitoring & Automation"
echo ""

# Add required Helm repositories
echo -e "${YELLOW}📦 Adding additional Helm repositories...${NC}"
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Deploy Phase 2: Platform Services
echo -e "${YELLOW}🔐 Phase 2: Deploying Platform Services...${NC}"
kubectl apply -f config/argocd/phase2-platform.yaml
echo -e "${GREEN}✅ Phase 2 applications deployed${NC}"

# Wait a bit for Phase 2 to start
echo -e "${YELLOW}⏳ Waiting for Phase 2 to initialize...${NC}"
sleep 30

# Deploy Phase 3: Media Services
echo -e "${YELLOW}🎬 Phase 3: Deploying Media Services...${NC}"
kubectl apply -f config/argocd/phase3-media.yaml
echo -e "${GREEN}✅ Phase 3 applications deployed${NC}"

# Wait a bit for Phase 3 to start
echo -e "${YELLOW}⏳ Waiting for Phase 3 to initialize...${NC}"
sleep 30

# Deploy Phase 4: Productivity Tools
echo -e "${YELLOW}📋 Phase 4: Deploying Productivity Tools...${NC}"
kubectl apply -f config/argocd/phase4-productivity.yaml
echo -e "${GREEN}✅ Phase 4 applications deployed${NC}"

# Wait a bit for Phase 4 to start
echo -e "${YELLOW}⏳ Waiting for Phase 4 to initialize...${NC}"
sleep 30

# Deploy Phase 5: Monitoring
echo -e "${YELLOW}📊 Phase 5: Deploying Monitoring Stack...${NC}"
kubectl apply -f config/argocd/phase5-monitoring.yaml
echo -e "${GREEN}✅ Phase 5 applications deployed${NC}"

# Update hosts file
echo -e "${YELLOW}🌐 Updating DNS entries...${NC}"
MINIKUBE_IP=$(minikube ip)
echo -e "${BLUE}Add these entries to your /etc/hosts file:${NC}"
echo "$MINIKUBE_IP argocd.homelab.local"
echo "$MINIKUBE_IP minio-console.homelab.local"
echo "$MINIKUBE_IP nextcloud.homelab.local"
echo "$MINIKUBE_IP homepage.homelab.local"
echo "$MINIKUBE_IP auth.homelab.local"
echo "$MINIKUBE_IP vault.homelab.local"
echo "$MINIKUBE_IP jellyfin.homelab.local"
echo "$MINIKUBE_IP immich.homelab.local"
echo "$MINIKUBE_IP paperless.homelab.local"
echo "$MINIKUBE_IP grocy.homelab.local"
echo "$MINIKUBE_IP n8n.homelab.local"
echo "$MINIKUBE_IP grafana.homelab.local"
echo "$MINIKUBE_IP prometheus.homelab.local"
echo "$MINIKUBE_IP alertmanager.homelab.local"
echo ""
echo -e "${YELLOW}Or run this command to add them automatically:${NC}"
echo "sudo ./tools/scripts/update-hosts.sh"

echo ""
echo -e "${GREEN}🎉 ALL PHASES DEPLOYMENT COMPLETE!${NC}"
echo ""
echo -e "${BLUE}📋 Access your complete homelab:${NC}"
echo ""
echo -e "${BLUE}🔧 INFRASTRUCTURE:${NC}"
echo "  🔧 ArgoCD:        http://argocd.homelab.local"
echo "  🗄️  MinIO Console: http://minio-console.homelab.local"
echo ""
echo -e "${BLUE}🔐 AUTHENTICATION:${NC}"
echo "  🔐 Authentic:     http://auth.homelab.local"
echo "  🔒 Vault:         http://vault.homelab.local"
echo ""
echo -e "${BLUE}☁️ FILES & STORAGE:${NC}"
echo "  ☁️  Nextcloud:     http://nextcloud.homelab.local"
echo "  🏠 Homepage:      http://homepage.homelab.local"
echo ""
echo -e "${BLUE}🎬 MEDIA:${NC}"
echo "  🎬 Jellyfin:      http://jellyfin.homelab.local"
echo "  📸 Immich:        http://immich.homelab.local"
echo ""
echo -e "${BLUE}📋 PRODUCTIVITY:${NC}"
echo "  📄 Paperless:     http://paperless.homelab.local"
echo "  🛒 Grocy:         http://grocy.homelab.local"
echo "  🔄 n8n:           http://n8n.homelab.local"
echo ""
echo -e "${BLUE}📊 MONITORING:${NC}"
echo "  📊 Grafana:       http://grafana.homelab.local"
echo "  📈 Prometheus:    http://prometheus.homelab.local"
echo "  🚨 AlertManager:  http://alertmanager.homelab.local"
echo ""
echo -e "${YELLOW}⚠️  Remember to run: minikube tunnel (in another terminal)${NC}"
echo -e "${BLUE}💡 Monitor all deployments: kubectl get applications -n argocd${NC}"
echo -e "${GREEN}🎯 Your complete self-hosted homelab is now running!${NC}"
