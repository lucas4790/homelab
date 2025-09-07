#!/bin/bash
set -e

echo "🧪 Testing Phase 1 Services"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to test HTTP endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $name... "
    
    if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 30 "$url" | grep -q "$expected_status"; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Function to test Kubernetes resource
test_k8s_resource() {
    local resource=$1
    local namespace=$2
    local name=${3:-""}
    
    echo -n "Testing $resource in $namespace... "
    
    if [ -n "$name" ]; then
        if kubectl get "$resource" "$name" -n "$namespace" &>/dev/null; then
            echo -e "${GREEN}✅ OK${NC}"
            return 0
        else
            echo -e "${RED}❌ FAILED${NC}"
            return 1
        fi
    else
        if kubectl get "$resource" -n "$namespace" &>/dev/null; then
            echo -e "${GREEN}✅ OK${NC}"
            return 0
        else
            echo -e "${RED}❌ FAILED${NC}"
            return 1
        fi
    fi
}

echo -e "${BLUE}🔍 Testing Kubernetes Resources${NC}"
echo "================================"

# Test namespaces
test_k8s_resource "namespace" "" "argocd"
test_k8s_resource "namespace" "" "cert-manager"
test_k8s_resource "namespace" "" "files"
test_k8s_resource "namespace" "" "productivity"

# Test ArgoCD
test_k8s_resource "deployment" "argocd" "argocd-server"
test_k8s_resource "deployment" "argocd" "argocd-repo-server"
test_k8s_resource "deployment" "argocd" "argocd-application-controller"

# Test cert-manager
test_k8s_resource "deployment" "cert-manager" "cert-manager"
test_k8s_resource "deployment" "cert-manager" "cert-manager-webhook"
test_k8s_resource "deployment" "cert-manager" "cert-manager-cainjector"

# Test cluster issuers
test_k8s_resource "clusterissuer" "" "selfsigned-issuer"
test_k8s_resource "clusterissuer" "" "letsencrypt-staging"

echo ""
echo -e "${BLUE}🌐 Testing Service Endpoints${NC}"
echo "============================="

# Test endpoints (these will only work if minikube tunnel is running and hosts are configured)
test_endpoint "ArgoCD" "http://argocd.homelab.local" "200"
test_endpoint "MinIO Console" "http://minio-console.homelab.local" "200"
test_endpoint "Nextcloud" "http://nextcloud.homelab.local" "200"
test_endpoint "Homepage" "http://homepage.homelab.local" "200"

echo ""
echo -e "${BLUE}📊 Application Status in ArgoCD${NC}"
echo "================================="
kubectl get applications -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status

echo ""
echo -e "${BLUE}🔍 Pod Status${NC}"
echo "============="
echo "ArgoCD pods:"
kubectl get pods -n argocd
echo ""
echo "cert-manager pods:"
kubectl get pods -n cert-manager
echo ""
echo "Files namespace pods:"
kubectl get pods -n files
echo ""
echo "Productivity namespace pods:"
kubectl get pods -n productivity

echo ""
echo -e "${YELLOW}💡 Troubleshooting Tips:${NC}"
echo "- If endpoints fail, ensure 'minikube tunnel' is running"
echo "- If endpoints fail, ensure /etc/hosts is configured (run ./scripts/update-hosts.sh)"
echo "- Check ArgoCD for application sync status: kubectl get applications -n argocd"
echo "- View application logs: kubectl logs -n <namespace> <pod-name>"
echo "- Access ArgoCD UI: http://argocd.homelab.local (admin / get password with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
