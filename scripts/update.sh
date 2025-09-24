#!/bin/bash

# n8n Docker Update Script
# This script updates n8n to the latest version

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

print_status "Updating n8n to the latest version..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check if containers are running
if docker compose ps | grep -q "Up"; then
    print_warning "Containers are currently running. They will be stopped during the update."
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Update cancelled."
        exit 0
    fi
fi

# Create backup notice
print_warning "IMPORTANT: This will update n8n to the latest version."
print_warning "It's recommended to backup your data before proceeding."
print_warning "Your workflows and data are stored in Docker volumes and should persist."
echo

read -p "Do you want to proceed with the update? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Update cancelled."
    exit 0
fi

# Stop containers
print_status "Stopping containers..."
if docker compose down; then
    print_success "Containers stopped successfully!"
else
    print_error "Failed to stop containers."
    exit 1
fi

# Pull latest images
print_status "Pulling latest Docker images..."
if docker compose pull; then
    print_success "Latest images pulled successfully!"
else
    print_error "Failed to pull latest images."
    exit 1
fi

# Start containers with new images
print_status "Starting containers with updated images..."
if docker compose up -d; then
    print_success "n8n updated and started successfully!"
    echo
    print_status "Container status:"
    docker compose ps
    echo
    print_status "n8n is available at: http://localhost:5678"
    print_status "Please check the logs to ensure everything is working correctly:"
    print_status "./scripts/logs.sh"
else
    print_error "Failed to start updated containers. Check the logs for details."
    print_status "Running logs command..."
    docker compose logs
    exit 1
fi

# Show version information
echo
print_status "Update completed! New version information:"
docker compose exec n8n n8n --version 2>/dev/null || echo "Could not retrieve version (this is normal if container is still starting)"
