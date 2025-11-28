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
9. create projects folder in application directory
   10. in projects folder create 2 folders
       11. prod
           12. in prod create app and api folders
           13. clone application and backend repos
       12. staging
           13. in staging create app and api folders
           14. clone application and backend repos