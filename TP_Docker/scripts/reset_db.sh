#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_DIR}"

if ! docker compose ps --status running --services | grep -qx mysql; then
  echo "The MySQL service is not running. Start the stack with: docker compose up -d" >&2
  exit 1
fi

# Clear only products created by the Spring Boot JMeter CRUD scenario.
# Preserve all other application data and create the known Category ID used by the plans.
docker compose exec -T mysql sh -c 'mysql --protocol=TCP -uroot -p"$MYSQL_ROOT_PASSWORD" products' <<'SQL'
DELETE FROM products WHERE name LIKE 'JMeter Load %';
INSERT INTO categories (id, name)
SELECT 1, 'JMeter Test Category'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE id = 1);
SQL

echo "Spring JMeter data reset. The test category is available as categoryId 1."

# Keep Laravel's schema separate from Spring's, and clear only Laravel JMeter products.
docker compose exec -T mysql sh -c 'mysql --protocol=TCP -uroot -p"$MYSQL_ROOT_PASSWORD" laravel_products' <<'SQL'
DELETE FROM products WHERE name LIKE 'JMeter Laravel %';
INSERT INTO categories (id, name, description, created_at, updated_at)
SELECT 1, 'JMeter Laravel Category', 'Category used by Laravel JMeter CRUD', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE id = 1);
SQL

echo "Laravel JMeter data reset. The test category is available as category_id 1."

# Clear only Express CRUD products from its isolated product_api database.
docker compose exec -T mysql sh -c 'mysql --protocol=TCP -uroot -p"$MYSQL_ROOT_PASSWORD" product_api' <<'SQL'
DELETE FROM products WHERE name LIKE 'JMeter Express %';
SQL

echo "Express JMeter data reset."
