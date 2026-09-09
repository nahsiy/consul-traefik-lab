COMPOSE_FILE := docker/docker-compose.yml
REGISTRATION ?= terraform

.PHONY: up down logs register-terraform register-ansible verify smoke test-outage

up:
	docker compose -f $(COMPOSE_FILE) up -d --wait --wait-timeout 120

down:
	docker compose -f $(COMPOSE_FILE) down

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

register-terraform:
	python3 tests/live.py --guard --registration terraform
	terraform -chdir=terraform init
	terraform -chdir=terraform apply

register-ansible:
	python3 tests/live.py --guard --registration ansible
	ansible-playbook -i ansible/inventory.yml ansible/playbooks/register-services.yml

verify:
	docker compose -f $(COMPOSE_FILE) config --quiet
	terraform -chdir=terraform fmt -check -recursive
	terraform -chdir=terraform init -backend=false
	terraform -chdir=terraform validate
	ansible-playbook -i ansible/inventory.yml --syntax-check ansible/playbooks/register-services.yml

smoke:
	python3 tests/live.py --registration $(REGISTRATION)

test-outage:
	python3 tests/live.py --registration $(REGISTRATION) --outage
