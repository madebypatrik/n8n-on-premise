# Troubleshooting Guide

This guide helps you resolve common issues with the n8n Docker deployment.

## Common Issues

### 1. Docker Desktop Not Running

**Problem**: Error message "Docker is not running"

**Solution**:
1. Open Docker Desktop application
2. Wait for it to fully start (whale icon in system tray should be stable)
3. Try the command again

### 2. Port Already in Use

**Problem**: Error about port 5678 already being in use

**Solutions**:

**Option A**: Change the port in `.env` file
```env
N8N_PORT=8080
```

**Option B**: Find and stop the process using port 5678
```bash
# Find process using port 5678
lsof -i :5678

# Kill the process (replace PID with actual process ID)
kill -9 PID
```

### 3. Permission Denied on Scripts

**Problem**: `Permission denied` when running scripts

**Solution**:
```bash
chmod +x scripts/*.sh
```

### 4. Database Connection Issues

**Problem**: n8n can't connect to PostgreSQL

**Symptoms**:
- n8n container keeps restarting
- Logs show database connection errors

**Solutions**:

1. **Check PostgreSQL health**:
   ```bash
   docker compose ps
   ./scripts/logs.sh postgres
   ```

2. **Verify environment variables**:
   - Ensure `POSTGRES_PASSWORD` matches in both services
   - Check `.env` file for typos

3. **Reset database**:
   ```bash
   ./scripts/stop.sh
   docker volume rm n8n-docker_postgres_data
   ./scripts/start.sh
   ```

### 5. Memory Issues

**Problem**: Containers are killed due to memory limits

**Solutions**:

1. **Increase Docker Desktop memory**:
   - Docker Desktop → Settings → Resources → Memory
   - Increase to at least 4GB

2. **Add memory limits to docker-compose.yml**:
   ```yaml
   services:
     n8n:
       # ... existing config
       mem_limit: 1g
   ```

### 6. SSL/HTTPS Issues

**Problem**: Mixed content errors or SSL warnings

**Solution**: Configure reverse proxy with SSL certificate

Example nginx configuration:
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 7. Workflow Execution Issues

**Problem**: Workflows fail to execute or timeout

**Solutions**:

1. **Check n8n logs**:
   ```bash
   ./scripts/logs.sh n8n
   ```

2. **Increase execution timeout**:
   Add to `.env`:
   ```env
   EXECUTIONS_TIMEOUT=300
   EXECUTIONS_TIMEOUT_MAX=600
   ```

3. **Check webhook URLs**:
   Ensure `WEBHOOK_URL` is correctly set in `.env`

### 8. Data Loss

**Problem**: Workflows or data disappeared after restart

**Cause**: Using bind mounts instead of Docker volumes

**Prevention**:
- Always use Docker volumes (default in our setup)
- Regular backups

**Recovery**:
```bash
# Check if volumes exist
docker volume ls | grep n8n

# If volumes are missing, data may be lost
# Restore from backup if available
```

## Debug Commands

### View Container Status
```bash
docker compose ps
```

### Check Container Resources
```bash
docker stats
```

### Inspect Container Configuration
```bash
docker compose config
```

### View All Logs
```bash
./scripts/logs.sh -f
```

### Enter n8n Container
```bash
docker compose exec n8n bash
```

### Check n8n Version
```bash
docker compose exec n8n n8n --version
```

### Database Connection Test
```bash
docker compose exec postgres pg_isready -U n8n -d n8n
```

### Manual Database Access
```bash
docker compose exec postgres psql -U n8n -d n8n
```

## Environment Debugging

### Verify Environment Variables
```bash
docker compose config | grep -A 10 environment
```

### Check .env File Loading
```bash
# Show environment variables as Docker Compose sees them
docker compose config --services
```

## Performance Issues

### Slow Workflow Execution

1. **Check system resources**:
   ```bash
   docker stats
   ```

2. **Optimize workflows**:
   - Reduce unnecessary nodes
   - Use batch processing
   - Add delays between API calls

3. **Increase worker processes**:
   ```env
   N8N_PAYLOAD_SIZE_MAX=16
   EXECUTIONS_PROCESS=main
   ```

### High Memory Usage

1. **Monitor memory usage**:
   ```bash
   docker stats --no-stream
   ```

2. **Reduce execution data retention**:
   ```env
   EXECUTIONS_DATA_PRUNE=true
   EXECUTIONS_DATA_MAX_AGE=168
   ```

## Getting Help

### Log Collection

Before seeking help, collect relevant information:

```bash
# System information
docker version
docker compose version

# Container status
docker compose ps

# Recent logs
./scripts/logs.sh -n 100 > n8n-logs.txt

# Configuration
docker compose config > docker-config.yml
```

### Support Channels

1. **n8n Community**: https://community.n8n.io/
2. **GitHub Issues**: Report bugs in this repository
3. **n8n Documentation**: https://docs.n8n.io/

### Include in Bug Reports

- Operating system and version
- Docker Desktop version
- Output of `docker compose ps`
- Relevant log excerpts
- Steps to reproduce the issue
- Expected vs actual behavior
