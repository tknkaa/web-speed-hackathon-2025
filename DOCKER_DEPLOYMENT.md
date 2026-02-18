# Docker Deployment Guide

This guide explains how to deploy the Web Speed Hackathon 2025 application using Docker.

## About the `.ts` Files in `workspaces/server/streams/`

**Important:** The `.ts` files in `workspaces/server/streams/` are **NOT TypeScript files**. They are **MPEG Transport Stream** video files used for HLS (HTTP Live Streaming) video delivery. This is why you may encounter "invalid UTF-8" errors when tools try to parse them as text files.

These files are binary video segments and should be treated as such by your deployment platform.

## Prerequisites

- Docker 20.10 or later
- Docker Compose (optional, for local testing)

## Building the Docker Image

### Local Build

```bash
docker build -t web-speed-hackathon-2025 .
```

### Build with Custom Tag

```bash
docker build -t your-registry/web-speed-hackathon-2025:latest .
```

## Running the Container

### Using Docker Run

```bash
docker run -p 8000:8000 \
  -e NODE_ENV=production \
  -e PORT=8000 \
  -e API_BASE_URL=http://localhost:8000/api \
  web-speed-hackathon-2025
```

### Using Docker Compose

```bash
docker-compose up -d
```

To view logs:
```bash
docker-compose logs -f
```

To stop:
```bash
docker-compose down
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `production` | Node environment |
| `PORT` | `8000` | Server port |
| `API_BASE_URL` | `http://localhost:8000/api` | API base URL |

## Deploying to Coolify

1. **Push your code to a Git repository** (GitHub, GitLab, etc.)

2. **In Coolify:**
   - Create a new application
   - Select "Docker" as the build pack
   - Connect your Git repository
   - Set the Dockerfile path to `./Dockerfile`
   - Configure environment variables as needed
   - Deploy!

3. **Important Coolify Settings:**
   - Build Pack: `Dockerfile`
   - Dockerfile Location: `./Dockerfile`
   - Port: `8000`
   - Health Check Path: `/` (optional)

## Deploying to Other Platforms

### Docker Hub / Container Registry

```bash
# Build and tag
docker build -t your-username/web-speed-hackathon-2025:latest .

# Push to registry
docker push your-username/web-speed-hackathon-2025:latest
```

### Cloud Platforms

The Docker image can be deployed to any platform that supports Docker containers:
- **Google Cloud Run**
- **AWS ECS/Fargate**
- **Azure Container Instances**
- **DigitalOcean App Platform**
- **Fly.io**
- **Railway**

## Troubleshooting

### UTF-8 Errors with `.ts` Files

If you encounter errors like "invalid UTF-8 in workspaces/server/stream/\*\*/\*.ts":

- These are **video files**, not TypeScript files
- Ensure your deployment platform is not trying to parse them as text
- The `.dockerignore` file is configured to handle this correctly
- Make sure you're using the provided Dockerfile which treats these files as binary data

### Build Fails

1. Ensure you have enough disk space (build requires ~2GB)
2. Check that pnpm version matches: `9.14.2`
3. Verify Node.js version: `22.14.0`

### Container Won't Start

1. Check logs: `docker logs <container-id>`
2. Verify environment variables are set correctly
3. Ensure port 8000 is not already in use

## Performance Optimization

The Dockerfile uses a multi-stage build to:
- Keep the final image size small
- Include only production dependencies
- Exclude development and test files

## Health Checks

The container includes a health check that verifies the server is responding on port 8000. The health check:
- Runs every 30 seconds
- Has a 3-second timeout
- Allows 10 seconds for startup
- Retries 3 times before marking as unhealthy

## File Structure

```
.
├── Dockerfile              # Multi-stage Docker build
├── .dockerignore          # Files to exclude from build
├── docker-compose.yml     # Local testing configuration
└── DOCKER_DEPLOYMENT.md   # This file
```
