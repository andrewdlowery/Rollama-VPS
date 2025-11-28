# Deployment & Setup Guide

This guide covers the installation, database migration, and environment setup for the Production and Staging environments.

## 1. Initial Server Setup

1. Create an SSH Key.
2. Clone the main repository.
3. Create the `.env` file in the root directory.

## 2. Docker Configuration

1. **Prepare Database Directories:**
   Create a `data` folder inside both `mysql_master` and `mysql_slave` directories.

2. **Install Docker & Docker Compose:**
   ```bash
   snap install docker
   apt install docker-compose
   ```

## 3. Database Migration

1. **Copy Backup:**
   Transfer the SQL backup to the MySQL container.
   ```bash
   docker cp db.sql.gz mysql-master:/db.sql.gz
   ```

2. **Import Data:**
   Access the container and restore the database.
   ```bash
   docker exec -it mysql-master /bin/bash
   gunzip < db.sql.gz | mariadb -u root -p mydb
   ```

## 4. Directory Structure & Repositories

Create the project folder structure for **Production** and **Staging**:

### Production
* `application/projects/prod/app`
* `application/projects/prod/api/backend`

### Staging
* `application/projects/staging/app`
* `application/projects/staging/api/backend`

### Cloning Sources
1. Clone the **Application** repository into:
    * `prod/app`
    * `staging/app`
2. Clone the **Laravel Backend** repository into:
    * `prod/api/backend/`
    * `staging/api/backend/`

## 5. Backend Configuration

Perform these steps inside both `prod/api/backend/` and `staging/api/backend/` folders:

1. **Install Dependencies:**
   ```bash
   composer install --ignore-platform-reqs
   ```

2. **Set Permissions:**
   ```bash
   sudo chmod -R o+rw bootstrap/cache 
   sudo chmod -R o+rw storage
   ```

3. **Environment Config:**
   Create a `.env` file and populate it with the necessary environment variables.

## 6. Frontend Application Configuration

In the `prod/app` directory, create the following files:
1. `conn.php`
2. `js/conn.php`

Paste the following connection logic into both files:

```php
<?php

$host = 'db';
$username = 'user';
$password = 'pass';
$database = 'db';

$conn = mysqli_connect($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
```