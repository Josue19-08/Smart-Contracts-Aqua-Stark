# Functions Documentation

This document describes all the functions and systems to be implemented in Aqua Stark Smart Contracts. Each function is documented with its purpose, parameters, return values, behavior, and examples.

## Table of Contents

1. [Registration & Initialization](#registration--initialization)
2. [Queries](#queries)
3. [Actions](#actions)
4. [Decorations](#decorations)
5. [Global Counters](#global-counters)
6. [Unique ID Generation](#unique-id-generation)

---

## Registration & Initialization

### register_player

**Description**: Registers a new player on-chain. Creates a Player component with default values.

**Function Signature**:
```cairo
fn register_player(ref self: ContractState, address: ContractAddress);
```

**Parameters**:
- `address` (ContractAddress): The player's Starknet contract address (from Cartridge Controller)

**Returns**: Nothing

**Behavior**:
1. Validates that the player doesn't already exist
2. Creates a Player component with default values:
   - `address` = provided address
   - `total_xp` = 0
   - `fish_count` = 0
   - `tournaments_won` = 0
   - `reputation` = 0
   - `offspring_created` = 0
3. Stores the Player model in the Dojo world

**Validations**:
- Player with this address must not already exist
- Address must be valid (non-zero)

**Example**:
```cairo
// Player logs in via Cartridge Controller
register_player(0x123...abc);
// Player component created with default values
```

---

### mint_fish

**Description**: Mints a new fish NFT to a player's address.

**Function Signature**:
```cairo
fn mint_fish(ref self: ContractState, address: ContractAddress, species: felt252, dna: felt252) -> u32;
```

**Parameters**:
- `address` (ContractAddress): Owner's address
- `species` (felt252): Species identifier (e.g., "Coraline", "Aetherfin") or ID linked off-chain
- `dna` (felt252): Genetic code for the fish

**Returns**: `fish_id` (u32) - The unique ID of the newly minted fish

**Behavior**:
1. Calls `get_next_fish_id()` to generate a unique ID
2. Creates a Fish component with:
   - `id` = generated fish_id
   - `owner` = address
   - `state` = Baby
   - `xp` = 0
   - `last_fed_at` = current timestamp
   - `is_ready_to_breed` = false
   - `parent_ids` = (None, None)
   - `species` = provided species
   - `dna` = provided dna
3. Increments player's `fish_count`
4. Returns the new fish_id

**Validations**:
- Address must be valid
- Species and dna must be provided
- Player must exist

**Example**:
```cairo
let fish_id = mint_fish(player_address, 'Coraline', dna_hash);
// New fish created with id = fish_id, state = Baby
```

---

### mint_tank

**Description**: Mints a new tank NFT to a player's address.

**Function Signature**:
```cairo
fn mint_tank(ref self: ContractState, address: ContractAddress, capacity: u8) -> u32;
```

**Parameters**:
- `address` (ContractAddress): Owner's address
- `capacity` (u8): Maximum number of fish the tank can hold (default: 10)

**Returns**: `tank_id` (u32) - The unique ID of the newly minted tank

**Behavior**:
1. Calls `get_next_tank_id()` to generate a unique ID
2. Creates a Tank component with:
   - `id` = generated tank_id
   - `owner` = address
   - `capacity` = capacity (default: 10)
3. Returns the new tank_id

**Validations**:
- Address must be valid
- Capacity must be > 0
- Player should exist (can be created during registration)

**Example**:
```cairo
let tank_id = mint_tank(player_address, 10);
// New tank created with capacity = 10
```

---

### mint_decoration

**Description**: Mints a new decoration NFT to a player's address.

**Function Signature**:
```cairo
fn mint_decoration(ref self: ContractState, address: ContractAddress, kind: DecorationKind) -> u32;
```

**Parameters**:
- `address` (ContractAddress): Owner's address
- `kind` (DecorationKind): Type of decoration (Plant, Statue, Background, Ornament)

**Returns**: `decoration_id` (u32) - The unique ID of the newly minted decoration

**Behavior**:
1. Calls `get_next_decoration_id()` to generate a unique ID
2. Determines `xp_multiplier` based on decoration kind (e.g., Plant=10%, Statue=15%)
3. Creates a Decoration component with:
   - `id` = generated decoration_id
   - `owner` = address
   - `kind` = provided kind
   - `xp_multiplier` = calculated based on kind
   - `is_active` = false
4. Returns the new decoration_id

**Validations**:
- Address must be valid
- Kind must be valid DecorationKind enum value
- Player should exist

**Example**:
```cairo
let deco_id = mint_decoration(player_address, DecorationKind::Plant);
// New decoration created, is_active = false
```

---

## Queries

### get_tank_by_owner

**Description**: Returns the player's main (first) tank.

**Function Signature**:
```cairo
fn get_tank_by_owner(self: @ContractState, address: ContractAddress) -> Tank;
```

**Parameters**:
- `address` (ContractAddress): Player's address

**Returns**: `Tank` - The first tank owned by the player

**Behavior**:
1. Queries all tanks owned by the address
2. Returns the first tank found (or default if none exists)

**Validations**:
- Address must be valid
- Player should have at least one tank

---

### get_tanks_by_owner

**Description**: Returns all tanks owned by a player.

**Function Signature**:
```cairo
fn get_tanks_by_owner(self: @ContractState, address: ContractAddress) -> Array<Tank>;
```

**Parameters**:
- `address` (ContractAddress): Player's address

**Returns**: `Array<Tank>` - Array of all tanks owned by the player

**Behavior**:
1. Queries all tanks owned by the address
2. Returns array of Tank components

**Validations**:
- Address must be valid

---

### get_tank

**Description**: Returns a specific tank by ID.

**Function Signature**:
```cairo
fn get_tank(self: @ContractState, tank_id: u32) -> Tank;
```

**Parameters**:
- `tank_id` (u32): Tank identifier

**Returns**: `Tank` - The tank component

**Behavior**:
1. Queries the tank by ID from the Dojo world
2. Returns the Tank component

**Validations**:
- Tank with this ID must exist

---

### get_fish_by_owner

**Description**: Returns all fish owned by a player.

**Function Signature**:
```cairo
fn get_fish_by_owner(self: @ContractState, address: ContractAddress) -> Array<Fish>;
```

**Parameters**:
- `address` (ContractAddress): Player's address

**Returns**: `Array<Fish>` - Array of all fish owned by the player

**Behavior**:
1. Queries all fish owned by the address
2. Returns array of Fish components

**Validations**:
- Address must be valid

---

### get_fish

**Description**: Returns a specific fish by ID.

**Function Signature**:
```cairo
fn get_fish(self: @ContractState, fish_id: u32) -> Fish;
```

**Parameters**:
- `fish_id` (u32): Fish identifier

**Returns**: `Fish` - The fish component

**Behavior**:
1. Queries the fish by ID from the Dojo world
2. Returns the Fish component

**Validations**:
- Fish with this ID must exist

---

### get_decorations_by_owner

**Description**: Returns all decorations owned by a player.

**Function Signature**:
```cairo
fn get_decorations_by_owner(self: @ContractState, address: ContractAddress) -> Array<Decoration>;
```

**Parameters**:
- `address` (ContractAddress): Player's address

**Returns**: `Array<Decoration>` - Array of all decorations owned by the player

**Behavior**:
1. Queries all decorations owned by the address
2. Returns array of Decoration components

**Validations**:
- Address must be valid

---

### get_decoration

**Description**: Returns a specific decoration by ID.

**Function Signature**:
```cairo
fn get_decoration(self: @ContractState, deco_id: u32) -> Decoration;
```

**Parameters**:
- `deco_id` (u32): Decoration identifier

**Returns**: `Decoration` - The decoration component

**Behavior**:
1. Queries the decoration by ID from the Dojo world
2. Returns the Decoration component

**Validations**:
- Decoration with this ID must exist

---

### get_player

**Description**: Returns a player's data.

**Function Signature**:
```cairo
fn get_player(self: @ContractState, address: ContractAddress) -> Player;
```

**Parameters**:
- `address` (ContractAddress): Player's address

**Returns**: `Player` - The player component

**Behavior**:
1. Queries the player by address from the Dojo world
2. Returns the Player component

**Validations**:
- Player with this address must exist

---

### get_player_stats

**Description**: Returns a summary of player statistics.

**Function Signature**:
```cairo
fn get_player_stats(self: @ContractState, address: ContractAddress) -> PlayerStats;
```

**Parameters**:
- `address` (ContractAddress): Player's address

**Returns**: `PlayerStats` - Struct containing player statistics summary

**Behavior**:
1. Queries the player component
2. Optionally calculates derived statistics
3. Returns structured stats summary

**Validations**:
- Player with this address must exist

---

### get_fish_family_tree

**Description**: Returns the complete family tree of a fish, including all relatives.

**Function Signature**:
```cairo
fn get_fish_family_tree(self: @ContractState, fish_id: u32) -> FamilyTree;
```

**Parameters**:
- `fish_id` (u32): Fish identifier

**Returns**: `FamilyTree` - Structured result grouped by relation

**Behavior**:
1. Queries the fish by ID
2. Recursively queries parent fish using `parent_ids`
3. Queries siblings (fish with same parents)
4. Queries children (fish where this fish is a parent)
5. Builds family tree structure including:
   - Parents
   - Siblings
   - Children
   - Grandparents
   - Uncles & Aunts
   - Cousins
6. Returns structured result grouped by relation

**Validations**:
- Fish with this ID must exist

**Example Structure**:
```
FamilyTree {
    parents: Array<Fish>,
    siblings: Array<Fish>,
    children: Array<Fish>,
    grandparents: Array<Fish>,
    uncles_aunts: Array<Fish>,
    cousins: Array<Fish>,
}
```

---

## Actions

### feed_fish_batch

**Description**: Feeds multiple fish at once, applying XP bonuses based on active decorations.

**Function Signature**:
```cairo
fn feed_fish_batch(ref self: ContractState, fish_ids: Array<u32>, timestamp: u64);
```

**Parameters**:
- `fish_ids` (Array<u32>): Array of fish IDs to feed
- `timestamp` (u64): Current timestamp for feeding

**Returns**: Nothing

**Behavior**:
1. For each fish_id in the array:
   - Validates ownership (fish must belong to caller)
   - Gets the fish's tank (via owner)
   - Calculates `get_xp_multiplier(tank_id)` to get bonus percentage
   - Calculates base XP gain
   - Applies XP with multiplier bonus: `base_xp * (100 + multiplier) / 100`
   - Updates fish `xp` field
   - Updates fish `last_fed_at` to timestamp
2. Optionally triggers evolution checks for each fish

**Validations**:
- All fish must belong to the caller
- All fish must exist
- Timestamp must be valid

**Example**:
```cairo
feed_fish_batch([1, 2, 3], current_timestamp);
// All three fish gain XP with decoration bonuses applied
```

---

### gain_fish_xp

**Description**: Increases XP for a specific fish.

**Function Signature**:
```cairo
fn gain_fish_xp(ref self: ContractState, fish_id: u32, amount: u32);
```

**Parameters**:
- `fish_id` (u32): Fish identifier
- `amount` (u32): Amount of XP to add

**Returns**: Nothing

**Behavior**:
1. Queries the fish by ID
2. Validates ownership
3. Adds `amount` to fish `xp`
4. Checks if XP threshold reached for evolution
5. If threshold reached, updates fish `state` to next stage:
   - Baby → Juvenile (at XP threshold 1)
   - Juvenile → YoungAdult (at XP threshold 2)
   - YoungAdult → Adult (at XP threshold 3)
6. Updates the fish component in the Dojo world

**Validations**:
- Fish must exist
- Fish must belong to caller
- Amount must be > 0

**Example**:
```cairo
gain_fish_xp(fish_id, 50);
// Fish gains 50 XP, may evolve if threshold reached
```

---

### gain_player_xp

**Description**: Increases the player's total XP.

**Function Signature**:
```cairo
fn gain_player_xp(ref self: ContractState, address: ContractAddress, amount: u32);
```

**Parameters**:
- `address` (ContractAddress): Player's address
- `amount` (u32): Amount of XP to add

**Returns**: Nothing

**Behavior**:
1. Queries the player by address
2. Adds `amount` to player `total_xp`
3. Updates the Player component in the Dojo world

**Validations**:
- Player must exist
- Amount must be > 0

**Example**:
```cairo
gain_player_xp(player_address, 100);
// Player's total_xp increases by 100
```

---

### set_ready_to_breed

**Description**: Marks a fish as ready or not ready to breed.

**Function Signature**:
```cairo
fn set_ready_to_breed(ref self: ContractState, fish_id: u32, ready: bool);
```

**Parameters**:
- `fish_id` (u32): Fish identifier
- `ready` (bool): Whether the fish is ready to breed

**Returns**: Nothing

**Behavior**:
1. Queries the fish by ID
2. Validates ownership
3. Validates fish is in Adult state
4. Updates `is_ready_to_breed` flag to `ready`
5. Updates the Fish component in the Dojo world

**Validations**:
- Fish must exist
- Fish must belong to caller
- Fish must be in Adult state
- Fish cannot be set to ready if not Adult

**Example**:
```cairo
set_ready_to_breed(fish_id, true);
// Fish marked as ready to breed (must be Adult)
```

---

### breed_fish

**Description**: Breeds two fish to create a new offspring.

**Function Signature**:
```cairo
fn breed_fish(ref self: ContractState, fish_id1: u32, fish_id2: u32) -> u32;
```

**Parameters**:
- `fish_id1` (u32): First parent fish ID
- `fish_id2` (u32): Second parent fish ID

**Returns**: `fish_id` (u32) - The ID of the newly created offspring

**Behavior**:
1. Validates both fish exist
2. Validates both fish belong to the same owner (caller)
3. Validates both fish are in Adult state
4. Validates both fish have `is_ready_to_breed == true`
5. Generates new `fish_id` using `get_next_fish_id()`
6. Generates mixed DNA from parents using DNA combination utilities
7. Derives or combines species from parents
8. Creates new Fish component with:
   - `id` = new fish_id
   - `owner` = same as parents
   - `state` = Baby
   - `xp` = 0
   - `last_fed_at` = current timestamp
   - `is_ready_to_breed` = false
   - `parent_ids` = (Some(fish_id1), Some(fish_id2))
   - `species` = combined/derived from parents
   - `dna` = mixed DNA from parents
9. Increments player's `offspring_created` counter
10. Increments player's `fish_count`
11. Optionally sets both parents' `is_ready_to_breed = false` (cooldown)
12. Returns the new fish_id

**Validations**:
- Both fish must exist
- Both fish must belong to caller
- Both fish must be in Adult state
- Both fish must have `is_ready_to_breed == true`
- Fish must be different (cannot breed with itself)

**Example**:
```cairo
let offspring_id = breed_fish(parent1_id, parent2_id);
// New fish created with mixed DNA from parents
// Player's offspring_created counter increases
```

---

## Decorations

### activate_decoration

**Description**: Activates a decoration, making it apply its XP multiplier bonus.

**Function Signature**:
```cairo
fn activate_decoration(ref self: ContractState, deco_id: u32);
```

**Parameters**:
- `deco_id` (u32): Decoration identifier

**Returns**: Nothing

**Behavior**:
1. Queries the decoration by ID
2. Validates ownership
3. Sets `is_active = true`
4. Updates the Decoration component in the Dojo world
5. The decoration's `xp_multiplier` now affects `get_xp_multiplier()` calculations

**Validations**:
- Decoration must exist
- Decoration must belong to caller

**Example**:
```cairo
activate_decoration(deco_id);
// Decoration is now active, applying XP bonus to tank
```

---

### deactivate_decoration

**Description**: Deactivates a decoration, removing its XP multiplier bonus.

**Function Signature**:
```cairo
fn deactivate_decoration(ref self: ContractState, deco_id: u32);
```

**Parameters**:
- `deco_id` (u32): Decoration identifier

**Returns**: Nothing

**Behavior**:
1. Queries the decoration by ID
2. Validates ownership
3. Sets `is_active = false`
4. Updates the Decoration component in the Dojo world
5. The decoration's `xp_multiplier` no longer affects calculations

**Validations**:
- Decoration must exist
- Decoration must belong to caller

**Example**:
```cairo
deactivate_decoration(deco_id);
// Decoration is now inactive, bonus removed
```

---

### get_xp_multiplier

**Description**: Calculates the total XP multiplier from all active decorations owned by the tank's owner.

**Function Signature**:
```cairo
fn get_xp_multiplier(self: @ContractState, tank_id: u32) -> u8;
```

**Parameters**:
- `tank_id` (u32): Tank identifier

**Returns**: `u8` - Total multiplier percentage (e.g., 25 = +25%)

**Behavior**:
1. Queries the tank by ID
2. Gets the tank owner's address
3. Queries all decorations owned by that address
4. Filters decorations where `is_active == true`
5. Sums all `xp_multiplier` values
6. Returns the total multiplier

**Validations**:
- Tank must exist

**Example**:
```cairo
let multiplier = get_xp_multiplier(tank_id);
// Returns sum of all active decorations' multipliers
// E.g., if 3 decorations are active with 10%, 5%, 10%, returns 25
```

---

## Global Counters

### FishCounter Model

**Description**: Global counter tracking the total number of fish created. Used for generating unique fish IDs.

**Code Structure**:
```cairo
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct FishCounter {
    pub count: u32,
}
```

**Purpose**: Maintains a globally unique counter for fish IDs.

---

### TankCounter Model

**Description**: Global counter tracking the total number of tanks created. Used for generating unique tank IDs.

**Code Structure**:
```cairo
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct TankCounter {
    pub count: u32,
}
```

**Purpose**: Maintains a globally unique counter for tank IDs.

---

### DecorationCounter Model

**Description**: Global counter tracking the total number of decorations created. Used for generating unique decoration IDs.

**Code Structure**:
```cairo
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct DecorationCounter {
    pub count: u32,
}
```

**Purpose**: Maintains a globally unique counter for decoration IDs.

---

## Unique ID Generation

### get_next_fish_id

**Description**: Generates a globally unique fish ID by atomically incrementing the FishCounter.

**Function Signature**:
```cairo
fn get_next_fish_id(ref self: ContractState) -> u32;
```

**Returns**: `u32` - The next unique fish ID

**Behavior**:
1. Reads the current FishCounter count
2. Returns the current count value
3. Increments FishCounter count atomically
4. Ensures thread-safe ID generation

**Validations**:
- FishCounter must be initialized (can start at 0 or 1)

**Example**:
```cairo
let fish_id = get_next_fish_id();
// Returns 1, then next call returns 2, etc.
```

---

### get_next_tank_id

**Description**: Generates a globally unique tank ID by atomically incrementing the TankCounter.

**Function Signature**:
```cairo
fn get_next_tank_id(ref self: ContractState) -> u32;
```

**Returns**: `u32` - The next unique tank ID

**Behavior**:
1. Reads the current TankCounter count
2. Returns the current count value
3. Increments TankCounter count atomically
4. Ensures thread-safe ID generation

**Validations**:
- TankCounter must be initialized (can start at 0 or 1)

**Example**:
```cairo
let tank_id = get_next_tank_id();
// Returns 1, then next call returns 2, etc.
```

---

### get_next_decoration_id

**Description**: Generates a globally unique decoration ID by atomically incrementing the DecorationCounter.

**Function Signature**:
```cairo
fn get_next_decoration_id(ref self: ContractState) -> u32;
```

**Returns**: `u32` - The next unique decoration ID

**Behavior**:
1. Reads the current DecorationCounter count
2. Returns the current count value
3. Increments DecorationCounter count atomically
4. Ensures thread-safe ID generation

**Validations**:
- DecorationCounter must be initialized (can start at 0 or 1)

**Example**:
```cairo
let deco_id = get_next_decoration_id();
// Returns 1, then next call returns 2, etc.
```

---

## Error Handling

All functions should implement proper error handling:

- **Ownership Validation**: Functions that modify data must verify the caller owns the resource
- **State Validation**: Functions must verify entities are in the correct state (e.g., Adult for breeding)
- **Existence Validation**: Functions must verify entities exist before operating on them
- **Input Validation**: Functions must validate input parameters are within acceptable ranges

Error codes should be defined in `utils/error_helpers.cairo` and used consistently across all functions.

---

## Implementation Notes

- All functions operate on Dojo models stored in the Dojo world
- State changes are persisted on-chain
- Functions should emit events for off-chain indexing via Torii
- Gas optimization should be considered for batch operations
- All ID generation must be atomic to prevent collisions
- DNA combination should use cryptographic functions for randomness

