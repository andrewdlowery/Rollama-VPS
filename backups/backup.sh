#!/bin/bash

# Загружаем переменные из .env
if [ -f ../.env ]; then
    export $(cat ../.env | grep -v '#' | xargs)
else
    echo "Ошибка: файл .env не найден!"
    exit 1
fi

# Параметры бэкапа
BACKUP_DIR="/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"
LOG_FILE="$BACKUP_DIR/backup.log"

# MySQL параметры
MYSQL_HOST="mysql-master"
MYSQL_PORT="3306"

# Количество дней, после которых удалять старые бэкапы
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}

echo "$(date '+%Y-%m-%d %H:%M:%S') - Начало бэкапа" >> $LOG_FILE

# Создаём бэкап
mysqldump -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD \
  --single-transaction \
  --quick \
  --lock-tables=false \
  --events \
  --routines \
  --triggers \
  $MYSQL_DATABASE > $BACKUP_FILE

if [ $? -eq 0 ]; then
    # Архивируем
    gzip $BACKUP_FILE
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Бэкап успешно создан: ${BACKUP_FILE}.gz ($(du -h ${BACKUP_FILE}.gz | cut -f1))" >> $LOG_FILE

    # Удаляем старые бэкапы
    find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Старые бэкапы удалены" >> $LOG_FILE
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ОШИБКА при создании бэкапа!" >> $LOG_FILE
fi