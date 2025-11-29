# 📊 Prometheus & Grafana - Monitoring

## C'est quoi ?

### Prometheus
**Prometheus** est un système de monitoring open-source créé par SoundCloud.
Il **collecte** (scrape) des métriques depuis des endpoints HTTP et les stocke dans une base de données temporelle (time-series).

### Grafana
**Grafana** est un outil de visualisation qui se connecte à Prometheus (et d'autres sources) pour créer des **dashboards** interactifs.

## Architecture

```
┌─────────────────┐     scrape /metrics     ┌─────────────────┐
│   Prometheus    │◄────────────────────────│    Traefik      │
│     :9090       │         (15s)           │   :8082/metrics │
└────────┬────────┘                         └─────────────────┘
         │
         │ PromQL queries
         ▼
┌─────────────────┐
│    Grafana      │ ──► Dashboards
│     :3000       │
└─────────────────┘
```

## Comment ça marche ?

### 1. Exposition des métriques
Chaque service expose un endpoint `/metrics` au format Prometheus :

```
# HELP traefik_entrypoint_requests_total Total requests
# TYPE traefik_entrypoint_requests_total counter
traefik_entrypoint_requests_total{code="200",entrypoint="web"} 42
traefik_entrypoint_requests_total{code="404",entrypoint="web"} 3
```

### 2. Scraping par Prometheus
Prometheus interroge régulièrement (toutes les 15s par défaut) les endpoints `/metrics` et stocke les valeurs avec un timestamp.

### 3. Requêtes PromQL
On peut interroger les données avec **PromQL** :

```promql
# Nombre total de requêtes
traefik_entrypoint_requests_total

# Requêtes par seconde (rate sur 1 minute)
rate(traefik_entrypoint_requests_total[1m])

# Seulement les erreurs 5xx
traefik_entrypoint_requests_total{code=~"5.."}
```

### 4. Visualisation Grafana
Grafana exécute des requêtes PromQL et affiche les résultats sous forme de graphes.

## Types de métriques

| Type | Description | Exemple |
|------|-------------|---------|
| **Counter** | Valeur qui ne fait qu'augmenter | Nombre total de requêtes |
| **Gauge** | Valeur qui monte et descend | Connexions actives |
| **Histogram** | Distribution de valeurs | Temps de réponse (p50, p95, p99) |
| **Summary** | Comme Histogram, calculé côté client | Moins utilisé |

## Explorer Prometheus

### Interface Web
Ouvrez http://localhost:9090

### Requêtes utiles

```promql
# Toutes les métriques Traefik
{job="traefik"}

# Requêtes par seconde par code HTTP
sum(rate(traefik_entrypoint_requests_total[1m])) by (code)

# Latence p95
histogram_quantile(0.95, sum(rate(traefik_entrypoint_request_duration_seconds_bucket[5m])) by (le))

# Services découverts par Traefik
traefik_service_open_connections
```

### Vérifier les cibles
Menu **Status > Targets** pour voir si Prometheus scrape bien les services.

## Explorer Grafana

### Accès
- URL : http://localhost:3000
- Pas de login (désactivé pour le lab)

### Dashboard pré-configuré
Un dashboard "Traefik - Consul-Traefik Lab" est déjà disponible avec :
- Requêtes par seconde
- Total des requêtes
- Distribution des codes HTTP
- Latence p50/p95

### Créer un nouveau panel

1. Cliquez sur **+ Add > Dashboard**
2. Cliquez sur **Add visualization**
3. Sélectionnez **Prometheus** comme datasource
4. Entrez une requête PromQL
5. Choisissez le type de visualisation

## Génerer du trafic pour tester

```bash
# Faire 100 requêtes via Traefik (port 80)
for i in {1..100}; do curl -s -H "Host: nginx.localhost" http://localhost > /dev/null; done

# Requêtes en boucle (Ctrl+C pour arrêter)
while true; do curl -s -H "Host: nginx.localhost" http://localhost > /dev/null; sleep 0.1; done

# Simuler des erreurs 404
for i in {1..10}; do curl -s -H "Host: nginx.localhost" http://localhost/inexistant > /dev/null; done
```

> ⚠️ **Important** : Les requêtes doivent passer par Traefik (port 80) pour générer des métriques.
> Les requêtes directes sur Nginx (port 8080) ne sont pas comptabilisées.

## Configuration Prometheus

Fichier : `docker/prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s      # Fréquence de collecte

scrape_configs:
  - job_name: 'traefik'     # Nom du job
    static_configs:
      - targets: ['traefik:8082']  # Adresse du endpoint /metrics
```

### Ajouter une nouvelle cible

```yaml
scrape_configs:
  # ... jobs existants ...
  
  - job_name: 'mon-app'
    static_configs:
      - targets: ['mon-app:3000']
    metrics_path: /metrics  # Par défaut
```

## Configuration Grafana

### Datasources
Fichier : `docker/grafana/provisioning/datasources/prometheus.yml`

Configure automatiquement Prometheus comme source de données.

### Dashboards
Dossier : `docker/grafana/dashboards/`

Les fichiers JSON sont chargés automatiquement au démarrage.

## Métriques exposées par Traefik

| Métrique | Type | Description |
|----------|------|-------------|
| `traefik_entrypoint_requests_total` | Counter | Nombre total de requêtes |
| `traefik_entrypoint_request_duration_seconds` | Histogram | Temps de réponse |
| `traefik_entrypoint_open_connections` | Gauge | Connexions ouvertes |
| `traefik_service_requests_total` | Counter | Requêtes par service |
| `traefik_service_request_duration_seconds` | Histogram | Latence par service |

## Exercices pratiques

### Exercice 1 : Créer une alerte
Dans Grafana, créez une alerte qui se déclenche si la latence p95 dépasse 500ms.

### Exercice 2 : Dashboard custom
Créez un dashboard avec :
- Le nombre de requêtes 200 vs 4xx vs 5xx
- Le temps de réponse moyen par service

### Exercice 3 : Ajouter cAdvisor
Ajoutez le conteneur `gcr.io/cadvisor/cadvisor` pour monitorer les ressources Docker (CPU, RAM).

## Bonnes pratiques

1. **Nommez vos métriques clairement** : `service_requests_total` pas `req`
2. **Utilisez les labels avec parcimonie** : Trop de labels = explosion de la cardinalité
3. **Définissez des dashboards par équipe/service**
4. **Créez des alertes** : Le monitoring sans alertes ne sert à rien

## Ressources

- 📖 [Prometheus Documentation](https://prometheus.io/docs/)
- 📖 [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- 📖 [Grafana Documentation](https://grafana.com/docs/)
- 🎓 [Prometheus Best Practices](https://prometheus.io/docs/practices/naming/)
