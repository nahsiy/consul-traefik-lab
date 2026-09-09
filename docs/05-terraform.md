# 🏗️ Terraform - Infrastructure as Code

## C'est quoi Terraform ?

Terraform est un outil d'**Infrastructure as Code (IaC)** créé par HashiCorp (les mêmes que Consul !).

**L'idée** : Décrire l'état souhaité de votre infrastructure dans des fichiers, et Terraform se charge de créer/modifier/supprimer les ressources pour atteindre cet état.

## Terraform vs Ansible

| Aspect | Ansible | Terraform |
|--------|---------|-----------|
| **Approche** | Procédurale (étapes) | Déclarative (état final) |
| **Question posée** | "Quelles actions exécuter ?" | "Quel état je veux ?" |
| **Idempotence** | À gérer soi-même | Automatique |
| **State** | Aucun | Fichier terraform.tfstate |
| **Retour arrière** | Rejouer une configuration adaptée | Revenir au code voulu puis examiner un nouveau plan ; restaurer le state seul ne restaure pas l'infrastructure |
| **Force** | Config serveurs | Création d'infra |

### Exemple concret

**Ansible** (procédural) :
```yaml
- name: Créer un utilisateur
  user:
    name: bob
    state: present    # Si on relance, Ansible vérifie et ne fait rien
```

**Terraform** (déclaratif) :
```hcl
resource "consul_service" "nginx" {
  name = "nginx"
  node = consul_node.nginx.name
  port = 80
}
# Extrait : consul_node.nginx est déclaré dans terraform/services.tf.
# Terraform compare la configuration, son state et l'état distant.
```

## Concepts fondamentaux

### 1. Provider
Un **provider** est un plugin qui permet à Terraform de parler à un service externe.

```hcl
# Exemple : Provider Consul
provider "consul" {
  address = "localhost:8500"
}

# Exemple : Provider AWS
provider "aws" {
  region = "eu-west-1"
}
```

📦 Il existe des providers pour : AWS, GCP, Azure, Kubernetes, Docker, GitHub, Datadog, etc.

### 2. Resource
Une **resource** est quelque chose que Terraform gère (crée, met à jour, supprime).

```hcl
resource "TYPE" "NOM_LOCAL" {
  # Configuration
}
```

- `TYPE` : Type de ressource du provider (consul_service, aws_instance, etc.)
- `NOM_LOCAL` : Identifiant unique dans VOTRE code (pas dans le service distant)

### 3. State (État)
Le **state** est un fichier JSON (`terraform.tfstate`) qui stocke :
- Ce que Terraform a créé
- Les correspondances entre votre code et les ressources réelles

⚠️ **Important** : Ne jamais modifier ce fichier à la main !

### 4. Variables
Les **variables** rendent votre code réutilisable :

```hcl
# Déclaration (variables.tf)
variable "environment" {
  type    = string
  default = "dev"
}

# Utilisation
resource "consul_keys" "config" {
  key {
    path  = "config/env"
    value = var.environment    # 👈 Référence à la variable
  }
}
```

### 5. Outputs
Les **outputs** affichent des informations après l'exécution :

```hcl
output "service_url" {
  value = "http://localhost:8500/v1/catalog/service/${consul_service.nginx.name}"
}
```

## Commandes essentielles

```bash
# 1️⃣ Initialiser Terraform (télécharge les providers)
terraform init

# 2️⃣ Voir ce que Terraform VA FAIRE (preview)
terraform plan

# 3️⃣ Appliquer les changements
terraform apply

# 4️⃣ Voir l'état actuel
terraform show

# 5️⃣ Détruire toute l'infrastructure
terraform destroy

# 6️⃣ Formater le code proprement
terraform fmt

# 7️⃣ Valider la syntaxe
terraform validate
```

## Workflow type

```
┌─────────────────────────────────────────────────────────────┐
│                     terraform init                          │
│              (Télécharge les providers)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     terraform plan                          │
│         (Compare le code avec l'état actuel)                │
│                                                             │
│   + consul_service.nginx will be created                    │
│   ~ consul_keys.config will be updated                      │
│   - consul_service.old will be destroyed                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    terraform apply                          │
│            (Applique les changements)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   terraform.tfstate                         │
│        (Sauvegarde l'état pour la prochaine fois)          │
└─────────────────────────────────────────────────────────────┘
```

## Exercice pratique

### Étape 1 : Initialiser
```bash
cd terraform
terraform init
```

Vous devriez voir :
```
Initializing provider plugins...
- Finding hashicorp/consul versions matching "~> 2.20"...
- Installing hashicorp/consul v2.20.0...
```

### Étape 2 : Voir le plan
```bash
terraform plan
```

Lisez attentivement :
- `+` = sera créé
- `~` = sera modifié
- `-` = sera supprimé

### Étape 3 : Appliquer
```bash
terraform apply
```

Tapez `yes` pour confirmer.

### Étape 4 : Vérifier dans Consul
- UI : http://localhost:8500/ui/dc1/services
- API : `curl http://localhost:8500/v1/catalog/services | jq`

### Étape 5 : Modifier quelque chose
Changez une valeur dans `services.tf` et relancez `terraform apply`.
Observez que Terraform ne recrée pas tout, il met à jour seulement ce qui a changé.

## Le fichier State

Après `terraform apply`, vous aurez un fichier `terraform.tfstate` :

```json
{
  "version": 4,
  "resources": [
    {
      "type": "consul_service",
      "name": "nginx",
      "instances": [
        {
          "attributes": {
            "name": "nginx",
            "port": 80,
            ...
          }
        }
      ]
    }
  ]
}
```

⚠️ **En équipe** : Ce fichier doit être partagé (Terraform Cloud, S3, etc.)
Pour ce lab local, il reste dans le dossier.

## Terraform vs notre Playbook Ansible

### Avant (Ansible)
```yaml
- name: Enregistrer nginx dans Consul
  ansible.builtin.uri:
    url: "{{ consul_url }}/v1/agent/service/register"
    method: PUT
    body:
      Name: "nginx"
      Port: 80
      ...
```

### Maintenant (Terraform)
```hcl
resource "consul_service" "nginx" {
  name = "nginx"
  port = 80
  ...
}
```

**Avantages de Terraform ici** :
1. Si vous changez le port, `terraform apply` met à jour (pas besoin de désenregistrer/réenregistrer)
2. Si vous supprimez la resource, `terraform apply` désenregistre automatiquement
3. L'état est tracké : vous savez toujours ce qui existe

## Bonnes pratiques

### Structure de fichiers
```
terraform/
├── main.tf          # Providers et config de base
├── variables.tf     # Déclaration des variables
├── outputs.tf       # Valeurs de sortie
├── services.tf      # Resources (groupées par domaine)
├── kv.tf            # Autre groupe de resources
└── terraform.tfvars # Valeurs des variables (optionnel)
```

### Nommage
```hcl
# ✅ Bon : noms descriptifs en snake_case
resource "consul_service" "nginx_web_server" { }

# ❌ Mauvais : noms génériques
resource "consul_service" "service1" { }
```

### Commentaires
```hcl
# Utilisez des commentaires pour expliquer le POURQUOI
# Le code explique le QUOI

# Ce service est exposé publiquement via Traefik
# pour permettre l'accès externe à l'application
resource "consul_service" "nginx" {
  ...
}
```

## Ressources pour aller plus loin

- 📖 [Documentation officielle](https://developer.hashicorp.com/terraform/docs)
- 🎓 [Learn Terraform](https://developer.hashicorp.com/terraform/tutorials)
- 📦 [Registry des providers](https://registry.terraform.io/browse/providers)
- 📦 [Provider Consul](https://registry.terraform.io/providers/hashicorp/consul/latest/docs)
