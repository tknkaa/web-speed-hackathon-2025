#!/bin/sh
set -e

DB_PATH="/app/workspaces/server/database.sqlite"

if [ ! -f "$DB_PATH" ]; then
  echo "==> database.sqlite not found, running migrations and seed..."
  cd /app/workspaces/server

  npx drizzle-kit generate
  npx drizzle-kit push

  # Give Node.js 2GB RAM for the seed script (inserts thousands of rows)
  NODE_OPTIONS="--max-old-space-size=2048" npx tsx ./tools/seed.ts || {
    echo "==> Seed failed! Removing partial database to allow retry..."
    rm -f "$DB_PATH"
    exit 1
  }

  echo "==> Database ready."
  cd /app
else
  echo "==> database.sqlite already exists, skipping seed."
fi

exec "$@"
