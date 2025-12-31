#!/bin/bash

# Start Torii indexer for local development
# Usage: ./scripts/start_torii.sh

set -e

echo "Starting Torii indexer..."

# Check if Torii is installed
if ! command -v torii > /dev/null 2>&1; then
    echo "❌ Torii is not installed"
    echo "Install Torii via dojoup:"
    echo "  curl -L https://install.dojoengine.org | bash"
    echo "  dojoup install"
    exit 1
fi

# Check if Katana is running
echo "Checking Katana connectivity..."
if ! curl -s --fail "http://localhost:5050/" > /dev/null 2>&1; then
    echo "❌ Katana is not running"
    echo "Please start Katana first:"
    echo "  katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation"
    exit 1
fi

echo "✅ Katana is running"

# Check if torii-dev.toml exists
if [ ! -f "torii-dev.toml" ]; then
    echo "❌ torii-dev.toml not found"
    echo "Please ensure torii-dev.toml exists in the project root"
    exit 1
fi

# Create .torii directory if it doesn't exist (for database)
mkdir -p .torii

echo "Starting Torii with configuration from torii-dev.toml..."
echo "GraphQL endpoint will be available at: http://localhost:8080"
echo ""
echo "Press Ctrl+C to stop Torii"
echo ""

# Start Torii with configuration file
torii --config torii-dev.toml

