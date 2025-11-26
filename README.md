1. Create SSH Key
2. Clone Repo
3. Create .env file
4. Create data folder in mysql_master & mysql_slave folder
3. Install Docker
   4. snap install docker
      apt  install docker-compose
5. Copy backup to mysql container
   6. docker cp db.sql.gz mysql-master:/db.sql.gz
   7. docker exec -it mysql-master /bin/bash
   8. gunzip < db.sql.gz | mariadb -u root -p mydb