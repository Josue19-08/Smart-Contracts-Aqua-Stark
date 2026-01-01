#!/bin/bash
# =============================================================================
# Aqua Stark - Sepolia Testnet Deployment Script
# =============================================================================
# This script deploys Aqua Stark contracts to Starknet Sepolia testnet.
# It reads configuration from .env file.
# =============================================================================

set -e

echo "============================================"
echo "  Aqua Stark - Sepolia Testnet Deployment"
echo "============================================"
echo ""

# -----------------------------------------------------------------------------
# Load environment variables
# -----------------------------------------------------------------------------

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found!"
    echo ""
    echo "To create it:"
    echo "  1. Copy .env.example to .env:"
    echo "     cp .env.example .env"
    echo ""
    echo "  2. Edit .env with your actual values"
    echo ""
    exit 1
fi

# Load .env file (excluding empty DOJO_WORLD_ADDRESS for fresh deploy)
set -a
source "$ENV_FILE"
set +a

# Unset DOJO_WORLD_ADDRESS if empty (for fresh deployment)
if [ -z "$DOJO_WORLD_ADDRESS" ]; then
    unset DOJO_WORLD_ADDRESS
fi

# -----------------------------------------------------------------------------
# Validate required variables
# -----------------------------------------------------------------------------

echo "Validating configuration..."
echo ""

MISSING_VARS=0

if [ -z "$STARKNET_RPC_URL" ]; then
    echo "  Error: STARKNET_RPC_URL is not set"
    MISSING_VARS=1
fi

if [ -z "$DOJO_ACCOUNT_ADDRESS" ] || [ "$DOJO_ACCOUNT_ADDRESS" = "0xYOUR_ACCOUNT_ADDRESS_HERE" ]; then
    echo "  Error: DOJO_ACCOUNT_ADDRESS is not set or still has placeholder value"
    MISSING_VARS=1
fi

if [ -z "$DOJO_PRIVATE_KEY" ] || [ "$DOJO_PRIVATE_KEY" = "0xYOUR_PRIVATE_KEY_HERE" ]; then
    echo "  Error: DOJO_PRIVATE_KEY is not set or still has placeholder value"
    MISSING_VARS=1
fi

if [ $MISSING_VARS -eq 1 ]; then
    echo ""
    echo "Please update your .env file with the correct values."
    echo "See .env.md for documentation."
    exit 1
fi

echo "Configuration loaded:"
echo "  RPC URL: $STARKNET_RPC_URL"
echo "  Account: $DOJO_ACCOUNT_ADDRESS"
echo ""

# -----------------------------------------------------------------------------
# Build contracts
# -----------------------------------------------------------------------------

echo "Step 1: Building contracts..."
echo "--------------------------------------------"
sozo build --profile sepolia
echo ""

# -----------------------------------------------------------------------------
# Deploy to Sepolia
# -----------------------------------------------------------------------------

echo "Step 2: Deploying to Sepolia testnet..."
echo "--------------------------------------------"
echo "This may take several minutes due to network confirmation times..."
echo ""

# sozo reads these environment variables automatically:
# - STARKNET_RPC_URL
# - DOJO_ACCOUNT_ADDRESS
# - DOJO_PRIVATE_KEY
# Use --profile sepolia to read dojo_sepolia.toml configuration
sozo migrate --profile sepolia

echo ""
echo "============================================"
echo "  Deployment Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Copy the world address from above"
echo "  2. Update .env with: DOJO_WORLD_ADDRESS=0x..."
echo ""
echo "To interact with contracts:"
echo "  source .env"
echo "  sozo execute PlayerSystem register_player --calldata \$DOJO_ACCOUNT_ADDRESS"
echo ""
echo "View on Starkscan:"
echo "  https://sepolia.starkscan.co/contract/WORLD_ADDRESS"
echo ""
