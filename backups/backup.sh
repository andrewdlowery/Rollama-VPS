#!/bin/bash

# Load variables from .env
if [ -f ../.env ]; then
    set -a
    source ../.env
    set +a
else
    echo "Error: .env file not found!"
    exit 1
fi

# Backup parameters
BACKUP_DIR="./backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql.gz"
LOG_FILE="$BACKUP_DIR/backup.log"

# MySQL parameters
MYSQL_HOST="mysql-master"
MYSQL_PORT="3306"

# Number of days after which old backups will be deleted
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Remove old backups
echo "$(date '+%Y-%m-%d %H:%M:%S') - Removing backups older than ${RETENTION_DAYS} days..."
find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "$(date '+%Y-%m-%d %H:%M:%S') - Old backups removed."

echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup start"

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

# Run backup in background
docker exec "$MYSQL_HOST" sh -c "mariadb-dump -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE" | gzip > "$BACKUP_FILE" &
BACKUP_PID=$!

# Show spinner while backup is running
spinner $BACKUP_PID

wait $BACKUP_PID
echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup done: $BACKUP_FILE"