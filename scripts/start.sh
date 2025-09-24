#!/bin/bash

# n8n Docker Start Script
# This script starts the n8n Docker containers

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

print_status "Starting n8n Docker containers..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_warning "Please edit .env file with your configuration before running again."
        print_warning "Especially change the default passwords!"
        exit 1
    else
        print_error ".env.example file not found. Please create environment configuration."
        exit 1
    fi
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Start the containers
print_status "Starting containers with Docker Compose..."
if docker compose up -d; then
    print_success "n8n containers started successfully!"
    echo
    print_status "Container status:"
    docker compose ps
    echo
    print_status "n8n will be available at: http://localhost:5678"
    print_status "Default credentials (if not changed in .env):"
    echo "  Username: admin"
    echo "  Password: secure-password"
    echo
    print_status "To view logs, run: ./scripts/logs.sh"
    print_status "To stop n8n, run: ./scripts/stop.sh"
else
    print_error "Failed to start n8n containers. Check the logs for details."
    print_status "Running logs command..."
    docker compose logs
    exit 1
fi
