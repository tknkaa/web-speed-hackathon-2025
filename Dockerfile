# syntax=docker/dockerfile:1

# Stage 1: Build stage
FROM node:22.14.0-slim AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.14.2 --activate

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY .npmrc ./

# Copy workspace package.json files
COPY workspaces/client/package.json ./workspaces/client/
COPY workspaces/configs/package.json ./workspaces/configs/
COPY workspaces/schema/package.json ./workspaces/schema/
COPY workspaces/server/package.json ./workspaces/server/

# Install all dependencies (including dev dependencies for build)
RUN pnpm install --frozen-lockfile

# Copy source code and configuration files
COPY . .

# Build the client application
RUN pnpm run build

# Clean up development dependencies and unnecessary files
RUN rm -rf ./node_modules ./workspaces/*/.wireit ./workspaces/test && \
    pnpm install --prod --frozen-lockfile

# Stage 2: Production stage
FROM node:22.14.0-slim AS production

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.14.2 --activate

WORKDIR /app

# Copy built application from builder
COPY --from=builder /app ./

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8000
ENV API_BASE_URL=http://localhost:8000/api

# Expose the application port
EXPOSE 8000

# Health check - just verify the server is responding
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8000/', (r) => {process.exit(r.statusCode < 500 ? 0 : 1)})"

# Start the application
CMD ["pnpm", "run", "heroku-start"]
