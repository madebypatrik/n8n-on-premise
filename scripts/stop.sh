#!/bin/bash

# n8n Docker Stop Script
# This script stops the n8n Docker containers

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

print_status "Stopping n8n Docker containers..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Stop the containers
if docker compose down; then
    print_success "n8n containers stopped successfully!"
    echo
    print_status "All containers have been stopped and removed."
    print_status "Data volumes are preserved."
    print_status "To start n8n again, run: ./scripts/start.sh"
else
    print_error "Failed to stop n8n containers."
    exit 1
fi
