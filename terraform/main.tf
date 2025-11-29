# ============================================================================
# TERRAFORM - FICHIER PRINCIPAL
# ============================================================================
# Ce fichier configure Terraform et déclare les providers (plugins) nécessaires.
#
# 📚 Concepts clés :
# - terraform {} : Configuration de Terraform lui-même
# - required_providers : Les plugins dont on a besoin
# - provider {} : Configuration de connexion au service externe
# ============================================================================

# ----------------------------------------------------------------------------
# Configuration Terraform
# ----------------------------------------------------------------------------
# Cette section définit :
# - La version minimum de Terraform requise
# - Les providers (plugins) à télécharger
terraform {
  # Version minimum de Terraform (optionnel mais recommandé)
  required_version = ">= 1.0.0"

  # Déclaration des providers nécessaires
  # Terraform va les télécharger automatiquement avec "terraform init"
  required_providers {
    # Provider Consul - permet d'interagir avec l'API Consul
    consul = {
      source  = "hashicorp/consul"  # Editeur/nom du provider
      version = "~> 2.20"           # Version compatible (>= 2.20.0, < 3.0.0)
    }
  }
}

# ----------------------------------------------------------------------------
# Configuration du Provider Consul
# ----------------------------------------------------------------------------
# Ici on dit à Terraform COMMENT se connecter à Consul
# C'est comme une "connexion à la base de données" pour Terraform
provider "consul" {
  # Adresse de l'API Consul (notre conteneur Docker)
  address = var.consul_address

  # Datacenter Consul (par défaut "dc1" en mode dev)
  datacenter = var.consul_datacenter

  # Pas de token car Consul tourne sans ACL dans notre lab
  # En production, on ajouterait : token = var.consul_token
}
