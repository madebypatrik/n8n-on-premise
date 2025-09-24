#!/bin/bash

# n8n Docker Status Script
# This script shows detailed status information about n8n containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop."
    exit 1
fi

print_header "n8n Docker Status Report"
echo

# Container Status
print_header "Container Status"
if docker compose ps --format table 2>/dev/null; then
    echo
else
    print_warning "No containers found or docker-compose.yml not found"
    echo
fi

# Health Status
print_header "Health Checks"
containers=$(docker compose ps --services 2>/dev/null || echo "")
if [ -n "$containers" ]; then
    for service in $containers; do
        container_name=$(docker compose ps --format json | jq -r --arg service "$service" 'select(.Service == $service) | .Name' 2>/dev/null || echo "")
        if [ -n "$container_name" ]; then
            health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
            case $health in
                "healthy")
                    print_success "$service: Healthy"
                    ;;
                "unhealthy")
                    print_error "$service: Unhealthy"
                    ;;
                "starting")
                    print_warning "$service: Starting..."
                    ;;
                "no-healthcheck")
                    print_status "$service: No health check configured"
                    ;;
                *)
                    print_warning "$service: Unknown health status ($health)"
                    ;;
            esac
        fi
    done
else
    print_warning "No services found"
fi
echo

# Resource Usage
print_header "Resource Usage"
if docker compose ps -q | head -1 > /dev/null 2>&1; then
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" "$(docker compose ps -q)" 2>/dev/null || print_warning "Could not get resource statistics"
else
    print_warning "No running containers found"
fi
echo

# Volume Information
print_header "Volume Information"
volumes=$(docker volume ls --format "{{.Name}}" | grep "$(basename "$PROJECT_DIR")" 2>/dev/null || echo "")
if [ -n "$volumes" ]; then
    for volume in $volumes; do
        size=$(docker system df -v | grep "$volume" | awk '{print $(NF-1)" "$NF}' 2>/dev/null || echo "unknown")
        print_status "$volume: $size"
    done
else
    print_warning "No project volumes found"
fi
echo

# Network Information
print_header "Network Information"
networks=$(docker network ls --format "{{.Name}}" | grep "$(basename "$PROJECT_DIR")" 2>/dev/null || echo "")
if [ -n "$networks" ]; then
    for network in $networks; do
        driver=$(docker network inspect "$network" --format "{{.Driver}}" 2>/dev/null || echo "unknown")
        print_status "$network: $driver network"
        
        # Show connected containers
        containers=$(docker network inspect "$network" --format "{{range .Containers}}{{.Name}} {{end}}" 2>/dev/null || echo "")
        if [ -n "$containers" ]; then
            echo "  Connected containers: $containers"
        fi
    done
else
    print_warning "No project networks found"
fi
echo

# Service URLs
print_header "Service URLs"
n8n_port=$(grep "N8N_PORT" .env 2>/dev/null | cut -d'=' -f2 || echo "5678")
if docker compose ps | grep -q "Up.*:$n8n_port->"; then
    print_success "n8n Web Interface: http://localhost:$n8n_port"
    
    # Test if n8n is responding
    if command -v curl > /dev/null 2>&1; then
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$n8n_port" | grep -q "200\|401"; then
            print_success "n8n is responding to requests"
        else
            print_warning "n8n may not be fully ready yet"
        fi
    fi
else
    print_warning "n8n does not appear to be running on port $n8n_port"
fi
echo

# Recent Log Summary
print_header "Recent Activity (Last 10 Log Lines)"
if docker compose ps -q | head -1 > /dev/null 2>&1; then
    docker compose logs --tail=10 2>/dev/null || print_warning "Could not retrieve recent logs"
else
    print_warning "No containers running"
fi
echo

# Configuration Check
print_header "Configuration Status"
if [ -f ".env" ]; then
    print_success ".env file exists"
    
    # Check for default passwords
    if grep -q "your-secure-password\|generate-a-secure-password" .env 2>/dev/null; then
        print_warning "Default passwords detected in .env file - please change them!"
    else
        print_success "Custom passwords configured"
    fi
else
    print_error ".env file not found"
fi

if [ -f "docker-compose.yml" ]; then
    print_success "docker-compose.yml exists"
    
    # Validate docker-compose.yml
    if docker compose config > /dev/null 2>&1; then
        print_success "docker-compose.yml is valid"
    else
        print_error "docker-compose.yml has configuration errors"
    fi
else
    print_error "docker-compose.yml not found"
fi
echo

# Quick Actions
print_header "Quick Actions"
echo "View logs:     ./scripts/logs.sh"
echo "Start n8n:     ./scripts/start.sh"
echo "Stop n8n:      ./scripts/stop.sh"
echo "Restart n8n:   ./scripts/restart.sh"
echo "Update n8n:    ./scripts/update.sh"
echo "This status:   ./scripts/status.sh"
