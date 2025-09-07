#!/bin/bash
set -e

echo "🌐 Updating /etc/hosts with homelab entries..."

# Get minikube IP
MINIKUBE_IP=$(minikube ip)

if [ -z "$MINIKUBE_IP" ]; then
    echo "❌ Could not get minikube IP. Is minikube running?"
    exit 1
fi

echo "📍 Minikube IP: $MINIKUBE_IP"

# Backup hosts file
sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)

# Remove old homelab entries
sudo sed -i '/homelab\.local/d' /etc/hosts

# Add new homelab entries
cat << EOF | sudo tee -a /etc/hosts

# Homelab services (managed by homelab project)
# Infrastructure
$MINIKUBE_IP argocd.homelab.local
$MINIKUBE_IP minio.homelab.local
$MINIKUBE_IP minio-console.homelab.local

# Authentication & Platform
$MINIKUBE_IP auth.homelab.local
$MINIKUBE_IP vault.homelab.local

# Files & Storage
$MINIKUBE_IP nextcloud.homelab.local
$MINIKUBE_IP homepage.homelab.local

# Media Services
$MINIKUBE_IP jellyfin.homelab.local
$MINIKUBE_IP immich.homelab.local

# Productivity Tools
$MINIKUBE_IP paperless.homelab.local
$MINIKUBE_IP grocy.homelab.local
$MINIKUBE_IP n8n.homelab.local

# Monitoring & Observability
$MINIKUBE_IP grafana.homelab.local
$MINIKUBE_IP prometheus.homelab.local
$MINIKUBE_IP alertmanager.homelab.local
EOF

echo "✅ /etc/hosts updated with homelab entries"
echo "🔍 You can now access services at *.homelab.local domains"
