# 📝 Loki - Logs Centralisés

## C'est quoi Loki ?

**Loki** est un système d'agrégation de logs créé par Grafana Labs.
C'est comme Prometheus, mais pour les **logs** au lieu des métriques.

### Pourquoi Loki ?

| Avant (sans Loki) | Après (avec Loki) |
|-------------------|-------------------|
| `docker logs nginx` | Tout dans Grafana |
| `docker logs traefik` | Recherche unifiée |
| Se connecter à chaque serveur | Un seul endroit |
| Pas d'historique | Rétention configurable |

## Architecture

```
┌─────────────┐
│   Nginx     │──┐
└─────────────┘  │
┌─────────────┐  │    ┌─────────────┐    ┌─────────────┐
│   Traefik   │──┼───►│    Alloy    │───►│    Loki     │
└─────────────┘  │    │ (collecteur)│    │  (stockage) │
┌─────────────┐  │    └─────────────┘    └──────┬──────┘
│   Consul    │──┘                              │
└─────────────┘                                 ▼
                                         ┌─────────────┐
                                         │   Grafana   │
                                         │  (explore)  │
                                         └─────────────┘
```

### Les composants

| Composant | Rôle | Équivalent Prometheus |
|-----------|------|----------------------|
| **Grafana Alloy** | Collecte et traite les logs | Agent de collecte |
| **Loki** | Stocke et indexe | Prometheus server |
| **Grafana** | Visualise | Grafana |

## Explorer les logs dans Grafana

### Accès
1. Ouvrir http://localhost:3000
2. Menu gauche → **Explore** (icône boussole)
3. En haut, sélectionner **Loki** comme datasource

### Syntaxe LogQL

LogQL est le langage de requête de Loki (comme PromQL pour Prometheus).

#### Requêtes de base

```logql
# Tous les logs de Nginx
{service="nginx"}

# Tous les logs de Traefik
{service="traefik"}

# Logs de plusieurs services
{service=~"nginx|traefik"}

# Tous les logs du projet
{compose_project="consul-traefik-lab"}
```

#### Filtrer le contenu

```logql
# Logs Nginx contenant "error"
{service="nginx"} |= "error"

# Logs Traefik contenant "404"
{service="traefik"} |= "404"

# Logs qui NE contiennent PAS "health"
{service="traefik"} != "health"

# Regex : lignes avec un code 4xx ou 5xx
{service="traefik"} |~ "HTTP/[12].[01]\" [45][0-9]{2}"
```

#### Opérateurs de filtrage

| Opérateur | Description | Exemple |
|-----------|-------------|---------|
| `\|=` | Contient | `{service="nginx"} \|= "error"` |
| `!=` | Ne contient pas | `{service="nginx"} != "GET"` |
| `\|~` | Regex match | `{service="nginx"} \|~ "error\|warn"` |
| `!~` | Regex not match | `{service="nginx"} !~ "health"` |

### Exemples pratiques

```logql
# Erreurs HTTP dans Traefik
{service="traefik"} |= "error" or {service="traefik"} |~ "\"[45][0-9]{2}\""

# Logs Consul sans les health checks
{service="consul"} != "health"

# Tous les logs des 5 dernières minutes avec "fail"
{compose_project="consul-traefik-lab"} |= "fail"
```

## Configuration

### Grafana Alloy (collecteur)
Fichier : `docker/alloy/config.alloy`

Alloy découvre les conteneurs du projet Compose, lit leurs logs via le socket
Docker, extrait leurs métadonnées et les transmet à Loki.

### Loki (stockage)
Fichier : `docker/loki/loki-config.yml`

Configuration du stockage et de l'indexation des logs.

## Comparer avec docker logs

### Avant
```bash
# Voir les logs d'un conteneur
docker logs consul-traefik-lab-nginx-1

# Suivre en temps réel
docker logs -f consul-traefik-lab-nginx-1

# Filtrer (limité)
docker logs consul-traefik-lab-nginx-1 2>&1 | grep error
```

### Avec Loki + Grafana
- Interface graphique
- Recherche sur tous les conteneurs en même temps
- Filtres puissants avec LogQL
- Historique persistant
- Corrélation avec les métriques

## Cas d'usage

### 1. Debug d'une erreur
```logql
# Chercher les erreurs dans tous les services
{compose_project="consul-traefik-lab"} |~ "(?i)error"
```

### 2. Analyser le trafic
```logql
# Requêtes HTTP vers Traefik
{service="traefik"} |= "GET" or {service="traefik"} |= "POST"
```

### 3. Surveiller un déploiement
```logql
# Logs des 5 dernières minutes
{compose_project="consul-traefik-lab"}
```
Puis dans Grafana, ajuster la plage de temps en haut à droite.

## Exercices

### Exercice 1 : Trouver les 404
Cherchez toutes les requêtes qui ont retourné un code 404.

<details>
<summary>Solution</summary>

```logql
{service="traefik"} |~ "\" 404 "
```
</details>

### Exercice 2 : Logs d'un conteneur spécifique
Affichez uniquement les logs du conteneur Consul.

<details>
<summary>Solution</summary>

```logql
{service="consul"}
```
</details>

### Exercice 3 : Exclure les health checks
Affichez les logs Traefik sans les lignes de health check.

<details>
<summary>Solution</summary>

```logql
{service="traefik"} != "health" != "/ping"
```
</details>

## Bonnes pratiques

1. **Utilisez des labels** : Filtrer par service est plus performant que chercher dans le contenu
2. **Évitez les regex complexes** : Préférez `|=` à `|~` quand possible
3. **Limitez la plage de temps** : Moins de données = requêtes plus rapides
4. **Créez des dashboards** : Pour les requêtes fréquentes

## Ressources

- 📖 [Loki Documentation](https://grafana.com/docs/loki/latest/)
- 📖 [LogQL Documentation](https://grafana.com/docs/loki/latest/logql/)
- 📖 [Collecte Docker avec Alloy](https://grafana.com/docs/alloy/latest/reference/components/loki/loki.source.docker/)
