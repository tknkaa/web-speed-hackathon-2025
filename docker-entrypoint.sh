#!/bin/sh
set -e

DB_PATH="/app/workspaces/server/database.sqlite"

if [ ! -f "$DB_PATH" ]; then
  echo "==> database.sqlite not found, running migrations and seed..."
  cd /app/workspaces/server
  npx drizzle-kit generate
  npx drizzle-kit push
  npx tsx ./tools/seed.ts
  echo "==> Database ready."
  cd /app
else
  echo "==> database.sqlite already exists, skipping seed."
fi

exec "$@"
