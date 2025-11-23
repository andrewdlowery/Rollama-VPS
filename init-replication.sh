#!/bin/bash

# Загружаем переменные из .env
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
else
    echo "Ошибка: файл .env не найден!"
    exit 1
fi

# Ждём запуска контейнеров
sleep 30

MASTER_CONTAINER="mysql-master"
SLAVE_CONTAINER="mysql-slave"

echo "=== Инициализация MySQL репликации ==="

# Создаём пользователя репликации на master
echo "Создание пользователя репликации на master..."
docker exec $MASTER_CONTAINER mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e \
  "CREATE USER '$MYSQL_REPLICATOR_USER'@'%' IDENTIFIED BY '$MYSQL_REPLICATOR_PASSWORD';"

docker exec $MASTER_CONTAINER mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e \
  "GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_REPLICATOR_USER'@'%';"

docker exec $MASTER_CONTAINER mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e \
  "FLUSH PRIVILEGES;"

# Получаем статус master
echo "Получение статуса master..."
MASTER_STATUS=$(docker exec $MASTER_CONTAINER mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e \
  "SHOW MASTER STATUS\G" | grep -E "File|Position")

echo "Master status:"
echo "$MASTER_STATUS"

# Извлекаем File и Position
MASTER_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

echo "File: $MASTER_FILE"
echo "Position: $MASTER_POS"

# Ждём запуска slave
sleep 10

# Конфигурируем slave
echo "Настройка slave..."
docker exec $SLAVE_CONTAINER mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e \
  "CHANGE MASTER TO \
    MASTER_HOST='mysql-master', \
    MASTER_USER='$MYSQL_REPLICATOR_USER', \
    MASTER_PASSWORD='$MYSQL_REPLICATOR_PASSWORD', \
    MASTER_LOG_FILE='$MASTER_FILE', \
    MASTER_LOG_POS=$MASTER_POS;"

# Стартуем репликацию на slave
docker exec $SLAVE_CONTAINER mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e \
  "START SLAVE;"

# Проверяем статус репликации
sleep 5
echo "=== Статус репликации на slave ==="
docker exec $SLAVE_CONTAINER mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e \
  "SHOW SLAVE STATUS\G"

echo "=== Инициализация завершена ==="