#!/bin/bash

# ShiwaTime Management Platform Installation Script
# This script installs and configures the ShiwaTime Management Platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Platform information
PLATFORM_NAME="ShiwaTime Management Platform"
VERSION="1.0.0"

# Functions
print_header() {
    echo -e "${GREEN}"
    echo "=============================================="
    echo "   $PLATFORM_NAME"
    echo "   Version: $VERSION"
    echo "=============================================="
    echo -e "${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        print_warning "This script should be run as root or with sudo privileges."
        print_info "Some operations may fail without proper permissions."
    fi
    
    print_info "All prerequisites are met."
}

create_directories() {
    print_info "Creating necessary directories..."
    
    # Create data directories
    mkdir -p data/{postgres,prometheus,grafana,alertmanager,redis}
    mkdir -p logs
    
    # Set permissions
    chmod -R 755 data/
    chmod -R 755 logs/
    
    print_info "Directories created successfully."
}

generate_secrets() {
    print_info "Generating secure passwords..."
    
    # Generate random passwords
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    GRAFANA_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    
    # Create .env file
    cat > .env << EOF
# ShiwaTime Management Platform Environment Variables
# Generated on $(date)

# Database Configuration
DB_PASSWORD=${DB_PASSWORD}

# Grafana Configuration
GRAFANA_PASSWORD=${GRAFANA_PASSWORD}

# Platform Configuration
PLATFORM_NAME=ShiwaTime
ENVIRONMENT=production
EOF
    
    chmod 600 .env
    print_info "Secure passwords generated and saved to .env file."
}

configure_firewall() {
    print_info "Configuring firewall rules..."
    
    # Check if ufw is installed
    if command -v ufw &> /dev/null; then
        # Allow necessary ports
        sudo ufw allow 80/tcp comment "ShiwaTime HTTP" 2>/dev/null || true
        sudo ufw allow 443/tcp comment "ShiwaTime HTTPS" 2>/dev/null || true
        sudo ufw allow 3000/tcp comment "Grafana" 2>/dev/null || true
        sudo ufw allow 8080/tcp comment "ShiwaTime API" 2>/dev/null || true
        sudo ufw allow 9090/tcp comment "Prometheus" 2>/dev/null || true
        
        print_info "Firewall rules configured."
    else
        print_warning "UFW not found. Please configure your firewall manually."
    fi
}

start_platform() {
    print_info "Starting ShiwaTime Management Platform..."
    
    cd docker/
    
    # Use docker-compose or docker compose based on availability
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    cd ..
    
    print_info "Platform started successfully."
}

wait_for_services() {
    print_info "Waiting for services to be ready..."
    
    # Wait for Grafana
    echo -n "Waiting for Grafana..."
    while ! curl -s http://localhost:3000/api/health > /dev/null; do
        echo -n "."
        sleep 2
    done
    echo " Ready!"
    
    # Wait for Prometheus
    echo -n "Waiting for Prometheus..."
    while ! curl -s http://localhost:9090/-/ready > /dev/null; do
        echo -n "."
        sleep 2
    done
    echo " Ready!"
    
    print_info "All services are ready."
}

configure_grafana() {
    print_info "Configuring Grafana..."
    
    # Get Grafana admin password from .env
    source .env
    
    # Change default admin password
    curl -s -X PUT \
        -H "Content-Type: application/json" \
        -d "{\"oldPassword\":\"admin\",\"newPassword\":\"${GRAFANA_PASSWORD}\",\"confirmNew\":\"${GRAFANA_PASSWORD}\"}" \
        http://admin:admin@localhost:3000/api/user/password > /dev/null
    
    print_info "Grafana configured successfully."
}

print_summary() {
    source .env
    
    echo -e "${GREEN}"
    echo "=============================================="
    echo "   Installation Complete!"
    echo "=============================================="
    echo -e "${NC}"
    echo
    echo "Access URLs:"
    echo "  - Grafana Dashboard: http://localhost:3000"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - ShiwaTime API: http://localhost:8080"
    echo
    echo "Credentials:"
    echo "  - Grafana:"
    echo "    Username: admin"
    echo "    Password: ${GRAFANA_PASSWORD}"
    echo
    echo "  - Database:"
    echo "    Username: shiwatime"
    echo "    Password: ${DB_PASSWORD}"
    echo
    echo "Configuration files:"
    echo "  - Environment variables: .env"
    echo "  - Docker Compose: docker/docker-compose.yml"
    echo
    echo "To stop the platform:"
    echo "  cd docker && docker-compose down"
    echo
    echo "To view logs:"
    echo "  cd docker && docker-compose logs -f [service-name]"
    echo
    print_warning "Please save the credentials above in a secure location!"
}

# Main installation flow
main() {
    print_header
    check_prerequisites
    create_directories
    generate_secrets
    configure_firewall
    start_platform
    wait_for_services
    configure_grafana
    print_summary
}

# Run main function
main