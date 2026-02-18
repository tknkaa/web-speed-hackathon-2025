# Coolify Deployment Troubleshooting

## Common Issues and Solutions

### Issue 1: "Command execution failed (exit code 1)"

This generic error can have multiple causes. Here's how to debug:

#### **Step 1: Check Coolify Build Logs**

In Coolify, click on your deployment and look for the full build logs. The error message you see is just the summary. Look for:

- `npm ERR!` or `pnpm ERR!` messages
- `Error: Cannot find module` messages
- Build step failures
- Memory issues

#### **Step 2: Common Causes**

**A. Missing Build Dependencies**

The updated Dockerfile now includes build dependencies (python3, make, g++) needed for native modules like `bcrypt`.

**B. Memory Issues**

Large builds can run out of memory. In Coolify:
- Go to your app settings
- Increase memory limit (try 2GB or more)

**C. Docker BuildKit Issues**

Some Coolify instances have issues with BuildKit. Try adding this to your Dockerfile (already included):
```dockerfile
# syntax=docker/dockerfile:1
```

**D. File Permissions**

Ensure your repository files have correct permissions, especially:
- `pnpm-lock.yaml`
- `.npmrc`
- `patches/` directory

### Issue 2: Build Succeeds but App Won't Start

**Check Environment Variables:**

In Coolify, ensure these are set:
```
NODE_ENV=production
PORT=8000
API_BASE_URL=https://your-domain.com/api
```

**Important:** Update `API_BASE_URL` with your actual Coolify domain!

### Issue 3: "Cannot find module" Errors

This usually means the production dependencies weren't installed correctly.

**Solution:** The Dockerfile has been updated to:
1. Install all deps (including dev) for build
2. Build the client
3. Remove node_modules
4. Reinstall only production deps

### Issue 4: Port Binding Issues

**In Coolify Settings:**
- Port: `8000`
- Protocol: `HTTP`

The app listens on `0.0.0.0:8000` (all interfaces) which is correct for containers.

## Debugging Steps

### 1. Test Build Locally First

```bash
# Clean build test
docker build --no-cache -t test-build .

# If it fails locally, you'll see the actual error
```

### 2. Check Specific Build Steps

```bash
# Test just the dependency installation
docker build --target builder -t test-builder .

# Then inspect it
docker run -it test-builder /bin/bash
```

### 3. Verify Files Are Copied

```bash
# Build and check what files made it into the image
docker build -t test .
docker run -it test ls -la /app
docker run -it test ls -la /app/workspaces
```

## Updated Dockerfile Changes

The new Dockerfile includes:

✅ **Build dependencies** (python3, make, g++) for native modules
✅ **Explicit file copying** instead of `COPY . .`
✅ **Patches directory** copied before `pnpm install`
✅ **Better layer caching** for faster rebuilds

## Still Having Issues?

### Get Full Error Details

1. In Coolify, go to your app
2. Click on "Deployments"
3. Click on the failed deployment
4. Copy the **full build log** (not just the summary)
5. Look for the first error message (usually near the end)

### Common Error Patterns

| Error Message | Likely Cause | Solution |
|---------------|--------------|----------|
| `ENOENT: no such file` | Missing file during build | Check .dockerignore isn't excluding needed files |
| `gyp ERR!` | Native module build failure | Build deps now included in Dockerfile |
| `ELIFECYCLE` | Script failed | Check the script in package.json |
| `Out of memory` | Build too large | Increase memory in Coolify settings |
| `Cannot find module` | Missing dependency | Check pnpm-lock.yaml is committed |

## Quick Checklist

Before deploying to Coolify:

- [ ] All files committed to Git (including `pnpm-lock.yaml`)
- [ ] `Dockerfile` is in repository root
- [ ] `.dockerignore` is in repository root
- [ ] Builder set to "Dockerfile" in Coolify
- [ ] Port set to `8000` in Coolify
- [ ] Environment variables configured
- [ ] Repository is accessible by Coolify

## Test Command

If you want to test the exact build process Coolify uses:

```bash
# This simulates what Coolify does
git clone <your-repo> test-deploy
cd test-deploy
docker build -t coolify-test .
docker run -p 8000:8000 -e NODE_ENV=production coolify-test
```

Then visit `http://localhost:8000` to verify it works.
