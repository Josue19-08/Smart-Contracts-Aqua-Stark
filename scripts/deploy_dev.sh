#!/bin/bash

# Deploy script for Aqua Stark contracts to local devnet
# Usage: ./scripts/deploy_dev.sh

set -e

echo "Building contracts..."
sozo build

echo "Migrating world..."
# Read config from dojo_dev.toml and pass as environment variables
export STARKNET_RPC_URL="http://localhost:5050/"
export DOJO_ACCOUNT_ADDRESS="0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec"
export DOJO_PRIVATE_KEY="0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912"
sozo migrate

echo "Deployment complete!"

