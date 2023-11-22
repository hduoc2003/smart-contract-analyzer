#!/bin/bash

# Chạy nginx
nginx

# Chạy server
gunicorn -c /app/backend/gunicorn.config.py --chdir /app/backend wsgi:app

# exec "$@"
