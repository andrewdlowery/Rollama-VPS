#!/bin/bash

echo "=== GitHub Runner Status ==="
docker-compose ps github-runner

echo ""
echo "=== PROD Status ==="
docker-compose ps | grep prod

echo ""
echo "=== STAGING Status ==="
docker-compose ps | grep staging

echo ""
echo "=== Logs (последние 50 строк) ==="
docker logs --tail 50 github-runner