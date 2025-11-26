#!/bin/bash

ENV=${1:-prod}

echo "=== PHP Logs ==="
docker logs -f ${ENV}_php

echo ""
echo "=== Nginx Logs ==="
docker logs -f ${ENV}_nginx

echo ""
echo "=== DB Logs ==="
docker logs -f ${ENV}_db