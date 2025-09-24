#!/bin/bash

# n8n Docker Monitor Script
# This script provides real-time monitoring of n8n containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}[$(date '+%H:%M:%S')] === $1 ===${NC}"
}

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Parse command line arguments
INTERVAL=10
SHOW_LOGS=false
ALERT_UNHEALTHY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -l|--logs)
            SHOW_LOGS=true
            shift
            ;;
        -a|--alert)
            ALERT_UNHEALTHY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Monitor n8n Docker containers in real-time"
            echo ""
            echo "Options:"
            echo "  -i, --interval N    Check interval in seconds (default: 10)"
            echo "  -l, --logs          Show recent logs with each check"
            echo "  -a, --alert         Alert on unhealthy containers"
            echo "  -h, --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                  # Monitor with default settings"
            echo "  $0 -i 5 -l          # Check every 5 seconds and show logs"
            echo "  $0 -a               # Enable alerts for unhealthy containers"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop."
    exit 1
fi

print_header "Starting n8n Docker Monitor"
print_status "Check interval: ${INTERVAL}s"
print_status "Show logs: $SHOW_LOGS"
print_status "Alert on unhealthy: $ALERT_UNHEALTHY"
print_status "Press Ctrl+C to stop monitoring"
echo

# Store previous states for change detection
declare -A prev_status
declare -A prev_health

# Function to check container status
check_containers() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get container information
    local containers=$(docker compose ps --format json 2>/dev/null | jq -r '.Name' 2>/dev/null || echo "")
    
    if [ -z "$containers" ]; then
        print_warning "No containers found"
        return
    fi
    
    echo "--- Status Check: $timestamp ---"
    
    # Check each container
    while read -r container; do
        [ -z "$container" ] && continue
        
        # Get current status and health
        local status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
        
        # Check for status changes
        if [ "${prev_status[$container]}" != "$status" ]; then
            if [ "$status" = "running" ]; then
                print_success "$container: Status changed to RUNNING"
            elif [ "$status" = "exited" ]; then
                print_error "$container: Status changed to EXITED"
            else
                print_warning "$container: Status changed to $status"
            fi
            prev_status[$container]="$status"
        fi
        
        # Check for health changes
        if [ "${prev_health[$container]}" != "$health" ] && [ "$health" != "no-healthcheck" ]; then
            case $health in
                "healthy")
                    print_success "$container: Health changed to HEALTHY"
                    ;;
                "unhealthy")
                    print_error "$container: Health changed to UNHEALTHY"
                    if [ "$ALERT_UNHEALTHY" = true ]; then
                        print_error "🚨 ALERT: $container is unhealthy!"
                    fi
                    ;;
                "starting")
                    print_warning "$container: Health changed to STARTING"
                    ;;
            esac
            prev_health[$container]="$health"
        fi
        
        # Show current status
        local status_color=""
        local health_color=""
        
        case $status in
            "running") status_color="\033[0;32m" ;;  # Green
            "exited") status_color="\033[0;31m" ;;   # Red
            *) status_color="\033[1;33m" ;;          # Yellow
        esac
        
        case $health in
            "healthy") health_color="\033[0;32m" ;;    # Green
            "unhealthy") health_color="\033[0;31m" ;;  # Red
            "starting") health_color="\033[1;33m" ;;   # Yellow
            *) health_color="\033[0;37m" ;;            # Gray
        esac
        
        printf "${BLUE}[$(date '+%H:%M:%S')]${NC} %-15s Status: ${status_color}%-10s${NC} Health: ${health_color}%-12s${NC}\n" \
               "$container" "$status" "$health"
               
    done <<< "$containers"
    
    # Show resource usage
    echo
    printf "${BLUE}Resource Usage:${NC}\n"
    docker stats --no-stream --format "  {{.Container}}: CPU {{.CPUPerc}}, Memory {{.MemUsage}} ({{.MemPerc}})" \
        $(docker compose ps -q) 2>/dev/null | head -5 || echo "  Could not get resource stats"
    
    # Show recent logs if requested
    if [ "$SHOW_LOGS" = true ]; then
        echo
        printf "${BLUE}Recent Logs (last 3 lines):${NC}\n"
        docker compose logs --tail=3 2>/dev/null | sed 's/^/  /' || echo "  Could not get logs"
    fi
    
    echo
}

# Function to handle Ctrl+C
cleanup() {
    echo
    print_header "Monitoring stopped"
    exit 0
}

# Set up signal handling
trap cleanup SIGINT SIGTERM

# Initialize previous states
containers=$(docker compose ps --format json 2>/dev/null | jq -r '.Name' 2>/dev/null || echo "")
while read -r container; do
    [ -z "$container" ] && continue
    prev_status[$container]=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")
    prev_health[$container]=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
done <<< "$containers"

# Main monitoring loop
while true; do
    check_containers
    sleep "$INTERVAL"
done
