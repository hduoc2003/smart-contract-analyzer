#!/bin/bash

# Chạy apache
apache2ctl start

# Chạy server
gunicorn -c /var/www/apache-flask/backend/gunicorn.config.py --chdir /var/www/apache-flask/backend wsgi:app


# exec "$@"
