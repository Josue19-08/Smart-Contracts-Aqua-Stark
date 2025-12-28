# Architecture Overview

## Project Organization

The Aqua Stark Smart Contracts project follows a modular architecture based on the Entity Component System (ECS) pattern provided by the Dojo framework.

## Directory Structure

### `src/models/`

Contains ECS models (Dojo components) that define the data structure of game entities:
- **Player**: Represents a player with address, total_xp, fish_count, tournaments_won, reputation, offspring_created
- **Fish**: Represents a fish with id, owner, state (FishState enum), dna, xp, last_fed_at, is_ready_to_breed, parent_ids, species
- **Tank**: Represents a tank with id, owner, capacity
- **Decoration**: Represents a decoration with id, owner, kind (DecorationKind enum), xp_multiplier, is_active
- **Counters**: FishCounter, TankCounter, DecorationCounter for unique ID generation

Each model is defined as a struct with the `#[dojo::model]` decorator and must derive `Drop`, `Copy`, and `Serde`. See [models.md](models.md) for detailed documentation.

### `src/systems/`

Contains the game logic systems that operate on models. Each system has its own directory with a `contracts.cairo` file:
- **player/contracts.cairo**: Handles player registration (register_player), queries, and XP updates
- **fish/contracts.cairo**: Manages fish operations (mint_fish, breed_fish, feed_fish_batch, gain_xp, set_ready_to_breed, queries, family tree)
- **tank/contracts.cairo**: Handles tank creation (mint_tank) and queries
- **decoration/contracts.cairo**: Manages decorations (mint_decoration, activate_decoration, deactivate_decoration, get_xp_multiplier, queries)

Each system consists of:
- An interface (`#[starknet::interface]`) defining function signatures
- A contract implementation (`#[dojo::contract]`) with the actual logic

See [functions.md](functions.md) for detailed function documentation.

### `src/libs/`

Shared helper functions used across multiple systems:
- **dna_utils**: DNA manipulation functions for fish genetics

### `src/constants/`

Global game configuration constants:
- **game_config**: Defines game-wide settings like limits, thresholds, etc.

### `src/utils/`

Utility functions for common operations:
- **error_helpers**: Error handling, validation, and error formatting

### Entry Points

- **lib.cairo**: Main library entry point that exports all modules
- **main.cairo**: Optional entry point for additional initialization logic

## Model-System Relationship

```
Models (Data)              Systems (Logic)
├── Player          →      systems/player/contracts.cairo
├── Fish            →      systems/fish/contracts.cairo
├── Tank            →      systems/tank/contracts.cairo
└── Decoration      →      systems/decoration/contracts.cairo
```

Systems read and write models to implement game logic. The Dojo framework provides the infrastructure for managing entity-model relationships.

## Data Flow

1. **Write Operation**: Systems write model data using Dojo's world state
2. **Read Operation**: Systems read model data to check current state
3. **Event Emission**: Systems emit events for off-chain indexing via Torii
4. **Indexing**: Torii indexes events and provides real-time state to clients

## Directory Structure

```
contracts/
├── src/
│   ├── models/              # Dojo models (ECS components)
│   │   ├── player.cairo
│   │   ├── fish.cairo
│   │   ├── tank.cairo
│   │   └── decoration.cairo
│   ├── systems/             # Game logic systems
│   │   ├── player/
│   │   │   └── contracts.cairo
│   │   ├── fish/
│   │   │   └── contracts.cairo
│   │   ├── tank/
│   │   │   └── contracts.cairo
│   │   └── decoration/
│   │       └── contracts.cairo
│   ├── libs/                # Shared helper functions
│   ├── constants/           # Game constants
│   ├── utils/               # Utility functions
│   └── lib.cairo            # Main entry point
```

## Dependencies

- **Dojo Framework**: Provides ECS infrastructure and world state management
- **Starknet**: Underlying blockchain infrastructure
- **Cairo Standard Library**: Basic language utilities

## Future Extensions

As the project evolves, additional models and systems can be added following the same modular pattern. Each new feature should:
1. Define its model(s) in `models/`
2. Implement its system(s) in `systems/<system_name>/contracts.cairo`
3. Use shared utilities from `libs/` and `utils/`
4. Reference constants from `constants/`
5. Export modules in `lib.cairo`

