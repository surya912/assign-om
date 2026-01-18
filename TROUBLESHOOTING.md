# Troubleshooting Guide

## Network Issues with Docker

If you're getting errors like "no such host" or "dial tcp: lookup auth.docker.io", try these solutions:

### Solution 1: Check Internet Connection
```bash
# Test basic connectivity
ping -c 3 8.8.8.8
ping -c 3 google.com
```

### Solution 2: Check Docker Network Settings
```bash
# Restart Docker
# On macOS: Restart Docker Desktop
# On Linux: sudo systemctl restart docker
```

### Solution 3: Use Docker Mirror/Proxy (if behind corporate firewall)
If you're behind a corporate firewall, configure Docker to use a proxy:
- Docker Desktop: Settings → Resources → Proxies
- Or set environment variables:
  ```bash
  export HTTP_PROXY=http://proxy.example.com:8080
  export HTTPS_PROXY=http://proxy.example.com:8080
  ```

### Solution 4: Use Local PostgreSQL (Alternative)
If you can't pull the PostgreSQL image, you can run PostgreSQL locally:

```bash
# Install PostgreSQL locally (macOS)
brew install postgresql@15
brew services start postgresql@15

# Create database
createdb ideaboard
psql ideaboard -c "CREATE USER ideaboard WITH PASSWORD 'ideaboard';"
psql ideaboard -c "GRANT ALL PRIVILEGES ON DATABASE ideaboard TO ideaboard;"

# Then modify docker-compose.yml to use host.docker.internal
# Or run backend locally (see below)
```

### Solution 5: Run Backend Locally (No Docker)
If Docker networking is problematic, you can run components separately:

```bash
# Terminal 1: Start PostgreSQL (if installed locally)
# Or use the docker postgres if it's already pulled

# Terminal 2: Backend
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Terminal 3: Frontend
cd frontend
npm install
npm start
```

### Solution 6: Pre-pull Images When Network is Available
```bash
# When you have network access, pre-pull images
docker pull postgres:15-alpine
docker pull python:3.11-slim
docker pull node:18-alpine
docker pull nginx:alpine
```

### Solution 7: Check DNS Settings
```bash
# Check your DNS servers
cat /etc/resolv.conf

# Try using Google DNS
# macOS: System Preferences → Network → Advanced → DNS
# Add: 8.8.8.8, 8.8.4.4
```

### Solution 8: VPN/Proxy Issues
If you're using a VPN:
- Try disconnecting VPN temporarily
- Or configure Docker to bypass VPN for Docker Hub

## Common Docker Compose Issues

### Port Already in Use
```bash
# Find what's using the port
lsof -i :5432  # PostgreSQL
lsof -i :8000  # Backend
lsof -i :3000  # Frontend

# Kill the process or change ports in docker-compose.yml
```

### Permission Denied
```bash
# On Linux, add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Out of Disk Space
```bash
# Clean up Docker
docker system prune -a
docker volume prune
```

## Getting Help

If issues persist:
1. Check Docker logs: `docker-compose logs`
2. Check individual service: `docker-compose logs postgres`
3. Verify Docker is running: `docker ps`
4. Check Docker version: `docker --version` and `docker compose version`

