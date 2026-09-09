# Ansible

## C'est quoi ?

Outil d'automatisation : exécute des tâches sur des machines (ou en local).

## Structure

```
ansible/
├── ansible.cfg       # Configuration globale
├── inventory.yml     # Liste des machines cibles
└── playbooks/
    └── *.yml         # Les playbooks (séquences de tâches)
```

## Playbook - Structure

```yaml
---
- name: Nom du playbook
  hosts: localhost          # Cibles
  vars:
    ma_variable: "valeur"
  
  tasks:
    - name: Description de la tâche
      ansible.builtin.module:
        param1: valeur
        param2: "{{ ma_variable }}"
```

## Modules utiles

| Module | Usage |
|--------|-------|
| `uri` | Appels HTTP (API REST) |
| `copy` | Copier des fichiers |
| `template` | Générer des fichiers depuis templates Jinja2 |
| `command` | Exécuter une commande |
| `debug` | Afficher des infos |

## Commandes

```bash
# Vérifier la syntaxe
ansible-playbook playbook.yml --syntax-check

# Exécuter
ansible-playbook playbook.yml

# Mode verbose
ansible-playbook playbook.yml -v

# Dry-run (sans appliquer)
ansible-playbook playbook.yml --check
```

## Idempotence

L'idempotence dépend des modules et des conditions du playbook. Ici, un ID
stable évite de créer des doublons. Le PUT est rejoué avec remplacement des
checks pour garantir leur définition : l'API de lecture ne restitue pas leur
URL HTTP dans la version testée. Le bilan affiche donc volontairement
`changed=1`, même au deuxième passage. L'état final est stable, mais ce n'est
pas une exécution sans écriture.

Le module `uri` ne simule pas les appels HTTP en mode `--check` : ce mode
ne remplace ni `--syntax-check` ni une exécution contrôlée du labo.
