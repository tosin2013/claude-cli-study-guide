#!/bin/bash

# Start the Docusaurus site locally for testing
# This script assumes you're in the root of the project

echo "Starting local Docusaurus development server..."
echo "---------------------------------------------"

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Temporarily set baseUrl for local development
echo "Setting up for local development..."
sed -i.bak 's|baseUrl: '\''/claude-cli-study-guide/'\''|baseUrl: '\''/'\''|g' ./docusaurus.config.js

# Start the development server
echo "Starting development server..."
echo "The site will be available at http://localhost:3000/"
echo "Press Ctrl+C to stop the server"
echo "---------------------------------------------"

npm start 

# After server is stopped with Ctrl+C, restore the baseUrl for production
echo "Restoring production configuration..."
mv ./docusaurus.config.js.bak ./docusaurus.config.js