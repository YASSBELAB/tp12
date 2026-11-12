#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

LABEL="${1:-snapshot-$(date +%Y%m%d-%H%M%S)}"
if [[ ! "${LABEL}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Use only letters, numbers, dots, underscores, and hyphens in the scenario label." >&2
  exit 2
fi

OUTPUT_DIR="${PROJECT_DIR}/metrics/${LABEL}"
mkdir -p "${OUTPUT_DIR}"

CONTAINERS=(spring-api express-api laravel-nginx laravel-php products-mysql)
CAPTURED_AT="$(date -Iseconds)"

{
  printf 'CapturedAt;Container;CPUPerc;MemUsage;NetIO;BlockIO\n'
  docker stats --no-stream \
    --format '{{.Container}};{{.CPUPerc}};{{.MemUsage}};{{.NetIO}};{{.BlockIO}}' \
    "${CONTAINERS[@]}" |
    while IFS= read -r row; do
      printf '%s;%s\n' "${CAPTURED_AT}" "${row}"
    done
} > "${OUTPUT_DIR}/stats.csv"

docker logs --timestamps spring-api > "${OUTPUT_DIR}/logs_spring.txt" 2>&1
docker logs --timestamps express-api > "${OUTPUT_DIR}/logs_express.txt" 2>&1
{
  printf '===== laravel-nginx =====\n'
  docker logs --timestamps laravel-nginx 2>&1
  printf '\n===== laravel-php =====\n'
  docker logs --timestamps laravel-php 2>&1
} > "${OUTPUT_DIR}/logs_laravel.txt"
docker logs --timestamps products-mysql > "${OUTPUT_DIR}/logs_mysql.txt" 2>&1

printf 'Metrics and logs saved in: %s\n' "${OUTPUT_DIR}"
