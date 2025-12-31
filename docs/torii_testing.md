# Torii Testing Guide

Quick guide for testing Torii indexer functionality.

## Quick Test

### 1. Verify Torii is Running

```bash
./scripts/verify_torii.sh
```

Expected output:
```
✅ Torii GraphQL endpoint is accessible
✅ Torii health check passed
✅ GraphQL endpoint is responding
```

### 2. Test GraphQL Queries

```bash
./scripts/test_torii_queries.sh
```

### 3. Access GraphQL Playground

Open in browser:
```
http://localhost:8080/graphql
```

Or use World Explorer:
```
https://worlds.dev/torii?url=http%3A%2F%2F127.0.0.1%3A8080%2Fgraphql
```

## Current Status

✅ **Torii is running and responding**
- GraphQL endpoint: `http://localhost:8080/graphql`
- Health endpoint: `http://localhost:8080/health`
- SQL playground: `http://localhost:8080/sql`
- World Explorer: Available via link in Torii logs

✅ **GraphQL queries work**
- Basic queries respond correctly
- Schema is accessible

⚠️ **Models are empty** (expected if no contract actions executed yet)
- Models will populate after executing contract actions
- Torii indexes events in real-time

## Testing Event Indexing

### Prerequisites

1. **Katana running**: `katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation`
2. **Contracts deployed**: `./scripts/deploy_dev.sh`
3. **Torii running**: `./scripts/start_torii.sh`

### Execute Contract Action

Once contracts are deployed and Torii is running, execute actions:

```bash
# Example: Register a player (adjust syntax based on sozo version)
sozo execute PlayerSystem register_player <address> \
  --world <world_address> \
  --account-address <account> \
  --private-key <key>
```

### Verify Indexing

1. **Check Torii logs** - You should see indexing activity
2. **Query GraphQL** - Models should appear after indexing
3. **Use GraphQL Playground** - Interactive query interface

## GraphQL Playground

Access the GraphQL Playground at:
```
http://localhost:8080/graphql
```

This provides an interactive interface to:
- Explore the schema
- Test queries
- View indexed data

## Common Queries

### Query All Models

```graphql
{
  models {
    edges {
      node {
        __typename
      }
    }
  }
}
```

### Query Specific Entity

```graphql
{
  entities(keys: ["0x..."]) {
    models {
      __typename
    }
  }
}
```

## Troubleshooting

### Models Empty

- **Cause**: No contract actions executed yet
- **Solution**: Execute contract actions and wait for indexing

### Torii Not Responding

- **Cause**: Torii not started or crashed
- **Solution**: Restart Torii with `./scripts/start_torii.sh`

### Events Not Indexing

- **Cause**: World address mismatch or Katana not running
- **Solution**: Verify `torii-dev.toml` has correct world address

## Next Steps

1. Execute contract actions to generate events
2. Monitor Torii logs for indexing activity
3. Query indexed data via GraphQL
4. Integrate with frontend application

