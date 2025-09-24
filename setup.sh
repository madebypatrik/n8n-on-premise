#!/bin/bash

# n8n Docker Quick Setup Script
# This script helps users get started quickly with n8n

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

# Welcome message
clear
print_header "Welcome to n8n Docker Setup"
echo
echo "This script will help you set up n8n with Docker in just a few steps!"
echo
print_status "What this script will do:"
echo "  1. Check if Docker is running"
echo "  2. Create your .env configuration file"
echo "  3. Generate secure passwords"
echo "  4. Start n8n for the first time"
echo

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Setup cancelled. You can run this script again anytime."
    exit 0
fi

echo

# Check if Docker is running
print_header "Step 1: Checking Docker"
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running!"
    echo
    print_status "Please:"
    echo "  1. Open Docker Desktop"
    echo "  2. Wait for it to start completely"
    echo "  3. Run this script again"
    exit 1
fi
print_success "Docker is running!"
echo

# Check if .env already exists
print_header "Step 2: Configuration Setup"
if [ -f ".env" ]; then
    print_warning ".env file already exists!"
    echo
    read -p "Do you want to recreate it? This will overwrite your current settings. (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Keeping existing .env file."
        echo
    else
        rm .env
        print_status "Existing .env file removed."
        echo
    fi
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    if [ ! -f ".env.example" ]; then
        print_error ".env.example file not found!"
        exit 1
    fi
    
    print_status "Creating your .env configuration file..."
    
    # Generate secure passwords
    print_status "Generating secure passwords..."
    N8N_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
    
    # Create .env from template
    cp .env.example .env
    
    # Replace placeholder passwords
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/your-secure-password-here/$N8N_PASSWORD/g" .env
        sed -i '' "s/generate-a-secure-password-here/$DB_PASSWORD/g" .env
    else
        # Linux
        sed -i "s/your-secure-password-here/$N8N_PASSWORD/g" .env
        sed -i "s/generate-a-secure-password-here/$DB_PASSWORD/g" .env
    fi
    
    print_success ".env file created with secure passwords!"
    echo
    
    # Show credentials
    print_header "Your n8n Credentials"
    echo -e "${GREEN}Username:${NC} admin"
    echo -e "${GREEN}Password:${NC} $N8N_PASSWORD"
    echo
    print_warning "Please save these credentials! You'll need them to log in."
    echo
    
    read -p "Press Enter to continue..."
    echo
fi

# Ask about port
print_header "Step 3: Port Configuration"
current_port=$(grep "N8N_PORT=" .env | cut -d'=' -f2)
print_status "n8n will be available on port: $current_port"
echo
read -p "Do you want to use a different port? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    read -p "Enter port number (1024-65535): " new_port
    if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1024 ] && [ "$new_port" -le 65535 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/N8N_PORT=$current_port/N8N_PORT=$new_port/g" .env
        else
            sed -i "s/N8N_PORT=$current_port/N8N_PORT=$new_port/g" .env
        fi
        print_success "Port updated to $new_port"
        current_port=$new_port
    else
        print_error "Invalid port number. Using default port $current_port"
    fi
    echo
fi

# Start n8n
print_header "Step 4: Starting n8n"
print_status "Starting n8n containers for the first time..."
echo

if ./scripts/start.sh; then
    echo
    print_success "🎉 n8n is now running!"
    echo
    print_header "Next Steps"
    echo "1. Open your browser and go to: http://localhost:$current_port"
    echo "2. Log in with your credentials (shown above)"
    echo "3. Complete the initial setup wizard"
    echo "4. Start creating your first workflow!"
    echo
    print_header "Useful Commands"
    echo "• Check status:    ./scripts/status.sh"
    echo "• View logs:       ./scripts/logs.sh"
    echo "• Stop n8n:        ./scripts/stop.sh"
    echo "• Restart n8n:     ./scripts/restart.sh"
    echo "• Monitor n8n:     ./scripts/monitor.sh"
    echo "• Update n8n:      ./scripts/update.sh"
    echo
    print_status "Enjoy automating with n8n! 🚀"
else
    echo
    print_error "Failed to start n8n. Please check the logs:"
    echo "./scripts/logs.sh"
    exit 1
fi
