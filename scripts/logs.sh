#!/bin/bash

# n8n Docker Logs Script
# This script shows logs from n8n Docker containers

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

# Parse command line arguments
SERVICE=""
FOLLOW=false
LINES=100

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        n8n|postgres)
            SERVICE="$1"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] [SERVICE]"
            echo ""
            echo "Show logs from n8n Docker containers"
            echo ""
            echo "Services:"
            echo "  n8n       Show n8n application logs"
            echo "  postgres  Show PostgreSQL database logs"
            echo ""
            echo "Options:"
            echo "  -f, --follow    Follow log output (like tail -f)"
            echo "  -n, --lines N   Show last N lines (default: 100)"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Show last 100 lines from all services"
            echo "  $0 -f                 # Follow logs from all services"
            echo "  $0 n8n                # Show logs from n8n service only"
            echo "  $0 -f n8n             # Follow n8n logs"
            echo "  $0 -n 50 postgres     # Show last 50 lines from postgres"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Build docker compose logs command
CMD="docker compose logs"

if [ "$FOLLOW" = true ]; then
    CMD="$CMD -f"
fi

CMD="$CMD --tail=$LINES"

if [ -n "$SERVICE" ]; then
    CMD="$CMD $SERVICE"
    print_status "Showing logs for $SERVICE service..."
else
    print_status "Showing logs for all services..."
fi

if [ "$FOLLOW" = true ]; then
    print_status "Following logs (Press Ctrl+C to stop)..."
fi

echo
eval $CMD
