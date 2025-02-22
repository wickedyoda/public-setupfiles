#!/bin/bash

# Paperless-NGX Installer for Debian 12
# This script installs dependencies, configures the environment, and sets up Paperless-NGX.

set -e

echo "Updating and installing required dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-dev \
    imagemagick fonts-liberation gnupg libpq-dev \
    default-libmysqlclient-dev pkg-config libmagic-dev \
    libzbar0 poppler-utils unpaper ghostscript \
    icc-profiles-free qpdf liblept5 libxml2 pngquant \
    zlib1g tesseract-ocr build-essential python3-setuptools \
    python3-wheel mariadb-client redis-server

# Enable Redis and start it
echo "Configuring Redis..."
sudo systemctl enable redis
sudo systemctl start redis

# Create paperless system user
echo "Creating paperless user..."
sudo adduser paperless --system --home /opt/paperless --group

# Download and install Paperless-NGX
PAPERLESS_VERSION="v1.10.2"
PAPERLESS_URL="https://github.com/paperless-ngx/paperless-ngx/releases/download/${PAPERLESS_VERSION}/paperless-ngx-${PAPERLESS_VERSION}.tar.xz"

echo "Downloading Paperless-NGX ${PAPERLESS_VERSION}..."
cd /opt
sudo -u paperless curl -O -L $PAPERLESS_URL
sudo -u paperless tar -xf "paperless-ngx-${PAPERLESS_VERSION}.tar.xz"
sudo mv "paperless-ngx-${PAPERLESS_VERSION}" /opt/paperless

# Create necessary directories
echo "Creating directories..."
sudo mkdir -p /opt/paperless/media /opt/paperless/data /opt/paperless/consume
sudo chown paperless:paperless /opt/paperless/media /opt/paperless/data /opt/paperless/consume

# Configure Paperless
echo "Configuring Paperless..."
cat <<EOL | sudo tee /opt/paperless/paperless.conf
PAPERLESS_REDIS=redis://localhost:6379
PAPERLESS_DBENGINE=sqlite
PAPERLESS_CONSUMPTION_DIR=/opt/paperless/consume
PAPERLESS_DATA_DIR=/opt/paperless/data
PAPERLESS_MEDIA_ROOT=/opt/paperless/media
PAPERLESS_SECRET_KEY=$(openssl rand -base64 32)
PAPERLESS_OCR_LANGUAGE=eng
PAPERLESS_TIME_ZONE=$(cat /etc/timezone)
EOL

# Install Python dependencies
echo "Installing Python dependencies..."
cd /opt/paperless
sudo -u paperless pip3 install --upgrade pip
sudo -u paperless pip3 install -r requirements.txt

# Initialize Paperless database
echo "Initializing Paperless database..."
cd /opt/paperless/src
sudo -u paperless python3 manage.py migrate

# Create a superuser
echo "Creating Paperless superuser..."
sudo -u paperless python3 manage.py createsuperuser

# Configure ImageMagick for PDF processing
echo "Updating ImageMagick policy..."
sudo sed -i 's|<policy domain="coder" rights="none" pattern="PDF" />|<policy domain="coder" rights="read|write" pattern="PDF" />|' /etc/ImageMagick-6/policy.xml

# Configure systemd services
echo "Setting up systemd services..."
cat <<EOL | sudo tee /etc/systemd/system/paperless-webserver.service
[Unit]
Description=Paperless Webserver
After=network.target redis.service
Requires=redis.service

[Service]
User=paperless
Group=paperless
WorkingDirectory=/opt/paperless/src
ExecStart=/usr/bin/python3 manage.py runserver 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the Paperless services
sudo systemctl daemon-reload
sudo systemctl enable paperless-webserver
sudo systemctl start paperless-webserver

echo "Paperless-NGX setup complete! Access it at http://localhost:8000"