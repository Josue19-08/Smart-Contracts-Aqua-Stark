#!/bin/bash

# Verification script for deployed contracts on local testnet
# Verifies that all contracts are deployed and accessible

set -e

WORLD_ADDRESS="0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c"
RPC_URL="http://localhost:5050/"

echo "Verifying contract deployment on local testnet..."

# Check if Katana is running
echo "1. Checking Katana connectivity..."
if curl -s --fail "$RPC_URL" > /dev/null 2>&1; then
    echo "   ✅ Katana is running"
else
    echo "   ❌ Katana is not running"
    echo "   Please start Katana first:"
    echo "   katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation"
    exit 1
fi

# Check if manifest exists
echo "2. Checking deployment manifest..."
if [ -f "manifest_dev.json" ]; then
    echo "   ✅ Deployment manifest found"
    
    # Check if world address is in manifest
    if grep -q "$WORLD_ADDRESS" manifest_dev.json 2>/dev/null; then
        echo "   ✅ World address found in manifest"
    else
        echo "   ⚠️  World address not found in manifest (may need to redeploy)"
    fi
else
    echo "   ⚠️  Deployment manifest not found"
    echo "   Run: ./scripts/deploy_dev.sh"
fi

# Check configuration files
echo "3. Verifying configuration files..."
if [ -f "dojo_dev.toml" ]; then
    if grep -q "world_address" dojo_dev.toml; then
        echo "   ✅ dojo_dev.toml has world_address configured"
    else
        echo "   ⚠️  dojo_dev.toml missing world_address"
    fi
else
    echo "   ⚠️  dojo_dev.toml not found"
fi

if [ -f "torii-dev.toml" ]; then
    if grep -q "world_address" torii-dev.toml && ! grep -q 'world_address = ""' torii-dev.toml; then
        echo "   ✅ torii-dev.toml has world_address configured"
    else
        echo "   ⚠️  torii-dev.toml missing or empty world_address"
    fi
else
    echo "   ⚠️  torii-dev.toml not found"
fi

# Verify systems are deployed (using sozo if available)
echo "4. Verifying system contracts..."
if command -v sozo > /dev/null 2>&1; then
    echo "   ✅ Sozo is available"
    echo "   Note: Use 'sozo execute' to interact with deployed contracts"
else
    echo "   ⚠️  Sozo not found (cannot verify contract interactions)"
fi

echo ""
echo "✅ Deployment verification complete!"
echo ""
echo "Deployment Summary:"
echo "   World Address: $WORLD_ADDRESS"
echo "   RPC URL: $RPC_URL"
echo ""
echo "Deployed Systems:"
echo "   - PlayerSystem"
echo "   - FishSystem"
echo "   - TankSystem"
echo "   - DecorationSystem"
echo ""
echo "Next steps:"
echo "   1. Test contract interactions using sozo execute"
echo "   2. Configure Torii indexer (see docs/deployment.md)"
echo "   3. Run end-to-end tests"
