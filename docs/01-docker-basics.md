# Docker & Docker Compose

## Concepts clés

| Concept | Description |
|---------|-------------|
| **Image** | Template read-only (ex: `nginx:alpine`) |
| **Container** | Instance d'une image en cours d'exécution |
| **Volume** | Données persistantes montées dans un container |
| **Network** | Réseau isolé pour la communication inter-containers |

## docker-compose.yml - Structure

```yaml
services:
  nom_service:
    image: image:tag
    ports:
      - "HOST:CONTAINER"
    volumes:
      - ./local:/container/path
    networks:
      - mon-reseau
    depends_on:
      - autre_service

networks:
  mon-reseau:
    driver: bridge
```

## Commandes essentielles

```bash
docker compose up -d      # Démarrer en arrière-plan
docker compose down       # Arrêter et supprimer
docker compose ps         # Liste des containers
docker compose logs -f    # Logs en temps réel
docker compose exec <svc> sh  # Shell dans un container
```

## Communication inter-services

Les services sur le même réseau se trouvent par leur **nom** :
```bash
docker compose exec nginx ping consul  # ✅ Fonctionne !
```
