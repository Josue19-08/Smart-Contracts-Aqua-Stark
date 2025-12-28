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

1. Ensure you have the required tools installed (see `.tool-versions`)
2. Install dependencies: `scarb build`
3. Review the documentation in the `docs/` directory
4. Start implementing models and systems according to the roadmap

## Version Requirements

- Dojo package: 1.8.0 (auto-downloaded)
- Sozo: 1.8.4
- Cairo: 2.14.0
- Scarb: 2.14.0

See [VERSIONS.md](VERSIONS.md) for detailed version information and rationale.

## Development

This is a base structure with no implemented logic. All files contain TODO comments indicating where implementation should begin. Follow the architecture and standards defined in the documentation.

