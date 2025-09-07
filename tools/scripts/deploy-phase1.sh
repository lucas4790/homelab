#!/bin/bash
set -e

echo "🚀 Deploying Phase 1: Core Infrastructure + Essential Apps"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if minikube is running
if ! minikube status | grep -q "Running"; then
    echo -e "${RED}❌ Minikube is not running. Please run: ./scripts/setup-minikube.sh${NC}"
    exit 1
fi

# Check if kubectl is working
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Phase 1 Deployment Plan:${NC}"
echo "  1. Create namespaces"
echo "  2. Install ArgoCD"
echo "  3. Install cert-manager"
echo "  4. Deploy applications via ArgoCD"
echo "  5. Configure local DNS entries"
echo ""

# Step 1: Create namespaces
echo -e "${YELLOW}📦 Step 1: Creating namespaces...${NC}"
kubectl apply -f bootstrap/namespaces/namespaces.yaml
echo -e "${GREEN}✅ Namespaces created${NC}"

# Step 2: Install ArgoCD
echo -e "${YELLOW}📦 Step 2: Installing ArgoCD...${NC}"
cd infrastructure/argocd
helm dependency update
helm upgrade --install argocd . \
    --namespace argocd \
    --create-namespace \
    --wait \
    --timeout=10m
cd ../..

# Get ArgoCD admin password
echo -e "${BLUE}🔑 ArgoCD Admin Password:${NC}"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo -e "${GREEN}✅ ArgoCD installed${NC}"

# Step 3: Wait for ArgoCD to be ready
echo -e "${YELLOW}⏳ Waiting for ArgoCD to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
echo -e "${GREEN}✅ ArgoCD is ready${NC}"

# Step 4: Install cert-manager
echo -e "${YELLOW}📦 Step 3: Installing cert-manager...${NC}"
cd infrastructure/cert-manager
helm dependency update
helm upgrade --install cert-manager . \
    --namespace cert-manager \
    --create-namespace \
    --wait \
    --timeout=10m
cd ../..

# Wait for cert-manager to be ready
echo -e "${YELLOW}⏳ Waiting for cert-manager to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager

# Apply cluster issuers
kubectl apply -f infrastructure/cert-manager/cluster-issuer.yaml
echo -e "${GREEN}✅ cert-manager installed${NC}"

# Step 5: Deploy applications via ArgoCD
echo -e "${YELLOW}📦 Step 4: Deploying infrastructure applications...${NC}"
kubectl apply -f config/argocd/infrastructure.yaml
echo -e "${GREEN}✅ Infrastructure applications deployed${NC}"

echo -e "${YELLOW}📦 Step 5: Deploying Phase 1 applications...${NC}"
kubectl apply -f config/argocd/phase1-apps.yaml
echo -e "${GREEN}✅ Phase 1 applications deployed${NC}"

# Step 6: Configure local DNS
echo -e "${YELLOW}🌐 Step 6: Configuring local DNS entries...${NC}"
MINIKUBE_IP=$(minikube ip)
echo -e "${BLUE}Add these entries to your /etc/hosts file:${NC}"
echo "$MINIKUBE_IP argocd.homelab.local"
echo "$MINIKUBE_IP minio.homelab.local"
echo "$MINIKUBE_IP minio-console.homelab.local"
echo "$MINIKUBE_IP nextcloud.homelab.local"
echo "$MINIKUBE_IP homepage.homelab.local"
echo ""
echo -e "${YELLOW}Or run this command to add them automatically:${NC}"
echo "sudo ./scripts/update-hosts.sh"

echo ""
echo -e "${GREEN}🎉 Phase 1 deployment complete!${NC}"
echo ""
echo -e "${BLUE}📋 Access your services:${NC}"
echo "  🔧 ArgoCD:        http://argocd.homelab.local (admin / see password above)"
echo "  🗄️  MinIO Console: http://minio-console.homelab.local (minioadmin / minioadmin123)"
echo "  ☁️  Nextcloud:     http://nextcloud.homelab.local (admin / admin123)"
echo "  🏠 Homepage:      http://homepage.homelab.local"
echo ""
echo -e "${YELLOW}⚠️  Remember to run: minikube tunnel (in another terminal)${NC}"
echo -e "${BLUE}💡 Monitor deployments: kubectl get applications -n argocd${NC}"
