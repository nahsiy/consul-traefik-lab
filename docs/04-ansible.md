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

Ansible est **idempotent** : relancer un playbook ne change rien si l'état est déjà correct.
