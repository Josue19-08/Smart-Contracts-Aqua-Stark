# Katana Local Testnet Setup Guide

This guide explains how to set up and use Katana, Dojo's local Starknet testnet, for local development and testing.

## What is Katana?

Katana is Dojo's local Starknet sequencer that provides a local testing environment without transaction costs. It's perfect for:
- Local development and testing
- Rapid iteration without waiting for testnet confirmations
- Testing without spending real tokens
- Isolated testing environment

## Prerequisites

- Dojo tools installed via `dojoup` (see [versions.md](versions.md))
- Katana should be installed automatically with Dojo tools

## Installation

Katana is installed automatically when you install Dojo tools:

```bash
curl -L https://install.dojoengine.org | bash
dojoup install
```

Verify installation:

```bash
katana --version
```

Expected output: `katana 1.7.0` or similar.

## Configuration

### Katana Configuration File

The project includes a `katana.toml` configuration file with default settings:

- **RPC URL**: `http://localhost:5050/`
- **Dev Mode**: Enabled (no fees, instant blocks)
- **Seed**: `0` (deterministic account generation)
- **Pre-funded Accounts**: 10 accounts

### Dojo Configuration

The `dojo_dev.toml` file is already configured for Katana:

```toml
[env]
rpc_url = "http://localhost:5050/"
account_address = "0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec"
private_key = "0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912"
```

These are the default Katana account credentials (seed = 0).

## Starting Katana

### Basic Start

Start Katana with default settings:

```bash
katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
```

### Using Configuration File

If you have a `katana.toml` file, you can use it (though Katana may not read it directly):

```bash
katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
```

### Recommended Command

For Aqua Stark development, use:

```bash
katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
```

**Important**: Keep Katana running in a separate terminal while developing.

## Verifying Connectivity

### Check RPC Endpoint

Test if Katana is running and accessible:

```bash
curl http://localhost:5050/
```

Or use the verification script:

```bash
./scripts/verify_katana.sh
```

### Check Accounts

Katana creates pre-funded accounts. The default account (katana0) has:
- **Address**: `0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec`
- **Private Key**: `0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912`

You can verify accounts are accessible through the RPC endpoint.

## Test Accounts

Katana creates multiple pre-funded accounts by default. The first account (katana0) is used for deployments:

- **Account 0 (katana0)**: Used for contract deployment
- **Accounts 1-9**: Available for testing

All accounts are pre-funded with test tokens.

## Deployment

Once Katana is running, deploy contracts:

```bash
./scripts/deploy_dev.sh
```

Or manually:

```bash
sozo build
export STARKNET_RPC_URL="http://localhost:5050/"
export DOJO_ACCOUNT_ADDRESS="0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec"
export DOJO_PRIVATE_KEY="0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912"
sozo migrate
```

## Troubleshooting

### Katana Won't Start

1. Check if port 5050 is already in use:
   ```bash
   lsof -i :5050
   ```
2. Kill any existing Katana processes:
   ```bash
   pkill katana
   ```
3. Try starting again

### Connection Refused

- Ensure Katana is running before deploying
- Verify RPC URL is correct: `http://localhost:5050/`
- Check firewall settings

### Account Not Found

- Verify account address matches Katana seed
- Use seed = 0 for default accounts
- Check `dojo_dev.toml` configuration

## Important Notes

- **Katana resets on restart**: All state is lost when Katana stops
- **No persistence**: Katana is ephemeral - perfect for testing
- **No fees**: All transactions are free
- **Instant blocks**: Blocks are generated instantly
- **Deterministic**: Using seed = 0 ensures consistent account addresses

## Next Steps

After Katana is running:
1. Deploy contracts using `./scripts/deploy_dev.sh`
2. Configure Torii indexer (see [deployment.md](deployment.md))
3. Start testing your contracts

## References

- [Dojo Documentation](https://book.dojoengine.org/)
- [Katana GitHub](https://github.com/dojoengine/dojo/tree/main/crates/katana)

