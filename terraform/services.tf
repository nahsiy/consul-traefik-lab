# Le service Nginx ne possède pas d'agent Consul local. Terraform crée donc un
# nœud de catalogue, puis rattache le service externe à ce nœud.
resource "consul_node" "nginx" {
  name    = "nginx-node"
  address = var.nginx_address
}

resource "consul_service" "nginx" {
  name       = "nginx"
  service_id = "nginx-lab"
  node       = consul_node.nginx.name
  address    = var.nginx_address
  port       = var.nginx_port

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.nginx.rule=Host(`${var.traefik_domain}`)",
    "traefik.http.routers.nginx.entrypoints=web",
    "traefik.http.routers.nginx.service=nginx",
    "traefik.http.services.nginx.loadbalancer.healthcheck.path=/",
    "traefik.http.services.nginx.loadbalancer.healthcheck.interval=5s",
    "traefik.http.services.nginx.loadbalancer.healthcheck.timeout=2s",
  ]
  # Le catalogue ne lance aucun check. Traefik contrôle activement le backend.
}
