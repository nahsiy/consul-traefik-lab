# 🚀 Consul-Traefik Lab

Environnement local pour apprendre Consul (Service Discovery) et Traefik (Reverse Proxy) sur Mac M4.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Mac M4 (ARM64)                       │
└─────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
    :80 (HTTP)          :8081 (Dashboard)    :8500 (Consul)
         │
         ▼
┌─────────────────┐   découvre    ┌─────────────────┐
│    Traefik      │◄────────────►│     Consul      │
│  (Reverse Proxy)│   services    │(Service Registry)│
└────────┬────────┘              └─────────────────┘
         │                               ▲
         │ route                         │ enregistré via
         ▼                               │ Ansible
┌─────────────────┐                      │
│     Nginx       │──────────────────────┘
│   :8080 (direct)│
└─────────────────┘
```

## Commandes rapides

```bash
# Démarrer l'infra
cd docker && docker compose up -d

# Option A : Enregistrer les services avec Ansible
cd ansible && ansible-playbook playbooks/register-services.yml

# Option B : Enregistrer les services avec Terraform (recommandé)
cd terraform && terraform init && terraform apply

# Arrêter l'infra
cd docker && docker compose down
```

## URLs

| Service | URL | Description |
|---------|-----|-------------|
| Dashboard | http://localhost:8080 | Page d'accueil du lab |
| Consul UI | http://localhost:8500 | Service Discovery |
| Traefik | http://localhost:8081 | Dashboard Traefik |
| Prometheus | http://localhost:9090 | Métriques & Queries |
| Grafana | http://localhost:3000 | Dashboards de monitoring |

## Structure

```
consul-traefik-lab/
├── ansible/          # Playbooks de configuration
├── configs/          # Fichiers de config des services
├── docker/           # Docker Compose + volumes
├── docs/             # Notes d'apprentissage
└── terraform/        # Infrastructure as Code (à venir)
```

## Stack

- 🐳 **Docker** - Conteneurisation
- 🔍 **Consul** - Service Discovery & KV Store
- 🔀 **Traefik** - Reverse Proxy dynamique
- 📊 **Prometheus** - Collecte de métriques
- 📈 **Grafana** - Visualisation & Dashboards
- 📜 **Ansible** - Automatisation de configuration
- 🏗️ **Terraform** - Infrastructure as Code