#!/bin/bash
# This script is executed on the frontend EC2 instance by Terraform.
# It installs Docker and runs the frontend application container.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. Validate Input ---
# Check if the Backend IP address was passed as the first argument.
# If not, print an error and exit. This makes the script safer.
if [ -z "$1" ]; then
  echo "Error: Backend IP address was not provided."
  exit 1
fi

# --- 2. Configuration ---
FRONTEND_IMAGE="vedprabhat/assignment-frontend:latest"
BACKEND_IP="$1"

# --- 3. Install Docker ---
echo "Installing Docker..."
sudo apt-get update -y
sudo apt-get install -y docker.io
# Enable Docker to start on boot and start it now.
sudo systemctl enable docker --now

# --- 4. Deploy Container ---
echo "Cleaning up old frontend container if it exists..."
# The '|| true' prevents an error if the container doesn't exist.
sudo docker rm -f frontend || true

echo "Pulling latest frontend image from Docker Hub..."
sudo docker pull $FRONTEND_IMAGE

echo "Starting new frontend container..."
# Run the new container. The -e flag is the most important part.
sudo docker run -d --name frontend -p 80:80 \
    -e BACKEND_URL="http://${BACKEND_IP}:5000" \
    $FRONTEND_IMAGE

echo "Frontend deployment complete. Application is running."
