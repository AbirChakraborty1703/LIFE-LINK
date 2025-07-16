#!/bin/bash

# Azure Developer CLI Pre-deployment script
echo "Running pre-deployment setup..."

# Set Node.js version
echo "Setting Node.js version to 20..."
export NODE_VERSION=20

# Install dependencies for backend
echo "Installing backend dependencies..."
cd backend
npm ci --only=production

# Install dependencies for frontend  
echo "Installing frontend dependencies..."
cd ../frontend
npm ci

# Install dependencies for admin
echo "Installing admin dependencies..."
cd ../admin
npm ci

echo "Pre-deployment setup complete!"
