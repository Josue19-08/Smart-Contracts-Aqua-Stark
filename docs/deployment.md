# Deployment Guide

## Deploy Contracts

**Important**: Start Katana first in a separate terminal:

```bash
katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
```

Then deploy:

```bash
./scripts/deploy_dev.sh
```

Or manually:

```bash
sozo build
export STARKNET_RPC_URL="http://localhost:5050/"
sozo migrate --katana-account katana0
```
