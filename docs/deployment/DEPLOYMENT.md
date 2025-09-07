# 🚀 Homelab Deployment Guide

This guide walks you through deploying your self-hosted Kubernetes homelab stack step by step.

## 📋 Prerequisites

- Docker installed and running
- Minikube installed
- Helm 3.x installed
- kubectl installed
- Git repository pushed to GitHub (lucas4790/homelab)

## 🏗️ Architecture Overview

The homelab is organized into phases for incremental deployment:

### Phase 1: Core Infrastructure + Essential Apps ✅
- **Infrastructure**: ArgoCD, cert-manager, namespaces
- **Storage**: MinIO (S3-compatible object storage)
- **Files**: Nextcloud (file sync & sharing)
- **Dashboard**: Homepage (service overview)

### Phase 2: Authentication & Security (Future)
- Authentic/Authelia for SSO
- Vault for secrets management
- Enhanced security policies

### Phase 3: Media Services (Future)
- Jellyfin (media server)
- Arr stack (media automation)
- Immich (photo management)

### Phase 4: Productivity Tools (Future)
- Paperless-ngx (document management)
- Obsidian (knowledge base)
- Grocy (inventory management)

### Phase 5: Monitoring & Automation (Future)
- Prometheus + Grafana (monitoring)
- n8n (workflow automation)
- Uptime monitoring

## 🚀 Quick Start

### 1. Set up Minikube Environment
```bash
./scripts/setup-minikube.sh
```

### 2. Deploy Phase 1
```bash
./scripts/deploy-phase1.sh
```

### 3. Configure Local DNS
```bash
sudo ./scripts/update-hosts.sh
```

### 4. Start Tunnel (in separate terminal)
```bash
minikube tunnel
```

### 5. Test Services
```bash
./scripts/test-services.sh
```

## 🌐 Service Access

After deployment, access your services at:

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| ArgoCD | http://argocd.homelab.local | admin / (see deployment output) |
| MinIO Console | http://minio-console.homelab.local | minioadmin / minioadmin123 |
| Nextcloud | http://nextcloud.homelab.local | admin / admin123 |
| Homepage | http://homepage.homelab.local | No auth required |

## 📁 Project Structure

```
homelab/
├── apps/                          # Application configurations
│   ├── auth/                      # Authentication services
│   ├── files/                     # File storage services
│   │   ├── minio/                 # MinIO object storage
│   │   └── nextcloud/             # Nextcloud file sync
│   ├── media/                     # Media services (future)
│   └── productivity/              # Productivity tools
│       └── homepage/              # Service dashboard
├── argocd/                        # ArgoCD application definitions
│   └── apps/                      # Application manifests
├── infrastructure/                # Core infrastructure
│   ├── argocd/                    # ArgoCD installation
│   ├── cert-manager/              # Certificate management
│   └── namespaces/                # Kubernetes namespaces
└── scripts/                       # Deployment and utility scripts
```

## 🔧 Development Workflow

1. **Make changes** to Helm charts or configurations
2. **Commit and push** to GitHub
3. **ArgoCD automatically syncs** changes to cluster
4. **Monitor** via ArgoCD UI or `kubectl get applications -n argocd`

## 🛠️ Troubleshooting

### Common Issues

**Services not accessible:**
- Ensure `minikube tunnel` is running
- Check `/etc/hosts` has homelab entries
- Verify ingress controller: `kubectl get pods -n ingress-nginx`

**ArgoCD applications not syncing:**
- Check application status: `kubectl get applications -n argocd`
- View application details: `kubectl describe application <app-name> -n argocd`
- Force sync via ArgoCD UI

**Pods not starting:**
- Check pod status: `kubectl get pods -n <namespace>`
- View pod logs: `kubectl logs <pod-name> -n <namespace>`
- Check events: `kubectl get events -n <namespace>`

### Useful Commands

```bash
# Check cluster status
kubectl cluster-info

# View all applications
kubectl get applications -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Restart a deployment
kubectl rollout restart deployment/<deployment-name> -n <namespace>

# Port forward to a service (alternative to minikube tunnel)
kubectl port-forward service/<service-name> <local-port>:<service-port> -n <namespace>
```

## 🔮 Next Steps

1. **Test Phase 1** thoroughly on minikube
2. **Plan production deployment** on your homelab hardware
3. **Implement authentication** (Phase 2)
4. **Add media services** (Phase 3)
5. **Deploy monitoring stack** (Phase 5)

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
