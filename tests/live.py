"""Live checks for this local lab only. --outage briefly stops its Nginx."""
import argparse
import json
from pathlib import Path
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
HTTP = urllib.request.build_opener(urllib.request.ProxyHandler({}))
COMPOSE = ["docker", "compose", "-f", str(ROOT / "docker/docker-compose.yml")]


def request(port, path="/", host=None):
    req = urllib.request.Request(f"http://127.0.0.1:{port}{path}")
    if host:
        req.add_header("Host", host)
    try:
        with HTTP.open(req, timeout=3) as response:
            return response.status, response.read().decode()
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode()


def api(port, path):
    status, body = request(port, path)
    assert status == 200, (port, path, status)
    return json.loads(body)


def wait(label, predicate, timeout=60):
    deadline = time.monotonic() + timeout
    last = None
    while time.monotonic() < deadline:
        try:
            last = predicate()
            if last:
                print(f"PASS {label}", flush=True)
                return
        except (OSError, ValueError, AssertionError) as error:
            last = str(error)
        time.sleep(1)
    raise AssertionError(f"{label}: timeout ({last})")


def route_ok():
    status, body = request(8088, host="nginx.localhost")
    return status == 200 and "Consul-Traefik Lab" in body


def registered(mode):
    services = api(8500, "/v1/health/service/nginx")
    if len(services) != 1:
        return False
    checks = services[0]["Checks"]
    if mode == "terraform":
        # Catalog registration alone must not pretend to run an HTTP check.
        return not checks
    return any(c["ServiceID"] == "nginx-lab" and c["Status"] == "passing"
               for c in checks)


def smoke(mode):
    for port, path in [(8500, "/v1/status/leader"), (9090, "/-/ready"),
                       (3100, "/ready"), (3000, "/api/health"), (12345, "/-/ready")]:
        wait(f"ready {port}", lambda: request(port, path)[0] == 200)
    wait("route Nginx HTTP 200", route_ok)
    wait(f"unique registration and honest health ({mode})", lambda: registered(mode))
    wait("Traefik scraped by Prometheus", lambda: any(
        item["value"][1] == "1" for item in api(
            9090, "/api/v1/query?" + urllib.parse.urlencode({"query": 'up{job="traefik"}'}))
        ["data"]["result"]))
    token = f"lab-smoke-{time.time_ns()}"
    assert request(8088, f"/?{token}", "nginx.localhost")[0] == 200
    query = urllib.parse.urlencode({
        "query": '{compose_project="consul-traefik-lab",service="nginx"} |= "' + token + '"',
        "since": "5m", "limit": 10,
    })
    wait("fresh Nginx request collected by Alloy into Loki", lambda: bool(
        api(3100, "/loki/api/v1/query_range?" + query)["data"]["result"]))


def outage(mode):
    wait("Nginx healthy before outage", route_ok)
    try:
        subprocess.run(COMPOSE + ["stop", "nginx"], check=True, timeout=30)
        expected = (503,) if mode == "terraform" else (503, 404)
        wait(f"failed backend removed (HTTP {expected})", lambda:
             request(8088, host="nginx.localhost")[0] in expected, timeout=35)
        if mode == "ansible":
            wait("Consul agent detects HTTP failure", lambda: any(
                c["ServiceID"] == "nginx-lab" and c["Status"] == "critical"
                for item in api(8500, "/v1/health/service/nginx") for c in item["Checks"]))
    finally:
        subprocess.run(COMPOSE + ["start", "nginx"], check=True, timeout=30)
        wait("Nginx route recovers automatically", route_ok)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registration", choices=["terraform", "ansible"], default="terraform")
    parser.add_argument("--outage", action="store_true")
    parser.add_argument("--guard", action="store_true", help="Reject mixed registration modes")
    args = parser.parse_args()
    if args.guard:
        services = api(8500, "/v1/catalog/service/nginx")
        assert all((s["Node"] == "nginx-node") == (args.registration == "terraform")
                   for s in services), "Other registration active: run make down then make up first"
    elif args.outage:
        outage(args.registration)
    else:
        smoke(args.registration)
