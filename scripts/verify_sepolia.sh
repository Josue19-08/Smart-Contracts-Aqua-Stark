#!/bin/bash
# =============================================================================
# Aqua Stark - Sepolia Deployment Verification Script
# =============================================================================
# Verifies that contracts are deployed and accessible on Sepolia testnet.
# Reads configuration from .env file.
# =============================================================================

set -e

echo "============================================"
echo "  Aqua Stark - Sepolia Verification"
echo "============================================"
echo ""

# -----------------------------------------------------------------------------
# Load environment variables
# -----------------------------------------------------------------------------

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found!"
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

# -----------------------------------------------------------------------------
# Display configuration
# -----------------------------------------------------------------------------

echo "Configuration:"
echo "  RPC URL: $STARKNET_RPC_URL"
echo "  Account: $DOJO_ACCOUNT_ADDRESS"
echo "  World:   ${DOJO_WORLD_ADDRESS:-"(not set)"}"
echo ""

# -----------------------------------------------------------------------------
# Verify RPC connection
# -----------------------------------------------------------------------------

echo "Verifying RPC connection..."
echo "--------------------------------------------"

RPC_CHECK=$(curl -s -X POST "$STARKNET_RPC_URL" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"starknet_chainId","params":[],"id":1}')

if echo "$RPC_CHECK" | grep -q "SN_SEPOLIA\|0x534e5f5345504f4c4941"; then
    echo "  RPC connection: OK (Sepolia testnet)"
else
    echo "  RPC connection: FAILED"
    echo "  Response: $RPC_CHECK"
    exit 1
fi
echo ""

# -----------------------------------------------------------------------------
# Verify world contract (if set)
# -----------------------------------------------------------------------------

if [ -n "$DOJO_WORLD_ADDRESS" ] && [ "$DOJO_WORLD_ADDRESS" != "" ]; then
    echo "Verifying world contract..."
    echo "--------------------------------------------"

    WORLD_CHECK=$(curl -s -X POST "$STARKNET_RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{
            "jsonrpc":"2.0",
            "method":"starknet_getClassHashAt",
            "params":{"block_id":"latest","contract_address":"'"$DOJO_WORLD_ADDRESS"'"},
            "id":1
        }')

    if echo "$WORLD_CHECK" | grep -q "result"; then
        echo "  World contract: DEPLOYED"
        CLASS_HASH=$(echo "$WORLD_CHECK" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
        echo "  Class hash: $CLASS_HASH"
    else
        echo "  World contract: NOT FOUND"
        echo "  Response: $WORLD_CHECK"
    fi
    echo ""

    echo "Block explorers:"
    echo "  Starkscan: https://sepolia.starkscan.co/contract/$DOJO_WORLD_ADDRESS"
    echo "  Voyager:   https://sepolia.voyager.online/contract/$DOJO_WORLD_ADDRESS"
else
    echo "World address not set. Run deployment first:"
    echo "  ./scripts/deploy_sepolia.sh"
fi

echo ""
echo "============================================"
echo "  Verification Complete"
echo "============================================"
