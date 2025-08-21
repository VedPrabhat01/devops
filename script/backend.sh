#!/bin/bash
# This script is executed on the backend EC2 instance by Terraform.
# It installs Docker and runs the backend application container.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
BACKEND_IMAGE="vedprabhat/assignment-backend:latest"

# --- Install Docker ---
echo "Installing Docker..."
sudo apt-get update -y
sudo apt-get install -y docker.io
# Enable Docker to start on boot and start it now.
sudo systemctl enable docker --now

# --- Deploy Container ---
echo "Cleaning up old backend container if it exists..."
# The '|| true' prevents an error if the container doesn't exist.
sudo docker rm -f backend || true

echo "Pulling latest backend image from Docker Hub..."
sudo docker pull $BACKEND_IMAGE

echo "Starting new backend container..."
# Run the new container, mapping the port.
sudo docker run -d --name backend -p 5000:5000 $BACKEND_IMAGE

echo "Backend deployment complete. Application is running."
