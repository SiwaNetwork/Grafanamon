#!/bin/bash

# ShiwaTime Management Platform Backup Script

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/var/backups/shiwatime}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="shiwatime-backup-${TIMESTAMP}"
RETENTION_DAYS=7

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
mkdir -p "${BACKUP_DIR}"

print_info "Starting backup process..."

# Change to platform directory
cd "$(dirname "$0")/.."

# Stop services to ensure data consistency
print_info "Stopping services..."
cd docker && docker-compose stop

# Create backup directory structure
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"

# Backup Docker volumes
print_info "Backing up Docker volumes..."
docker run --rm \
    -v shiwatime-platform_postgres-data:/postgres:ro \
    -v shiwatime-platform_prometheus-data:/prometheus:ro \
    -v shiwatime-platform_grafana-data:/grafana:ro \
    -v shiwatime-platform_redis-data:/redis:ro \
    -v "${BACKUP_DIR}/${BACKUP_NAME}":/backup \
    alpine tar -czf /backup/volumes.tar.gz /postgres /prometheus /grafana /redis

# Backup configuration files
print_info "Backing up configuration files..."
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}/config.tar.gz" \
    ../config/ \
    ../grafana/ \
    ../prometheus/ \
    docker-compose.yml \
    ../.env 2>/dev/null || true

# Export PostgreSQL database
print_info "Exporting PostgreSQL database..."
docker-compose run --rm postgres pg_dump -U shiwatime shiwatime > "${BACKUP_DIR}/${BACKUP_NAME}/database.sql"

# Start services again
print_info "Starting services..."
docker-compose start

# Create final archive
print_info "Creating final backup archive..."
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}/"
rm -rf "${BACKUP_NAME}"

# Clean old backups
print_info "Cleaning old backups (older than ${RETENTION_DAYS} days)..."
find "${BACKUP_DIR}" -name "shiwatime-backup-*.tar.gz" -mtime +${RETENTION_DAYS} -delete

# Calculate backup size
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)

print_info "Backup completed successfully!"
print_info "Backup location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
print_info "Backup size: ${BACKUP_SIZE}"