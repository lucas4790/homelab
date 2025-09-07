# 🏗 Self‑Hosted Kubernetes Stack – Replacement for Paid Services

This README documents the full plan to replace various paid/cloud services with a **self‑hosted, Kubernetes‑based stack**.
It includes the chosen applications, their purposes, installation notes, namespace layout, and a recommended deployment order.

---

## 📜 Table of Contents
1. [Core Infrastructure](#1-core-infrastructure)
2. [Authentication & Secrets](#2-authentication--secrets)
3. [Media & Entertainment](#3-media--entertainment)
4. [Files, Knowledge & Lifestyle](#4-files-knowledge--lifestyle)
5. [Monitoring & Backups](#5-monitoring--backups)
6. [Automation, Development & Quality of Life](#6-automation-development--quality-of-life)
7. [Suggested Namespace Layout](#-suggested-namespace-layout)
8. [Recommended Deployment Order](#-recommended-deployment-order)
9. [General Notes](#-general-notes)

---

## 1️⃣ Core Infrastructure

| Component | Purpose | Install Notes |
|-----------|---------|---------------|
| **Kubernetes Cluster** | Orchestration platform | Deploy via k3s, kubeadm, or cloud provider; ensure persistent storage & ingress |
| **NFS Provisioner** | Shared storage backend | Deploy NFS server or use NAS; create StorageClass for PVs |
| **Emissary‑ingress** | API gateway / ingress controller | Routes external traffic to services; integrates with SSO & TLS |
| **Cert‑Manager + Let’s Encrypt** | Automatic TLS certificates | Issue/renew certs via HTTP‑01 or DNS‑01 challenge |
| **Network Policies** | Pod‑to‑pod traffic control | Define per‑namespace; restrict unnecessary communication |
| **Fail2Ban / CrowdSec** | Brute‑force protection | Deploy as DaemonSet or on ingress nodes; block malicious IPs |
| **Shlink** | Self‑hosted URL shortener with analytics | Deploy with DB backend (PostgreSQL/MySQL) and HTTPS ingress |
| **Pi‑hole** | Network‑wide ad blocker & DNS sinkhole | Deploy as a service with host networking or MetalLB; persistent config storage |

---

## 2️⃣ Authentication & Secrets

| Component | Purpose | Install Notes |
|-----------|---------|---------------|
| **Authentic** | Single Sign‑On (SSO) | Keep existing; integrate with Emissary for central auth |
| **Authelia** | Authentication gateway for services without native SSO | Requires Redis backend; integrate with ingress rules |
| **HashiCorp Vault** | Secure storage for API keys & personal keys | Separate namespaces for API vs personal keys; enable Kubernetes auth |
| **Vaultwarden** | Lightweight Bitwarden‑compatible password manager | Persistent volume for vault data; HTTPS ingress; optional 2FA |
| **Sealed Secrets** *(optional)* | GitOps‑friendly secrets | Encrypt secrets for storage in Git repos |

---

## 3️⃣ Media & Entertainment

| Component | Purpose | Install Notes |
|-----------|---------|---------------|
| **Jellyfin** | Netflix/Disney+ replacement | StatefulSet; hardware transcoding if supported |
| **Arr Stack** (Sonarr, Radarr, Lidarr, etc.) | Media automation | Integrate with Jellyfin; persistent volumes for configs |
| **Immich** | Google Photos replacement | StatefulSet; GPU optional for AI features; NFS or object storage backend |

---

## 4️⃣ Files, Knowledge & Lifestyle

| Component | Purpose | Install Notes |
|-----------|---------|---------------|
| **Nextcloud** | File storage & sync | StatefulSet; use MinIO or NFS backend |
| **MinIO** | S3‑compatible object storage | Backend for Nextcloud, Immich, backups |
| **Paperless‑ngx** | Document management & OCR | Persistent storage; optional S3 backend |
| **Self‑Hosted Obsidian** | Personal knowledge base | Deploy obsidian‑remote; vault stored on NFS/Nextcloud |
| **Gorcy** | Online cookbook & meal planner | StatefulSet; persistent storage; import recipes from URLs; meal planning & shopping lists |

---

## 5️⃣ Monitoring & Backups

| Component | Purpose | Install Notes |
|-----------|---------|---------------|
| **Prometheus + Grafana** | Metrics & dashboards | Monitor cluster, apps, hardware |
| **Loki + Promtail** | Centralised logging | Search logs across all apps |
| **Uptime Kuma** | Service uptime monitoring | Alerts via email/Telegram |
| **Scrutiny** | SMART disk health monitoring | Requires host disk access; Prometheus integration optional |
| **Velero** | Cluster & PV backups | Backup to MinIO or off‑site S3 |
| **Restic / Rclone** | File‑level backups | Sync to off‑site storage (Backblaze, Wasabi, etc.) |

---

## 6️⃣ Automation, Development & Quality of Life

| Component | Purpose | Install Notes |
|-----------|---------|---------------|
| **Renovate Bot** | Automated dependency updates | Monitors Helm charts & container images |
| **Homepage / Dashy / Heimdall** | Central dashboard | Links to all services; deployed in `infra` namespace |
| **ArgoCD** *(optional)* | GitOps deployment | Version‑controlled, reproducible installs |
| **K9s** *(optional)* | Terminal UI for Kubernetes | Easier cluster management |
| **n8n** | Self‑hosted workflow automation | Persistent storage for workflows; HTTPS ingress; can integrate with all other services |
| **GitLab** | Self‑hosted Git repository manager with CI/CD | StatefulSet; requires PostgreSQL & Redis; persistent storage for repos and CI artifacts |

---

## 📂 Suggested Namespace Layout