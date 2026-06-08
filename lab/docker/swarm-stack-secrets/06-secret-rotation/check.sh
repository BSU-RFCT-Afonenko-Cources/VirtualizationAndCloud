#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "Ошибка: $*" >&2; exit 1; }
docker secret inspect shop_db_password_v2 >/dev/null 2>&1 || fail "нет secret shop_db_password_v2"
if docker secret inspect shop_db_password_v1 >/dev/null 2>&1; then fail "старый secret shop_db_password_v1 не удалён"; fi
docker config inspect shop_api_config_v2 >/dev/null 2>&1 || fail "нет config shop_api_config_v2"
if docker config inspect shop_api_config_v1 >/dev/null 2>&1; then fail "старый config shop_api_config_v1 не удалён"; fi
api_secrets=$(docker service inspect shop_api --format '{{range .Spec.TaskTemplate.ContainerSpec.Secrets}}{{println .SecretName}}{{end}}')
printf '%s\n' "$api_secrets" | grep -qx shop_db_password_v2 || fail "api не переключён на secret v2"
db_secrets=$(docker service inspect shop_db --format '{{range .Spec.TaskTemplate.ContainerSpec.Secrets}}{{println .SecretName}}{{end}}')
printf '%s\n' "$db_secrets" | grep -qx shop_db_password_v2 || fail "db не переключён на secret v2"
api_configs=$(docker service inspect shop_api --format '{{range .Spec.TaskTemplate.ContainerSpec.Configs}}{{println .ConfigName}}{{end}}')
printf '%s\n' "$api_configs" | grep -qx shop_api_config_v2 || fail "api не переключён на config v2"
curl -fsS http://127.0.0.1:8080/api/version | grep -q '"rotated": true' || fail "API не видит rotated config"
curl -fsS http://127.0.0.1:8080/api/products/swarm-book | grep -q 'Swarm Book' || fail "после rotation потеряны данные/доступ к БД"
for service in shop_api shop_db; do
  if docker service logs --raw "$service" 2>&1 | grep -Eiq 'SwarmLab-DB-v[12]!'; then fail "plaintext secret найден в logs $service"; fi
done
echo "Secret и API config успешно ротированы"
