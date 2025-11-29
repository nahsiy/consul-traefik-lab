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

# Enregistrer les services dans Consul
cd ansible && ansible-playbook playbooks/register-services.yml

# Arrêter l'infra
cd docker && docker compose down
```

## URLs

| Service | URL | Description |
|---------|-----|-------------|
| Dashboard | http://localhost:8080 | Page d'accueil du lab |
| Consul UI | http://localhost:8500 | Service Discovery |
| Traefik | http://localhost:8081 | Dashboard Traefik |

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
- 📜 **Ansible** - Automatisation de configuration
- 🏗️ **Terraform** - Infrastructure as Code (à venir)