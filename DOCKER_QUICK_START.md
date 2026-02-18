# Quick Docker Deployment Reference

## The Problem: UTF-8 Error with `.ts` Files

The error "invalid UTF-8 in workspaces/server/stream/\*\*/\*.ts" occurs because:
- These `.ts` files are **video files** (MPEG Transport Stream), NOT TypeScript
- They contain binary data that cannot be parsed as UTF-8 text
- Some deployment tools incorrectly try to validate them as text files

## The Solution: Docker Container

Use the provided Dockerfile which properly handles binary files.

## Quick Start

### 1. Build the Docker Image
```bash
docker build -t web-speed-hackathon-2025 .
```

### 2. Test Locally
```bash
# Option A: Using docker run
docker run -p 8000:8000 web-speed-hackathon-2025

# Option B: Using docker-compose
docker-compose up
```

### 3. Deploy to Coolify

**In Coolify Dashboard:**
1. Create New Application
2. Select your Git repository
3. Build Pack: **Dockerfile**
4. Dockerfile Path: `./Dockerfile`
5. Port: **8000**
6. Environment Variables:
   - `NODE_ENV=production`
   - `PORT=8000`
   - `API_BASE_URL=https://your-domain.com/api` (update with your actual domain)
7. Click Deploy

**Important:** Make sure Coolify uses the Dockerfile build method, not trying to detect the build pack automatically.

## Files Created

- ✅ `Dockerfile` - Multi-stage build configuration
- ✅ `.dockerignore` - Excludes unnecessary files from build
- ✅ `docker-compose.yml` - For local testing
- ✅ `DOCKER_DEPLOYMENT.md` - Detailed deployment guide
- ✅ `DOCKER_QUICK_START.md` - This file

## Verification

After deployment, verify the app is running:
```bash
curl http://your-domain.com/
```

You should see the application's HTML response.

## Need Help?

See `DOCKER_DEPLOYMENT.md` for detailed instructions and troubleshooting.
