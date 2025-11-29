# ============================================================================
# TERRAFORM - VARIABLES
# ============================================================================
# Les variables permettent de rendre la configuration réutilisable.
# On peut les surcharger via :
# - Un fichier terraform.tfvars
# - La ligne de commande : terraform apply -var="consul_address=..."
# - Des variables d'environnement : TF_VAR_consul_address=...
#
# 📚 Concepts clés :
# - variable {} : Déclare une variable d'entrée
# - type : Le type de données (string, number, bool, list, map, object)
# - default : Valeur par défaut si non fournie
# - description : Documentation de la variable
# ============================================================================

# ----------------------------------------------------------------------------
# Variables Consul
# ----------------------------------------------------------------------------

variable "consul_address" {
  description = "Adresse de l'API Consul (host:port)"
  type        = string
  default     = "localhost:8500"

  # 💡 En production, on mettrait l'adresse du cluster Consul
  # Exemple : "consul.example.com:8500"
}

variable "consul_datacenter" {
  description = "Nom du datacenter Consul"
  type        = string
  default     = "dc1"

  # 💡 Consul organise les services par datacenter
  # Utile pour le multi-région
}

# ----------------------------------------------------------------------------
# Variables pour les services
# ----------------------------------------------------------------------------

variable "nginx_port" {
  description = "Port sur lequel Nginx écoute dans le conteneur"
  type        = number
  default     = 80
}

variable "nginx_address" {
  description = "Adresse/hostname du service Nginx (nom du conteneur Docker)"
  type        = string
  default     = "nginx"

  # 💡 Dans Docker, les conteneurs se parlent via leur nom
  # "nginx" est résolu par le DNS interne de Docker
}

variable "traefik_domain" {
  description = "Domaine pour accéder à Nginx via Traefik"
  type        = string
  default     = "nginx.localhost"

  # 💡 Traefik route les requêtes selon le Host header
  # curl -H "Host: nginx.localhost" http://localhost
}
