# Torii Indexer Setup Guide

Complete guide for setting up and configuring Torii, Dojo's world indexer, for local development.

## What is Torii?

Torii is Dojo's indexing service that:
- Indexes Dojo world events in real-time
- Provides GraphQL API for querying indexed state
- Synchronizes world state for frontend/backend integration
- Enables efficient off-chain state management

## Prerequisites

1. **Torii installed** (via `dojoup`):
   ```bash
   curl -L https://install.dojoengine.org | bash
   dojoup install
   ```

2. **Verify Torii installation**:
   ```bash
   torii --version
   ```

3. **Katana running** (see [katana_setup.md](katana_setup.md)):
   ```bash
   katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
   ```

4. **Contracts deployed** (see [deployment.md](deployment.md)):
   ```bash
   ./scripts/deploy_dev.sh
   ```

## Configuration

### Torii Configuration File

The project includes `torii-dev.toml` with the following configuration:

```toml
# World address from deployment
world_address = "0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c"

# RPC endpoint (Katana local testnet)
rpc = "http://localhost:5050"

# Database directory (SQLite for local development)
db_dir = ".torii"

# Events configuration
[events]
raw = true

# Indexing configuration
[indexing]
pending = true
```

**Configuration Options**:
- **world_address**: Address of the deployed Dojo world
- **rpc**: RPC endpoint URL (Katana local: `http://localhost:5050`)
- **db_dir**: Database directory (SQLite database stored in `.torii/`)
- **events.raw**: Enable raw event indexing
- **indexing.pending**: Index pending transactions

## Starting Torii

### Using the Script

Start Torii using the provided script:

```bash
./scripts/start_torii.sh
```

This script:
- Verifies Torii is installed
- Checks Katana is running
- Creates database directory if needed
- Starts Torii with configuration from `torii-dev.toml`

### Manual Start

Start Torii manually:

```bash
torii --config torii-dev.toml
```

Or with explicit parameters:

```bash
torii \
  --world 0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c \
  --rpc http://localhost:5050 \
  --db-dir .torii
```

## Verify Torii

After starting Torii, verify it's running:

```bash
./scripts/verify_torii.sh
```

This script checks:
- Torii GraphQL endpoint accessibility
- Health endpoint status
- Database directory existence
- Configuration file validity
- GraphQL query functionality

## Torii Endpoints

Once Torii is running, the following endpoints are available:

- **GraphQL API**: `http://localhost:8080`
- **Health Check**: `http://localhost:8080/health` (if available)

## Querying Indexed State

### GraphQL Queries

Query indexed state using GraphQL:

```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{
      entities {
        id
        keys
        models {
          __typename
        }
      }
    }"
  }'
```

### Example Queries

**Query all players**:
```graphql
{
  entities(keys: ["0x..."]) {
    id
    models {
      ... on Player {
        address
        total_xp
        fish_count
      }
    }
  }
}
```

**Query all fish**:
```graphql
{
  entities {
    id
    models {
      ... on Fish {
        id
        owner
        state
        xp
      }
    }
  }
}
```

## Testing Event Indexing

1. **Start Torii**:
   ```bash
   ./scripts/start_torii.sh
   ```

2. **Perform contract actions** (in another terminal):
   ```bash
   # Register a player
   sozo execute PlayerSystem register_player \
     --world 0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c \
     --account-address 0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec \
     --private-key 0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912 \
     --calldata 0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec
   ```

3. **Verify events are indexed**:
   ```bash
   # Query via GraphQL
   curl -X POST http://localhost:8080 \
     -H "Content-Type: application/json" \
     -d '{"query": "{ entities { id models { __typename } } }"}'
   ```

## Database

Torii uses SQLite for local development. The database is stored in `.torii/` directory.

**Important Notes**:
- Database is created automatically on first run
- Database persists between Torii restarts
- To reset indexing, delete `.torii/` directory
- Database is gitignored (not committed to repository)

## Troubleshooting

### Torii Not Starting

1. **Check Katana is running**:
   ```bash
   ./scripts/verify_katana.sh
   ```

2. **Check world address**:
   Verify `world_address` in `torii-dev.toml` matches deployed world

3. **Check RPC URL**:
   Ensure `rpc` in `torii-dev.toml` points to running Katana

### GraphQL Endpoint Not Accessible

1. **Check Torii is running**:
   ```bash
   ./scripts/verify_torii.sh
   ```

2. **Check port 8080**:
   Ensure port 8080 is not in use by another process

3. **Check logs**:
   Review Torii output for error messages

### Events Not Indexing

1. **Verify contracts are deployed**:
   ```bash
   ./scripts/verify_deployment.sh
   ```

2. **Check world address**:
   Ensure `world_address` in `torii-dev.toml` is correct

3. **Restart Torii**:
   Stop and restart Torii to re-sync from beginning

### Database Issues

1. **Reset database**:
   ```bash
   rm -rf .torii
   ./scripts/start_torii.sh
   ```

2. **Check permissions**:
   Ensure write permissions for `.torii/` directory

## Integration with Frontend

Torii provides GraphQL API that can be consumed by frontend applications:

```javascript
// Example GraphQL query in JavaScript
const query = `
  {
    entities {
      id
      models {
        ... on Player {
          address
          total_xp
          fish_count
        }
      }
    }
  }
`;

const response = await fetch('http://localhost:8080', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ query })
});

const data = await response.json();
```

## Important Notes

- **Torii must be running** for event indexing to work
- **World address must match** deployed world address
- **Database persists** between restarts (SQLite)
- **GraphQL endpoint** is available at `http://localhost:8080`
- **Reset indexing** by deleting `.torii/` directory

## Next Steps

After Torii is configured and running:
1. Test event indexing with contract interactions
2. Query indexed state via GraphQL
3. Integrate with frontend application
4. Monitor indexing performance

## References

- [Dojo Torii Documentation](https://book.dojoengine.org/toolchain/torii/overview)
- [GraphQL API Reference](https://book.dojoengine.org/toolchain/torii/graphql)
- [Katana Setup Guide](katana_setup.md)
- [Deployment Guide](deployment.md)

