#!/bin/bash

# Verification script for Katana local testnet
# Checks if Katana is running and accessible

set -e

KATANA_RPC_URL="http://localhost:5050/"

echo "Verifying Katana local testnet..."

# Check if Katana is running
echo "1. Checking if Katana is running..."
if curl -s --fail "$KATANA_RPC_URL" > /dev/null 2>&1; then
    echo "   ✅ Katana is running and accessible at $KATANA_RPC_URL"
else
    echo "   ❌ Katana is not running or not accessible"
    echo "   Please start Katana with:"
    echo "   katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation"
    exit 1
fi

# Check RPC endpoint
echo "2. Testing RPC endpoint..."
if curl -s --fail "$KATANA_RPC_URL" > /dev/null 2>&1; then
    echo "   ✅ RPC endpoint is responding"
else
    echo "   ❌ RPC endpoint is not responding"
    exit 1
fi

# Check configuration
echo "3. Verifying configuration..."
if [ -f "dojo_dev.toml" ]; then
    if grep -q "rpc_url = \"http://localhost:5050/\"" dojo_dev.toml; then
        echo "   ✅ dojo_dev.toml is configured correctly"
    else
        echo "   ⚠️  dojo_dev.toml RPC URL may be incorrect"
    fi
else
    echo "   ⚠️  dojo_dev.toml not found"
fi

echo ""
echo "✅ Katana verification complete!"
echo "   Katana is ready for contract deployment."
echo ""
echo "Next steps:"
echo "   1. Deploy contracts: ./scripts/deploy_dev.sh"
echo "   2. Or manually: sozo build && sozo migrate"

