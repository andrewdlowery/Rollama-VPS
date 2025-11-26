#!/bin/bash

ENV=${1:-prod}

echo "Restarting $ENV environment..."
docker-compose restart ${ENV}_php ${ENV}_nginx

sleep 3
docker-compose ps | grep $ENV