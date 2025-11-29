# ============================================================================
# TERRAFORM - ENREGISTREMENT DES SERVICES DANS CONSUL
# ============================================================================
# Ce fichier déclare les services à enregistrer dans Consul.
# C'est l'équivalent Terraform du playbook Ansible register-services.yml
#
# 📚 Concepts clés :
# - resource : Crée/modifie/supprime une ressource
# - La syntaxe : resource "TYPE" "NOM_LOCAL" { ... }
# - TYPE = type de ressource du provider (consul_service, aws_instance, etc.)
# - NOM_LOCAL = identifiant unique dans votre code Terraform
#
# 🔄 Différence avec Ansible :
# - Ansible : "Exécute PUT /v1/agent/service/register avec ce JSON"
# - Terraform : "Je veux ce service, gère la création/mise à jour/suppression"
#
# 💡 Note technique :
# On utilise "consul_catalog_entry" car nos conteneurs Docker n'ont pas
# d'agent Consul installé. Cette ressource permet d'enregistrer des services
# "externes" directement dans le catalogue Consul.
# ============================================================================

# ----------------------------------------------------------------------------
# Service Nginx
# ----------------------------------------------------------------------------
# Cette ressource enregistre Nginx dans le catalogue de services Consul
# Traefik découvrira automatiquement ce service grâce aux tags

resource "consul_catalog_entry" "nginx" {
  # Nom du node dans le catalogue Consul
  # (on crée un node virtuel pour représenter notre conteneur)
  node = "nginx-node"

  # Adresse du node
  address = "nginx"

  # Définition du service
  service {
    # Nom du service dans Consul (visible dans l'UI Consul)
    name = "nginx"

    # Adresse où le service est joignable
    # "nginx" = nom du conteneur Docker (résolu par DNS Docker)
    address = var.nginx_address

    # Port d'écoute du service
    port = var.nginx_port

    # Tags - Configuration pour Traefik
    # Traefik les lit pour savoir comment router le trafic
    tags = [
      "traefik.enable=true",
      "traefik.http.routers.nginx.rule=Host(`${var.traefik_domain}`)",
      "traefik.http.routers.nginx.entrypoints=web",
    ]
  }
}

# ============================================================================
# 💡 EXERCICE : Ajouter un nouveau service
# ============================================================================
# Essayez d'ajouter un service "whoami" (image traefik/whoami)
# 1. Ajoutez-le dans docker-compose.yml
# 2. Créez une resource "consul_catalog_entry" "whoami" ci-dessous
# 3. Lancez "terraform apply" pour l'enregistrer
#
# resource "consul_catalog_entry" "whoami" {
#   node    = "whoami-node"
#   address = "whoami"
#
#   service {
#     name    = "whoami"
#     address = "whoami"
#     port    = 80
#     tags = [
#       "traefik.enable=true",
#       "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)",
#       "traefik.http.routers.whoami.entrypoints=web",
#     ]
#   }
# }
# ============================================================================
