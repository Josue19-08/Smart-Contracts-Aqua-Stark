#!/bin/bash

# Deploy script for Aqua Stark contracts to local devnet
# Usage: ./scripts/deploy_dev.sh

set -e

echo "Building contracts..."
sozo build

echo "Migrating world..."
sozo migrate --config dojo_dev.toml

echo "Deployment complete!"

