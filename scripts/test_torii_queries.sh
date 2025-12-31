#!/bin/bash

# Test script for Torii GraphQL queries
# Tests various GraphQL queries to verify Torii indexing

set -e

TORII_URL="http://localhost:8080/graphql"

echo "Testing Torii GraphQL queries..."
echo ""

# Check if Torii is running
if ! curl -s --fail "http://localhost:8080" > /dev/null 2>&1; then
    echo "❌ Torii is not running"
    echo "Please start Torii first: ./scripts/start_torii.sh"
    exit 1
fi

echo "✅ Torii is running"
echo ""

# Test 1: Basic GraphQL query
echo "1. Testing basic GraphQL query..."
RESPONSE=$(curl -s -X POST "$TORII_URL" \
    -H "Content-Type: application/json" \
    -d '{"query": "{ __typename }"}')
echo "   Response: $RESPONSE"
echo ""

# Test 2: Query models
echo "2. Querying models..."
RESPONSE=$(curl -s -X POST "$TORII_URL" \
    -H "Content-Type: application/json" \
    -d '{"query": "{ models { edges { node { __typename } } } }"}')
echo "   Response: $RESPONSE"
echo ""

# Test 3: Query entities (if available)
echo "3. Querying entities..."
RESPONSE=$(curl -s -X POST "$TORII_URL" \
    -H "Content-Type: application/json" \
    -d '{"query": "{ entities { edges { node { keys models { edges { node { __typename } } } } } } }"}')
echo "   Response: $RESPONSE"
echo ""

# Test 4: Query specific entity by key
echo "4. Querying entity by key..."
ACCOUNT_KEY="0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec"
RESPONSE=$(curl -s -X POST "$TORII_URL" \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"{ entities(keys: [\\\"$ACCOUNT_KEY\\\"]) { edges { node { keys models { edges { node { __typename } } } } } } }\"}")
echo "   Response: $RESPONSE"
echo ""

echo "✅ GraphQL query tests complete!"
echo ""
echo "Note: If models/entities are empty, ensure:"
echo "   1. Contracts are deployed"
echo "   2. Contract actions have been executed"
echo "   3. Torii has had time to index events"
echo ""
echo "Check Torii logs for indexing activity."

