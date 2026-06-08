#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Ошибка: $*" >&2; exit 1; }
docker stack ls --format '{{.Name}}' | grep -qx shop || fail "stack shop не развёрнут"
for service in web api db; do
  name="shop_$service"
  docker service inspect "$name" >/dev/null 2>&1 || fail "нет service $name"
  [ "$(docker service inspect "$name" --format '{{.Spec.Mode.Replicated.Replicas}}')" = 1 ] || fail "$name: desired replicas не равно 1"
  [ "$(docker service ls --filter name="${name}" --format '{{.Replicas}}')" = '1/1' ] || fail "$name не достиг 1/1"
  docker service ps "$name" --filter desired-state=running --format '{{.CurrentState}}' | grep -q '^Running' || fail "$name не имеет running task"
done
network=$(docker network ls --filter label=com.docker.stack.namespace=shop --filter driver=overlay -q)
[ -n "$network" ] || fail "нет stack overlay-сети"
[ "$(docker service inspect shop_api --format '{{range .Spec.TaskTemplate.ContainerSpec.Secrets}}{{println .SecretName}}{{end}}')" = 'shop_db_password_v1' ] || fail "secret не подключён к api"
docker service inspect shop_web --format '{{range .Spec.TaskTemplate.ContainerSpec.Configs}}{{println .ConfigName}}{{end}}' | grep -qx shop_nginx_v1 || fail "nginx config не подключён к web"
docker service inspect shop_api --format '{{range .Spec.TaskTemplate.ContainerSpec.Configs}}{{println .ConfigName}}{{end}}' | grep -qx shop_api_config_v1 || fail "API config не подключён к api"
for service in web api db; do
  cid=$(docker ps --filter label=com.docker.swarm.service.name="shop_$service" --format '{{.ID}}' | head -n 1)
  [ -n "$cid" ] || fail "не найден container shop_$service"
  health=$(docker inspect "$cid" --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}')
  [ "$health" = healthy ] || fail "shop_$service health=$health"
done
curl -fsS http://127.0.0.1:8080/health | grep -q '"status":"ok"' || fail "web health endpoint недоступен"
echo "Stack shop работает"
