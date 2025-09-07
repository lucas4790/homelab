#!/bin/bash
set -e

echo "🧪 Testing ALL PHASES: Complete Homelab Stack"

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
echo "================================="

# Test namespaces
test_k8s_resource "namespace" "" "argocd"
test_k8s_resource "namespace" "" "cert-manager"
test_k8s_resource "namespace" "" "files"
test_k8s_resource "namespace" "" "productivity"
test_k8s_resource "namespace" "" "auth"
test_k8s_resource "namespace" "" "media"
test_k8s_resource "namespace" "" "monitoring"

echo ""
echo -e "${BLUE}🌐 Testing Service Endpoints${NC}"
echo "============================="

# Phase 1: Infrastructure
echo -e "${YELLOW}Phase 1: Infrastructure${NC}"
test_endpoint "ArgoCD" "http://argocd.homelab.local" "200"
test_endpoint "MinIO Console" "http://minio-console.homelab.local" "200"
test_endpoint "Nextcloud" "http://nextcloud.homelab.local" "200"
test_endpoint "Homepage" "http://homepage.homelab.local" "200"

# Phase 2: Authentication
echo -e "${YELLOW}Phase 2: Authentication${NC}"
test_endpoint "Authentic" "http://auth.homelab.local" "200"
test_endpoint "Vault" "http://vault.homelab.local" "200"

# Phase 3: Media
echo -e "${YELLOW}Phase 3: Media Services${NC}"
test_endpoint "Jellyfin" "http://jellyfin.homelab.local" "200"
test_endpoint "Immich" "http://immich.homelab.local" "200"

# Phase 4: Productivity
echo -e "${YELLOW}Phase 4: Productivity Tools${NC}"
test_endpoint "Paperless-ngx" "http://paperless.homelab.local" "200"
test_endpoint "Grocy" "http://grocy.homelab.local" "200"
test_endpoint "n8n" "http://n8n.homelab.local" "200"

# Phase 5: Monitoring
echo -e "${YELLOW}Phase 5: Monitoring${NC}"
test_endpoint "Grafana" "http://grafana.homelab.local" "200"
test_endpoint "Prometheus" "http://prometheus.homelab.local" "200"
test_endpoint "AlertManager" "http://alertmanager.homelab.local" "200"

echo ""
echo -e "${BLUE}📊 ArgoCD Application Status${NC}"
echo "============================"
kubectl get applications -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status

echo ""
echo -e "${BLUE}🔍 Pod Status Summary${NC}"
echo "===================="
echo "Infrastructure pods:"
kubectl get pods -n argocd -o wide | head -5
echo ""
echo "Files namespace pods:"
kubectl get pods -n files -o wide | head -5
echo ""
echo "Auth namespace pods:"
kubectl get pods -n auth -o wide | head -5
echo ""
echo "Media namespace pods:"
kubectl get pods -n media -o wide | head -5
echo ""
echo "Productivity namespace pods:"
kubectl get pods -n productivity -o wide | head -5
echo ""
echo "Monitoring namespace pods:"
kubectl get pods -n monitoring -o wide | head -5

echo ""
echo -e "${BLUE}💾 Storage Usage${NC}"
echo "================"
kubectl get pvc --all-namespaces

echo ""
echo -e "${BLUE}🎯 Complete Homelab Summary${NC}"
echo "=========================="
echo -e "${GREEN}✅ Phase 1: Core Infrastructure${NC}"
echo -e "${GREEN}✅ Phase 2: Authentication & Platform${NC}"
echo -e "${GREEN}✅ Phase 3: Media Services${NC}"
echo -e "${GREEN}✅ Phase 4: Productivity Tools${NC}"
echo -e "${GREEN}✅ Phase 5: Monitoring & Automation${NC}"

echo ""
echo -e "${YELLOW}💡 Access Information:${NC}"
echo "🔧 ArgoCD:        http://argocd.homelab.local (admin / see deployment output)"
echo "🔐 Authentic:     http://auth.homelab.local"
echo "🔒 Vault:         http://vault.homelab.local (root-token-change-me)"
echo "☁️  Nextcloud:     http://nextcloud.homelab.local (admin / admin123)"
echo "🎬 Jellyfin:      http://jellyfin.homelab.local"
echo "📸 Immich:        http://immich.homelab.local"
echo "📄 Paperless:     http://paperless.homelab.local (admin / admin123)"
echo "🛒 Grocy:         http://grocy.homelab.local"
echo "🔄 n8n:           http://n8n.homelab.local (admin / admin123)"
echo "📊 Grafana:       http://grafana.homelab.local (admin / admin123)"
echo "🏠 Homepage:      http://homepage.homelab.local"

echo ""
echo -e "${GREEN}🎉 COMPLETE HOMELAB TESTING FINISHED!${NC}"
