# syntax=docker/dockerfile:1
#
# Database is seeded on first container startup via docker-entrypoint.sh
# No need to commit database.sqlite to git.

# Stage 1: Build stage
FROM node:22.14.0-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Enable corepack and install pnpm
RUN corepack enable && corepack prepare pnpm@9.14.2 --activate

WORKDIR /app

# Copy everything
COPY . .

# Install all dependencies (including dev - needed for seeding at startup)
RUN pnpm install --frozen-lockfile

# Build the client application
RUN pnpm run build

# Stage 2: Production stage
FROM node:22.14.0-slim AS production

# Install runtime dependencies needed for seeding (python3 for bcrypt native module)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Enable corepack and install pnpm
RUN corepack enable && corepack prepare pnpm@9.14.2 --activate

WORKDIR /app

# Copy built application from builder (includes node_modules with dev deps for seeding)
COPY --from=builder /app ./

# Copy and set up entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8000
ENV API_BASE_URL=http://localhost:8000/api

# Expose the application port
EXPOSE 8000

# Health check (longer start period to allow for first-time seeding)
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=5 \
    CMD node -e "require('http').get('http://localhost:8000/', (r) => {process.exit(r.statusCode < 500 ? 0 : 1)})"

# Use entrypoint to seed DB on first run, then start the app
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pnpm", "run", "heroku-start"]

