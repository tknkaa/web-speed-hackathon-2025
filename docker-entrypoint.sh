#!/bin/sh
set -e

DB_PATH="/app/workspaces/server/database.sqlite"
SEED_DONE_PATH="/app/workspaces/server/.seed_done"

cd /app/workspaces/server

if [ ! -f "$DB_PATH" ]; then
  echo "==> database.sqlite not found, creating schema..."
  npx drizzle-kit generate
  npx drizzle-kit push
  echo "==> Schema created. Server will start now, seeding in background..."

  # Seed in background so server can start immediately (healthchecks pass)
  (
    NODE_OPTIONS="--max-old-space-size=2048" npx tsx ./tools/seed.ts && \
    touch "$SEED_DONE_PATH" && \
    echo "==> Background seeding complete!" || \
    (echo "==> Background seed failed! Removing DB for retry on next restart..." && rm -f "$DB_PATH" "$SEED_DONE_PATH")
  ) &

elif [ ! -f "$SEED_DONE_PATH" ]; then
  echo "==> database.sqlite exists but seed did not complete. Re-seeding in background..."
  (
    NODE_OPTIONS="--max-old-space-size=2048" npx tsx ./tools/seed.ts && \
    touch "$SEED_DONE_PATH" && \
    echo "==> Background re-seeding complete!" || \
    (echo "==> Background seed failed!" && rm -f "$DB_PATH" "$SEED_DONE_PATH")
  ) &

else
  echo "==> database.sqlite ready, skipping seed."
fi

cd /app
exec "$@"
