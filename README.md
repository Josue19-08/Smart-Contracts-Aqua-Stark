<img width="2300" height="863" alt="aqua-banner" src="https://github.com/user-attachments/assets/e870b386-093d-4fde-934a-a3d19d180903" />

# Aqua Stark Smart Contracts

Base structure for Aqua Stark Smart Contracts using Cairo 1.0 and Dojo ECS framework.

## Overview

This project provides a clean, modular foundation for developing the Aqua Stark game on Starknet. The architecture follows the Entity Component System (ECS) pattern implemented by the Dojo framework.

## Project Structure

```
contracts/
├── src/
│   ├── models/          # Dojo models (ECS components: Player, Fish, Tank, Decoration)
│   ├── systems/         # Game logic systems
│   │   ├── player/
│   │   │   └── contracts.cairo
│   │   ├── fish/
│   │   │   └── contracts.cairo
│   │   ├── tank/
│   │   │   └── contracts.cairo
│   │   └── decoration/
│   │       └── contracts.cairo
│   ├── libs/            # Shared helper functions
│   ├── constants/       # Global game constants
│   ├── utils/           # Utility functions (errors, validation)
│   ├── lib.cairo        # Main entry point
│   └── main.cairo       # Optional entry point
├── Scarb.toml           # Cairo package configuration
├── dojo_dev.toml        # Dojo development configuration
├── torii_dev.toml       # Torii indexer configuration
└── katana.toml          # Katana local testnet configuration

docs/
├── architecture.md      # Architecture documentation
├── standards.md         # Coding standards
├── responses.md         # Response format standards
├── models.md            # Model documentation (Player, Fish, Tank, Decoration)
├── functions.md         # Functions and systems documentation
└── roadmap.md           # Development roadmap with detailed issues
```

## Getting Started

1. **Install Dojo tools** (see [versions.md](docs/versions.md)):
   ```bash
   curl -L https://install.dojoengine.org | bash
   dojoup install
   ```

2. **Install dependencies**:
   ```bash
   scarb build
   ```

3. **Setup Katana local testnet** (see [katana_setup.md](docs/katana_setup.md)):
   ```bash
   katana --dev --dev.seed 0 --dev.no-fee --dev.no-account-validation
   ```

4. **Deploy contracts** (see [deployment.md](docs/deployment.md)):
   ```bash
   ./scripts/deploy_dev.sh
   ```

5. Review the documentation in the `docs/` directory
6. Start implementing models and systems according to the roadmap

## Version Requirements

- Dojo package: 1.8.0 (auto-downloaded)
- Sozo: 1.8.4
- Cairo: 2.14.0
- Scarb: 2.14.0

See [VERSIONS.md](VERSIONS.md) for detailed version information and rationale.

