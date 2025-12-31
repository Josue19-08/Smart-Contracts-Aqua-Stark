# End-to-End Testing Guide

Complete guide for running end-to-end tests on the local testnet.

## Overview

End-to-end tests validate complete user workflows from registration to breeding, ensuring all systems work together correctly in a real environment.

## Prerequisites

1. **Katana running**: `katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation`
2. **Contracts deployed**: `./scripts/deploy_dev.sh`
3. **Torii running**: `./scripts/start_torii.sh`

## Running Tests

Execute the end-to-end test script:

```bash
./scripts/e2e_test.sh
```

## Test Coverage

### 1. Player Registration Flow
- ✅ Register new player
- ✅ Verify player component created
- ✅ Query player data via Torii

### 2. Tank and Decoration Setup
- ✅ Create tank with capacity
- ✅ Mint decorations (Plant, Statue)
- ✅ Activate decorations

### 3. Fish Minting and XP Gain Flow
- ✅ Mint initial fish
- ✅ Feed fish to gain XP
- ✅ Gain XP directly to evolve to Adult state
- ✅ Verify evolution state changes

### 4. Breeding Flow
- ✅ Set fish ready to breed
- ✅ Breed two Adult fish
- ✅ Verify offspring created with correct lineage

### 5. Query Functions Test
- ✅ Query player data
- ✅ Query fish data (by ID and by owner)
- ✅ Query family tree
- ✅ Query tank data
- ✅ Query decorations
- ✅ Query XP multiplier

### 6. Decoration Deactivation Flow
- ✅ Deactivate decorations
- ✅ Verify XP multiplier updates

### 7. Player XP Gain Flow
- ✅ Gain player XP
- ✅ Verify player total_xp updates

### 8. Edge Cases Testing
- ✅ Tank capacity limits
- ✅ Ownership validation (implicit in all operations)

## Test Results

The script provides a summary at the end:
- ✅ Passed: Number of successful tests
- ❌ Failed: Number of failed tests
- 📈 Total: Total number of tests

## Troubleshooting

### Tests Fail with "Transaction error"
- Ensure Katana is running
- Verify contracts are deployed
- Check world address is correct

### Torii Queries Return Empty
- Wait a few seconds for indexing
- Check Torii logs for errors
- Verify Torii is running and connected

### Ownership Validation Errors
- Ensure the account executing transactions owns the resources
- Check that player address matches decoration/fish owners

## Manual Testing

You can also test individual workflows manually:

```bash
# Register player
sozo execute PlayerSystem register_player <address> \
  --world <world_address> \
  --account-address <account> \
  --private-key <key>

# Mint fish
sozo execute FishSystem mint_fish <address> <species> <dna> \
  --world <world_address> \
  --account-address <account> \
  --private-key <key>

# Feed fish
sozo execute FishSystem feed_fish_batch arr:<fish_id> <timestamp> \
  --world <world_address> \
  --account-address <account> \
  --private-key <key>

# Breed fish
sozo execute FishSystem breed_fish <fish_id1> <fish_id2> \
  --world <world_address> \
  --account-address <account> \
  --private-key <key>
```

## Next Steps

After successful end-to-end testing:
1. Document any issues found
2. Fix any bugs discovered
3. Re-run tests to verify fixes
4. Prepare for testnet deployment



