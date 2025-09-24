# Configuration Guide

This guide covers all configuration options for the n8n Docker deployment.

## Environment Variables

### Core n8n Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `N8N_PORT` | Port for n8n web interface | `5678` | No |
| `N8N_HOST` | Host for n8n | `localhost` | No |
| `N8N_PROTOCOL` | Protocol (http/https) | `http` | No |
| `N8N_BASIC_AUTH_ACTIVE` | Enable basic authentication | `true` | No |
| `N8N_BASIC_AUTH_USER` | Basic auth username | `admin` | No |
| `N8N_BASIC_AUTH_PASSWORD` | Basic auth password | `secure-password` | **Yes** |

### Database Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `DB_TYPE` | Database type | `postgresdb` | No |
| `POSTGRES_DB` | PostgreSQL database name | `n8n` | No |
| `POSTGRES_USER` | PostgreSQL username | `n8n` | No |
| `POSTGRES_PASSWORD` | PostgreSQL password | Generated | **Yes** |
| `POSTGRES_PORT` | PostgreSQL port | `5432` | No |

### Optional Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `GENERIC_TIMEZONE` | Timezone for n8n | `UTC` |
| `WEBHOOK_URL` | Base URL for webhooks | `http://localhost:5678/` |
| `NODE_ENV` | Node environment | `production` |

## Email Configuration

To enable email notifications, add these variables to your `.env` file:

```env
N8N_EMAIL_MODE=smtp
N8N_SMTP_HOST=smtp.gmail.com
N8N_SMTP_PORT=587
N8N_SMTP_USER=your-email@gmail.com
N8N_SMTP_PASS=your-app-password
N8N_SMTP_SENDER=your-email@gmail.com
```

### Gmail Setup

1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate a password for "Mail"
3. Use the generated password as `N8N_SMTP_PASS`

## Security Configuration

### Change Default Passwords

Always change the default passwords in your `.env` file:

```env
N8N_BASIC_AUTH_PASSWORD=your-very-secure-password
POSTGRES_PASSWORD=another-very-secure-password
```

### Enable HTTPS (Production)

For production deployments, consider adding a reverse proxy with SSL:

```yaml
# Add to docker-compose.yml
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - n8n
```

## Volume Configuration

### Data Persistence

- **n8n data**: Stored in `n8n_data` Docker volume
- **PostgreSQL data**: Stored in `postgres_data` Docker volume

### Custom Volume Paths

To use custom paths instead of Docker volumes:

```yaml
volumes:
  - /path/to/your/n8n/data:/home/node/.n8n
  - /path/to/your/postgres/data:/var/lib/postgresql/data
```

## Network Configuration

### Custom Networks

The setup uses a custom bridge network `n8n-network` for container communication.

### Port Mapping

- n8n web interface: `5678:5678`
- PostgreSQL: Internal only (not exposed)

### Custom Ports

To use a different port:

```env
N8N_PORT=8080
```

Then update the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "8080:5678"
```

## Resource Limits

For production deployments, consider adding resource limits:

```yaml
services:
  n8n:
    # ... existing config
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
  
  postgres:
    # ... existing config
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

## Monitoring Configuration

### Health Checks

The configuration includes health checks for both services:

- **n8n**: Checks `/healthz` endpoint
- **PostgreSQL**: Uses `pg_isready` command

### Logging

Customize logging levels:

```env
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=console
```

## Backup Configuration

### Database Backups

Add a backup service to `docker-compose.yml`:

```yaml
  backup:
    image: postgres:15-alpine
    depends_on:
      - postgres
    volumes:
      - ./backups:/backups
    command: |
      bash -c 'while true; do
        pg_dump -h postgres -U n8n -d n8n > /backups/n8n_backup_$$(date +%Y%m%d_%H%M%S).sql
        sleep 86400
      done'
    environment:
      - PGPASSWORD=${POSTGRES_PASSWORD}
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure script files are executable
2. **Port Already in Use**: Change `N8N_PORT` in `.env`
3. **Database Connection Failed**: Check PostgreSQL container logs
4. **Memory Issues**: Increase Docker Desktop memory allocation

### Debug Mode

Enable debug logging:

```env
N8N_LOG_LEVEL=debug
```

### Container Inspection

```bash
# Check container status
docker compose ps

# View logs
./scripts/logs.sh

# Enter container
docker compose exec n8n bash
```
