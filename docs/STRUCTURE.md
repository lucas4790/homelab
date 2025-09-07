# 📁 Improved Directory Structure

## 🎯 Design Principles

1. **Single Source of Truth**: Each app exists in exactly one logical location
2. **Clear Separation**: Infrastructure vs Applications vs Configuration
3. **Namespace Alignment**: Directory structure matches Kubernetes namespaces
4. **GitOps Ready**: Structure supports ArgoCD's app-of-apps pattern
5. **Scalable**: Easy to add new apps without confusion

## 🏗️ Proposed Structure

```
homelab/
├── 🔧 infrastructure/           # Core platform components
│   ├── argocd/                 # GitOps controller
│   ├── cert-manager/           # Certificate management
│   ├── ingress-nginx/          # Ingress controller (or emissary)
│   ├── monitoring/             # Prometheus, Grafana stack
│   ├── storage/                # Storage classes, PV provisioners
│   └── security/               # Network policies, RBAC
│
├── 🔐 platform/                # Platform services (shared by apps)
│   ├── auth/                   # Authentication services
│   │   ├── authentic/          # SSO provider
│   │   ├── authelia/           # Auth gateway
│   │   └── vault/              # Secrets management
│   ├── database/               # Shared databases
│   │   ├── postgresql/         # PostgreSQL cluster
│   │   └── redis/              # Redis cluster
│   └── messaging/              # Message queues, etc.
│
├── 📱 applications/             # End-user applications
│   ├── media/                  # Media & entertainment
│   │   ├── jellyfin/           # Media server
│   │   ├── immich/             # Photo management
│   │   ├── sonarr/             # TV show automation
│   │   └── radarr/             # Movie automation
│   ├── files/                  # File storage & management
│   │   ├── nextcloud/          # File sync & collaboration
│   │   ├── minio/              # Object storage
│   │   └── paperless-ngx/      # Document management
│   ├── productivity/           # Productivity tools
│   │   ├── obsidian/           # Knowledge management
│   │   ├── grocy/              # Inventory management
│   │   └── n8n/                # Workflow automation
│   ├── development/            # Development tools
│   │   ├── gitlab/             # Git repository & CI/CD
│   │   └── renovate/           # Dependency updates
│   └── dashboard/              # Dashboards & monitoring
│       ├── homepage/           # Service dashboard
│       └── uptime-kuma/        # Uptime monitoring
│
├── 🚀 bootstrap/                # Initial cluster setup
│   ├── namespaces/             # Namespace definitions
│   ├── crds/                   # Custom Resource Definitions
│   └── rbac/                   # Initial RBAC setup
│
├── 🎛️ config/                   # Configuration management
│   ├── argocd/                 # ArgoCD Applications
│   │   ├── infrastructure.yaml # Infrastructure apps
│   │   ├── platform.yaml       # Platform services
│   │   ├── applications.yaml   # End-user applications
│   │   └── projects/           # ArgoCD Projects
│   ├── environments/           # Environment-specific configs
│   │   ├── development/        # Dev/minikube overrides
│   │   ├── staging/            # Staging environment
│   │   └── production/         # Production environment
│   └── secrets/                # Secret templates (encrypted)
│
├── 🛠️ tools/                    # Deployment & management tools
│   ├── scripts/                # Automation scripts
│   ├── manifests/              # Raw Kubernetes manifests
│   └── helm/                   # Helm utilities
│
└── 📚 docs/                     # Documentation
    ├── deployment/             # Deployment guides
    ├── operations/             # Operational procedures
    └── troubleshooting/        # Common issues & solutions
```

## 🎯 Key Improvements

### 1. **Logical Grouping**
- **Infrastructure**: Core platform components that everything depends on
- **Platform**: Shared services used by multiple applications
- **Applications**: End-user facing applications grouped by purpose
- **Bootstrap**: Initial cluster setup (run once)
- **Config**: All ArgoCD and environment configurations

### 2. **Clear Ownership**
- Each application has exactly one home directory
- No duplication or confusion about where to find things
- Clear separation of concerns

### 3. **Environment Support**
- Environment-specific configurations in `config/environments/`
- Easy to manage dev/staging/prod differences
- Supports GitOps promotion workflows

### 4. **ArgoCD Integration**
- `config/argocd/` contains all Application definitions
- Supports app-of-apps pattern for easy management
- Clear dependency ordering (infrastructure → platform → applications)

## 🔄 Migration Strategy

1. **Create new structure** alongside existing
2. **Move applications** to correct locations
3. **Update ArgoCD configurations** to point to new paths
4. **Test in minikube** before production
5. **Clean up old structure** once verified
