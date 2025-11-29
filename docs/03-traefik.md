# Traefik

## C'est quoi ?

Reverse Proxy dynamique qui découvre les services automatiquement.

## Concepts

| Concept | Description |
|---------|-------------|
| **Entrypoint** | Port d'entrée (ex: `:80`, `:443`) |
| **Router** | Règle de routage (`Host`, `Path`, etc.) |
| **Service** | Backend vers lequel router |
| **Provider** | Source de config (Docker, Consul, fichier...) |

## Intégration Consul

Traefik lit le **Consul Catalog** et crée automatiquement les routes.

```
Service enregistré dans Consul
        ↓
Traefik le détecte
        ↓
Route créée automatiquement
```

## Configuration (arguments)

```yaml
command:
  - --api.insecure=true                              # Dashboard
  - --providers.consulcatalog.endpoint.address=consul:8500
  - --providers.consulcatalog.exposedByDefault=false # Opt-in
  - --entrypoints.web.address=:80
```

## Tags Traefik (dans Consul)

```json
"Tags": [
  "traefik.enable=true",
  "traefik.http.routers.nginx.rule=Host(`nginx.localhost`)",
  "traefik.http.routers.nginx.entrypoints=web"
]
```
