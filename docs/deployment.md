# Deployment Guide

## Prerequisites

1. **Install Dojo tools** (if not already installed):
   ```bash
   curl -L https://install.dojoengine.org | bash
   dojoup install
   ```

2. **Verify Katana installation**:
   ```bash
   katana --version
   ```

3. **Start Katana** in a separate terminal:
   ```bash
   katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
   ```

4. **Verify Katana is running**:
   ```bash
   ./scripts/verify_katana.sh
   ```

## Deploy Contracts

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

## Configuration

- **RPC URL**: `http://localhost:5050/` (configured in `dojo_dev.toml`)
- **Account**: Default Katana account (seed = 0)
- **Network**: Local testnet (no fees, instant blocks)

For detailed Katana setup, see [katana_setup.md](katana_setup.md).
