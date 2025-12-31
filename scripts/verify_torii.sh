#!/bin/bash

# Verification script for Torii indexer
# Verifies that Torii is running and accessible

set -e

TORII_GRAPHQL_URL="http://localhost:8080"
TORII_HEALTH_ENDPOINT="${TORII_GRAPHQL_URL}/health"

echo "Verifying Torii indexer..."

# Check if Torii GraphQL endpoint is accessible
echo "1. Checking Torii GraphQL endpoint..."
if curl -s --fail "$TORII_GRAPHQL_URL" > /dev/null 2>&1; then
    echo "   ✅ Torii GraphQL endpoint is accessible at $TORII_GRAPHQL_URL"
else
    echo "   ❌ Torii GraphQL endpoint is not accessible"
    echo "   Please ensure Torii is running:"
    echo "     ./scripts/start_torii.sh"
    exit 1
fi

# Check health endpoint if available
echo "2. Checking Torii health..."
if curl -s --fail "$TORII_HEALTH_ENDPOINT" > /dev/null 2>&1; then
    echo "   ✅ Torii health check passed"
else
    echo "   ⚠️  Torii health endpoint not available (may be normal)"
fi

# Check if database exists
echo "3. Checking Torii database..."
if [ -d ".torii" ] && [ -n "$(ls -A .torii 2>/dev/null)" ]; then
    echo "   ✅ Torii database directory exists"
    echo "   Database location: .torii/"
else
    echo "   ⚠️  Torii database directory not found (will be created on first run)"
fi

# Check configuration
echo "4. Verifying configuration..."
if [ -f "torii-dev.toml" ]; then
    if grep -q "world_address" torii-dev.toml && ! grep -q 'world_address = ""' torii-dev.toml; then
        echo "   ✅ torii-dev.toml has world_address configured"
    else
        echo "   ⚠️  torii-dev.toml missing or empty world_address"
    fi
    
    if grep -q "rpc" torii-dev.toml; then
        echo "   ✅ torii-dev.toml has RPC configured"
    else
        echo "   ⚠️  torii-dev.toml missing RPC configuration"
    fi
else
    echo "   ❌ torii-dev.toml not found"
    exit 1
fi

# Test GraphQL query (simple introspection)
echo "5. Testing GraphQL endpoint..."
if curl -s -X POST "$TORII_GRAPHQL_URL" \
    -H "Content-Type: application/json" \
    -d '{"query":"{ __typename }"}' > /dev/null 2>&1; then
    echo "   ✅ GraphQL endpoint is responding"
else
    echo "   ⚠️  GraphQL query test failed (Torii may still be starting)"
fi

echo ""
echo "✅ Torii verification complete!"
echo ""
echo "Torii Status:"
echo "   GraphQL Endpoint: $TORII_GRAPHQL_URL"
echo "   Configuration: torii-dev.toml"
echo "   Database: .torii/"
echo ""
echo "Next steps:"
echo "   1. Query indexed state via GraphQL: curl -X POST $TORII_GRAPHQL_URL -H 'Content-Type: application/json' -d '{\"query\":\"{ ... }\"}'"
echo "   2. Test event indexing by performing contract actions"
echo "   3. Verify events are indexed in Torii"

