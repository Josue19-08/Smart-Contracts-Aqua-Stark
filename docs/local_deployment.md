# Local Deployment Guide

Complete guide for deploying Aqua Stark contracts to local Katana testnet.

## Overview

This guide covers the complete deployment process from starting Katana to verifying contract interactions.

## Step 1: Start Katana

Start Katana in a separate terminal:

```bash
katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
```

Keep this terminal open. Katana must be running for all operations.

## Step 2: Verify Katana

Verify Katana is running and accessible:

```bash
./scripts/verify_katana.sh
```

Expected output:
```
✅ Katana is running and accessible at http://localhost:5050/
✅ RPC endpoint is responding
✅ dojo_dev.toml is configured correctly
```

## Step 3: Build Contracts

Build all contracts:

```bash
sozo build
```

This compiles all Cairo contracts and prepares them for deployment.

## Step 4: Deploy Contracts

Deploy the Dojo world and all system contracts:

```bash
./scripts/deploy_dev.sh
```

Or manually:

```bash
export STARKNET_RPC_URL="http://localhost:5050/"
export DOJO_ACCOUNT_ADDRESS="0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec"
export DOJO_PRIVATE_KEY="0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912"
sozo migrate
```

## Step 5: Verify Deployment

Verify all contracts are deployed:

```bash
./scripts/verify_deployment.sh
```

## Deployment Output

After successful deployment, you should see:

```
World deployed at block X and at address 0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c
- Sync resources: 11 classes declared, 11 resources registered
- Sync permissions: 4 permissions synced
- Initialize contracts: 4 contracts initialized
Migration successful
```

## Deployed Contracts

**World Contract**: `0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c`

**System Contracts**:
- PlayerSystem
- FishSystem
- TankSystem
- DecorationSystem

## Configuration Files Updated

After deployment, the following files are updated:

- `dojo_dev.toml`: World address added
- `torii-dev.toml`: World address added
- `manifest_dev.json`: Deployment manifest created

## Test Contract Interactions

### Register a Player

```bash
sozo execute PlayerSystem register_player \
  --world 0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c \
  --account-address 0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec \
  --private-key 0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912 \
  --calldata 0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec
```

### Query Player

```bash
sozo execute PlayerSystem get_player \
  --world 0x06d10bbdbf0b1798c946ed3a07361e86c546eab1af1e2d70fe4d1b17dfd04a5c \
  --calldata 0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec
```

## Troubleshooting

### Deployment Fails

1. **Check Katana is running**: `./scripts/verify_katana.sh`
2. **Check RPC URL**: Should be `http://localhost:5050/`
3. **Check account credentials**: Verify in `dojo_dev.toml`
4. **Rebuild contracts**: `sozo build`

### Contracts Not Accessible

1. **Verify world address**: Check `dojo_dev.toml` and `torii-dev.toml`
2. **Check manifest**: `manifest_dev.json` should exist
3. **Redeploy if needed**: Run `./scripts/deploy_dev.sh` again

### RPC Connection Errors

1. **Restart Katana**: Stop and start Katana again
2. **Check port**: Ensure port 5050 is not in use by another process
3. **Verify network**: `curl http://localhost:5050/`

## Important Notes

- **Katana resets on restart**: All deployed contracts are lost when Katana stops
- **World address changes**: Each deployment generates a new world address
- **Update configuration**: Always update `dojo_dev.toml` and `torii-dev.toml` after deployment
- **No persistence**: Local testnet is ephemeral - perfect for testing

## Next Steps

After successful deployment:
1. Configure Torii indexer (see [deployment.md](deployment.md))
2. Run end-to-end tests
3. Test all system functions
4. Verify contract interactions

## References

- [Katana Setup Guide](katana_setup.md)
- [Dojo Documentation](https://book.dojoengine.org/)
- [Sozo Commands](https://book.dojoengine.org/toolchain/sozo/overview)

