# Validation du 9 septembre 2026

Contrôles effectués sur macOS avec Docker Compose. Les deux parcours ont été
testés séparément après `make down` puis `make up`, sans supprimer les volumes.

| Contrôle | Terraform | Ansible |
| --- | --- | --- |
| Route Nginx via Traefik | HTTP 200 | HTTP 200 |
| Une seule instance enregistrée | Validé | Validé |
| Check Consul artificiel absent | Validé : aucun check sur le nœud catalogue | Contrôle HTTP réel de l'agent |
| Prometheus collecte Traefik | `up=1` | `up=1` |
| Nouvelle requête Nginx retrouvée dans Loki via Alloy | Validé | Validé |
| Arrêt de Nginx détecté | Backend retiré, HTTP 503 | Backend retiré et check Consul `critical` |
| Retour après redémarrage | HTTP 200 sans réenregistrement | HTTP 200 sans réenregistrement |

`make verify` passe : Compose, format/validation Terraform et syntaxe Ansible.
Le second plan Terraform retourne « No changes ». Le playbook Ansible utilise
un ID stable, sans doublon, mais rejoue volontairement le PUT (`changed=1`) pour
garantir la définition du check. Voir [Ansible](04-ansible.md).

Le garde-fou refuse le parcours Terraform lorsqu'un enregistrement Ansible est
actif. Les commandes Make imposent de repartir d'un catalogue vide pour basculer.

## Régression corrigée

Avant correction, l'arrêt de Nginx laissait un check de catalogue `passing`
et produisait un 502 persistant. `python3 tests/live.py --outage` échouait,
puis redémarrait bien Nginx dans son bloc de récupération.

Le check déclaratif a été supprimé. Des tags Consul configurent désormais un
contrôle HTTP actif du backend dans Traefik. Le même test passe ensuite, y
compris après recréation de la stack. L'API catalogue ne lance pas de check :
[documentation Consul](https://developer.hashicorp.com/consul/api-docs/catalog).

Un ancien check peut rester dans le catalogue après un simple `terraform apply`.
Le parcours de migration documenté recrée le Consul de développement avant
l'enregistrement. Aucune donnée de production n'est concernée.

## Limites

- Ces résultats sont un contrôle local, pas une qualification de production.
- La CI Linux exécute les mêmes tests sur chaque parcours ; son résultat est
  consultable dans l'onglet Actions, séparément de cette preuve locale.
- Les tests de panne arrêtent brièvement Nginx. Ne pas les lancer pendant une
  démonstration sans prévenir.
- Les scans de signatures de secrets n'ont rien détecté dans les quatre
  commits historiques ni dans les fichiers proposés. Ils ne sont pas exhaustifs.
- Aucune implication du VPN dans les anciens échecs n'a été démontrée.
