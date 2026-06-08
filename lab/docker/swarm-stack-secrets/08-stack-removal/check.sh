#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Ошибка: $*" >&2; exit 1; }
if docker stack ls --format '{{.Name}}' | grep -qx shop; then fail "stack shop ещё существует"; fi
[ -z "$(docker service ls --filter label=com.docker.stack.namespace=shop -q)" ] || fail "остались services stack shop"
[ -z "$(docker network ls --filter label=com.docker.stack.namespace=shop -q)" ] || fail "осталась stack-сеть"
if docker volume inspect shop_db_data >/dev/null 2>&1; then fail "volume shop_db_data не удалён"; fi
if docker secret ls --format '{{.Name}}' | grep -q '^shop_'; then fail "остались secrets с префиксом shop_"; fi
if docker config ls --format '{{.Name}}' | grep -q '^shop_'; then fail "остались configs с префиксом shop_"; fi
if curl -fsS --max-time 2 http://127.0.0.1:8080/health >/dev/null 2>&1; then fail "порт 8080 всё ещё обслуживает приложение"; fi
[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = active ] || fail "Swarm не должен быть выключен"
echo "Stack и лабораторные ресурсы удалены"
