# ============================================================================
# TERRAFORM - OUTPUTS
# ============================================================================
# Les outputs affichent des informations après "terraform apply".
# Utiles pour :
# - Voir des valeurs calculées
# - Passer des infos à d'autres modules/outils
# - Documenter ce qui a été créé
#
# 📚 Concepts clés :
# - output {} : Déclare une sortie
# - value : La valeur à afficher (peut référencer des ressources)
# - description : Documentation
# ============================================================================

# ----------------------------------------------------------------------------
# Informations sur le service Nginx
# ----------------------------------------------------------------------------

output "nginx_node" {
  description = "Node du service Nginx dans Consul"
  value       = consul_catalog_entry.nginx.node

  # 💡 Vérifiez dans l'UI Consul : http://localhost:8500/ui/dc1/nodes
}

output "nginx_url" {
  description = "URL pour accéder à Nginx via Traefik"
  value       = "http://${var.traefik_domain}"

  # 💡 N'oubliez pas d'ajouter nginx.localhost à /etc/hosts
  # ou utilisez : curl -H "Host: nginx.localhost" http://localhost
}

# ----------------------------------------------------------------------------
# Informations Consul
# ----------------------------------------------------------------------------

output "consul_ui_url" {
  description = "URL de l'interface Consul"
  value       = "http://${var.consul_address}/ui"
}

output "consul_services_url" {
  description = "URL pour lister les services via API"
  value       = "http://${var.consul_address}/v1/catalog/services"

  # 💡 Essayez : curl http://localhost:8500/v1/catalog/services | jq
}

output "consul_kv_url" {
  description = "URL pour accéder au Key/Value store"
  value       = "http://${var.consul_address}/v1/kv/?recurse"

  # 💡 Essayez : curl http://localhost:8500/v1/kv/?recurse | jq
}

# ============================================================================
# 💡 À SAVOIR
# ============================================================================
# Après "terraform apply", vous verrez ces outputs affichés.
# Pour les revoir plus tard : terraform output
# Pour un output spécifique : terraform output nginx_url
# En JSON (pour scripts) : terraform output -json
# ============================================================================
