#!/bin/bash
set -e

echo "🚀 Setting up Minikube development environment for homelab..."

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed. Please install it first:"
    echo "   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
    echo "   sudo install minikube-linux-amd64 /usr/local/bin/minikube"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install it first:"
    echo "   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    exit 1
fi

# Start minikube with appropriate resources
echo "🔧 Starting minikube with sufficient resources..."
minikube start \
    --cpus=2 \
    --memory=4096 \
    --disk-size=30g \
    --driver=docker \
    --kubernetes-version=v1.28.3

# Enable required addons
echo "🔧 Enabling minikube addons..."
minikube addons enable ingress
minikube addons enable storage-provisioner
minikube addons enable default-storageclass
minikube addons enable metrics-server

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add jetstack https://charts.jetstack.io
helm repo add emissary-ingress https://app.getambassador.io
helm repo add minio https://charts.min.io/
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "✅ Minikube setup complete!"
echo "🔍 Cluster info:"
kubectl cluster-info
echo ""
echo "🌐 To access services later, run: minikube tunnel"
echo "📊 To open dashboard, run: minikube dashboard"
