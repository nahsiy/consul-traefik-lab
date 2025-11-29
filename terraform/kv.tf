# ============================================================================
# TERRAFORM - KEY/VALUE STORE CONSUL
# ============================================================================
# Consul possède un Key/Value store distribué, comme un petit Redis intégré.
# Utile pour stocker des configurations partagées entre services.
#
# 📚 Concepts clés :
# - consul_keys : Gère plusieurs clés K/V en une ressource
# - consul_key_prefix : Gère un préfixe entier (comme un dossier)
#
# 🎯 Cas d'usage réels :
# - Feature flags (activer/désactiver des fonctionnalités)
# - Configuration dynamique (URLs, timeouts, etc.)
# - Coordination entre services
# ============================================================================

# ----------------------------------------------------------------------------
# Configuration globale de l'application
# ----------------------------------------------------------------------------
# On stocke des valeurs de configuration que nos services peuvent lire

resource "consul_keys" "app_config" {
  # Chaque bloc "key" définit une paire clé/valeur

  # Configuration de l'environnement
  key {
    path  = "config/environment"
    value = "development"
    # 💡 Vos apps peuvent lire cette valeur pour adapter leur comportement
  }

  # Version de l'application (exemple de feature flag)
  key {
    path  = "config/app/version"
    value = "1.0.0"
  }

  # Configuration de log level
  key {
    path  = "config/log_level"
    value = "debug"
    # 💡 En prod, on mettrait "info" ou "warn"
  }
}

# ----------------------------------------------------------------------------
# Configuration spécifique à Nginx
# ----------------------------------------------------------------------------
resource "consul_keys" "nginx_config" {
  key {
    path  = "services/nginx/max_connections"
    value = "1000"
  }

  key {
    path  = "services/nginx/timeout"
    value = "30s"
  }
}

# ============================================================================
# 💡 EXERCICE : Ajouter vos propres configurations
# ============================================================================
# 1. Ajoutez une clé "config/feature_flags/dark_mode" avec valeur "true"
# 2. Lancez "terraform apply"
# 3. Vérifiez dans Consul UI : http://localhost:8500/ui/dc1/kv
#
# Vous pouvez aussi lire ces valeurs depuis vos apps :
# curl http://localhost:8500/v1/kv/config/environment?raw
# ============================================================================
