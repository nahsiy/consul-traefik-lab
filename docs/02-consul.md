# Consul

## C'est quoi ?

Service Discovery + Health Checking + KV Store

## Fonctionnalités

| Fonction | Utilité |
|----------|---------|
| **Service Discovery** | Les services se trouvent par nom, pas par IP |
| **Health Check** | Consul sait quels services sont UP/DOWN |
| **KV Store** | Stockage clé/valeur pour config partagée |
| **Catalog** | Traefik lit le catalog pour router automatiquement |

## API principales

```bash
# Enregistrer un service
curl -X PUT http://localhost:8500/v1/agent/service/register \
  -d '{"Name": "mon-service", "Port": 80}'

# Lister les services
curl http://localhost:8500/v1/catalog/services

# KV Store - écrire
curl -X PUT -d "valeur" http://localhost:8500/v1/kv/ma/cle

# KV Store - lire
curl http://localhost:8500/v1/kv/ma/cle?raw
```

## Modes

- **`-dev`** : Développement (données en mémoire, 1 seul nœud)
- **`-server`** : Production (cluster, données persistantes)
