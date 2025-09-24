#!/bin/bash

# n8n Docker Restart Script
# This script restarts the n8n Docker containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

print_status "Restarting n8n Docker containers..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Restart the containers
print_status "Stopping containers..."
if docker compose down; then
    print_success "Containers stopped successfully!"
else
    print_error "Failed to stop containers."
    exit 1
fi

print_status "Starting containers..."
if docker compose up -d; then
    print_success "n8n containers restarted successfully!"
    echo
    print_status "Container status:"
    docker compose ps
    echo
    print_status "n8n is available at: http://localhost:5678"
    print_status "To view logs, run: ./scripts/logs.sh"
else
    print_error "Failed to start n8n containers. Check the logs for details."
    print_status "Running logs command..."
    docker compose logs
    exit 1
fi
