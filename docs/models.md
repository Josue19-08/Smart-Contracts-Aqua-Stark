# Models Documentation

This document describes the detailed models (Dojo ECS components) for entities in the Aqua Stark game. Each model represents the on-chain data structure for game entities.

## Overview

Aqua Stark uses four core models to represent the game state:
- **Player**: Core identity and statistics for each user
- **Fish**: Individual fish with genetics, state, and progression
- **Tank**: Aquarium containers with capacity limits
- **Decoration**: Visual and functional items that provide bonuses

## Player Model

### Description

**English**: Player is the core identity model for users in Aqua Stark. It's created on-chain and linked to their Cartridge Controller account, storing gameplay progress and ownership of in-game assets.

**Español**: Player es el modelo base que representa a cada usuario en Aqua Stark. Se crea on-chain y está vinculado a su cuenta de Cartridge Controller. Guarda el progreso del jugador y las estadísticas globales de su experiencia.

### Code Structure (Cairo/Dojo)

```cairo
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub total_xp: u32,
    pub fish_count: u16,
    pub tournaments_won: u16,
    pub reputation: u16,
    pub offspring_created: u16,
}
```

### Fields Description

- **address** (ContractAddress, key): Unique identifier - the player's Starknet contract address
- **total_xp** (u32): Total experience points accumulated across all fish
- **fish_count** (u16): Current number of fish owned by the player
- **tournaments_won** (u16): Number of tournaments won by the player
- **reputation** (u16): Player's reputation score based on achievements
- **offspring_created** (u16): Total number of fish bred by the player

### Behavior

**English**:
- A player is registered on-chain after logging in with Cartridge Controller
- They receive a starter pack: 1 Tank + 2 Fish (minted to their address)
- `total_xp` increases as their fish level up
- `fish_count` updates on minting, breeding, or death
- `tournaments_won` and `reputation` reflect achievements
- `offspring_created` increases every time the player breeds successfully

**Español**:
- El jugador se registra on-chain luego de iniciar sesión con Cartridge
- Recibe un pack inicial: 1 acuario y 2 peces (NFTs asignados a su cuenta)
- `total_xp` sube a medida que sus peces ganan experiencia
- `fish_count` cambia al criar, recibir o perder peces
- `tournaments_won` y `reputation` reflejan logros dentro del juego
- `offspring_created` se incrementa cada vez que cría exitosamente

### Example Use Case

**English**:
1. Player logs in via Cartridge → backend registers them
2. Their fish level up → total_xp increases
3. They breed two fish → offspring_created becomes 1
4. Later, they win a tournament → tournaments_won += 1

**Español**:
1. El jugador inicia sesión → se crea su entidad
2. Sus peces suben de nivel → total_xp sube
3. Reproduce dos peces → offspring_created = 1
4. Gana un torneo → tournaments_won += 1

## Fish Model

### Description

**English**: Fish is the core model representing each player's fish in Aqua Stark. Every fish is an on-chain NFT with unique genetics, evolution, and behavior traits.

**Español**: Fish es el modelo principal que representa a los peces de cada jugador en Aqua Stark. Cada pez es un NFT on-chain con características genéticas, evolución y comportamiento propio.

### Code Structure (Cairo/Dojo)

```cairo
// FishState Enum
pub enum FishState {
    Baby,
    Juvenile,
    YoungAdult,
    Adult,
}

// Fish Model
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Fish {
    #[key]
    pub id: u32,
    pub owner: ContractAddress,
    pub state: FishState,
    pub dna: felt252,
    pub xp: u32,
    pub last_fed_at: u64,
    pub is_ready_to_breed: bool,
    pub parent_ids: (Option<u32>, Option<u32>),
    pub species: felt252,  // Ej: "Coraline", "Aetherfin", etc. or ID linked OFF-CHAIN
}
```

### Fields Description

- **id** (u32, key): Unique identifier for the fish, generated sequentially
- **owner** (ContractAddress): Address of the player who owns this fish
- **state** (FishState): Current life stage of the fish (Baby, Juvenile, YoungAdult, Adult)
- **dna** (felt252): Genetic code that determines appearance and hidden stats
- **xp** (u32): Current experience points of the fish
- **last_fed_at** (u64): Timestamp of the last time the fish was fed
- **is_ready_to_breed** (bool): Whether the fish is ready for breeding (must be Adult)
- **parent_ids** (Option<u32>, Option<u32>): Tuple containing parent fish IDs if bred, (None, None) if minted
- **species** (felt252): Species identifier (e.g., "Coraline", "Aetherfin") or ID linked off-chain

### FishState Enum

The fish progresses through four life stages:
- **Baby**: Initial state, low XP, cannot breed
- **Juvenile**: First evolution stage
- **YoungAdult**: Second evolution stage
- **Adult**: Final stage, can breed when `is_ready_to_breed == true`

### Behavior

**English**:
- When created, fish starts as Baby, low XP and slightly hungry
- Gains XP when fed or through time-based progression
- Evolves as XP increases: Baby → Juvenile → YoungAdult → Adult
- Once Adult and `is_ready_to_breed == true`, it can breed
- DNA determines appearance and hidden stats
- `parent_ids` tracks genetic lineage (if born via breeding)

**Español**:
- Al ser creado, el pez nace en estado Baby, con hambre baja y sin XP
- Gana XP al ser alimentado y con el tiempo
- Cuando alcanza cierto XP, cambia de estado (evolución)
- Si está en estado Adult y tiene `is_ready_to_breed`, puede reproducirse
- El ADN determina variaciones visuales o estadísticas
- `parent_ids` rastrea herencia genética si fue creado por cría

### Example Use Case

**English**:
1. Player receives two fish (initial mint)
2. Player feeds it → hunger change date, XP increases
3. Reaches Adult, `is_ready_to_breed = true`
4. Can now mate with another adult fish to create offspring

**Español**:
1. Jugador recibe dos peces iniciales
2. Lo alimenta → gana XP y cambia la última fecha de alimentación
3. Llega a Adult, se activa `is_ready_to_breed = true`
4. Puede cruzarse con otro pez adulto para generar una cría

## Tank Model

### Description

**English**: Tank represents the on-chain aquarium where a player's fish live. Each tank is a unique NFT owned by a player, with a limited capacity and potential for decoration or upgrades.

**Español**: Tank representa el acuario on-chain donde viven los peces del jugador. Cada tanque es un NFT único asignado al jugador, con una capacidad limitada y posibilidades de expansión o decoración.

### Code Structure (Cairo/Dojo)

```cairo
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Tank {
    #[key]
    pub id: u32,
    pub owner: ContractAddress,
    pub capacity: u8,
}
```

### Fields Description

- **id** (u32, key): Unique identifier for the tank, generated sequentially
- **owner** (ContractAddress): Address of the player who owns this tank
- **capacity** (u8): Maximum number of fish that can be stored in this tank (default: 10)

### Behavior

**English**:
- A new player gets 1 tank on registration
- `capacity` limits the number of fish that can be stored
- Players can upgrade or unlock more tanks in the future
- Fish minted or bred are assigned to the player's active tank
- Off-chain logic can be used to sort, rename, or rearrange tanks visually

**Español**:
- Al registrarse, el jugador recibe 1 tanque
- `capacity` limita cuántos peces puede tener en ese acuario
- Se pueden añadir nuevos tanques o mejoras
- Los peces nacidos o obtenidos se asignan al tanque activo
- El cliente puede mostrar múltiples tanques y organizarlos visualmente

### Example Use Case

**English**:
1. Player logs in → backend calls mint_tank()
2. Player owns 7 fish → tank still has room
3. When capacity is reached, breeding fails or requires another tank

**Español**:
1. Jugador se registra → backend llama mint_tank()
2. Tiene 7 peces → aún puede agregar más
3. Al llegar a 10, debe liberar espacio o conseguir otro tanque

## Decoration Model

### Description

**English**: Decoration represents visual and functional objects that can be placed in a tank. Each decoration is an NFT owned by a player and may provide gameplay bonuses like XP multipliers.

**Español**: Decoration representa objetos visuales y funcionales que se pueden colocar en el acuario. Cada decoración es un NFT propiedad del jugador y puede otorgar bonificaciones como multiplicadores de XP.

### Code Structure (Cairo/Dojo)

```cairo
// DecorationKind Enum
pub enum DecorationKind {
    Plant,
    Statue,
    Background,
    Ornament,
}

// Decoration Model
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Decoration {
    #[key]
    pub id: u32,
    pub owner: ContractAddress,
    pub kind: DecorationKind,
    pub xp_multiplier: u8,  // Bonus de XP, ej: 10 = +10%
    pub is_active: bool,
}
```

### Fields Description

- **id** (u32, key): Unique identifier for the decoration, generated sequentially
- **owner** (ContractAddress): Address of the player who owns this decoration
- **kind** (DecorationKind): Type of decoration (Plant, Statue, Background, Ornament)
- **xp_multiplier** (u8): Bonus percentage to fish XP (e.g., 10 = +10%)
- **is_active** (bool): Whether this decoration is currently active and applying its bonus

### DecorationKind Enum

Four types of decorations:
- **Plant**: Plant decorations
- **Statue**: Statue decorations
- **Background**: Background decorations
- **Ornament**: Ornament decorations

### Behavior

**English**:
- Players can own multiple decorations
- Only active ones apply bonuses (e.g., `xp_multiplier`)
- Each decoration has a visual type (`kind`)
- Players can toggle which are active in their tank
- Backend or frontend can apply visual changes based on `kind`

**Español**:
- El jugador puede tener varias decoraciones
- Solo las activas aplican sus bonificaciones
- Cada una tiene un tipo visual (`kind`)
- El jugador decide cuáles activar o desactivar
- El frontend muestra cambios visuales según `kind`

### Example Use Case

**English**:
1. Player wins or buys a decoration
2. Player activates it → it gives +15% XP to all fish in that tank
3. Can be swapped for another decoration later

**Español**:
1. Jugador gana o compra una decoración
2. La activa → todos sus peces ganan +15% XP
3. Puede reemplazarla por otra más adelante

## Model Relationships

```
Player
  ├── owns multiple Tanks
  │     ├── contains multiple Fish (limited by capacity)
  │     └── contains multiple Decorations (active ones provide bonuses)
  └── owns multiple Fish
        └── can be placed in Tanks
        └── can breed to create offspring (parent_ids tracked)
```

## Data Integrity Rules

- Each model must have a unique identifier (key field)
- Player ownership must be validated for all operations
- Tank capacity must be enforced (cannot exceed capacity)
- Fish can only be owned by one player
- Decorations can only be owned by one player
- Fish must be in Adult state to breed
- Only active decorations apply xp_multiplier bonuses
- Parent fish IDs are tracked for genetic lineage

## Future Extensions

As the game evolves, additional models may be added:
- Food items
- Special events
- Achievements
- Trading/marketplace items
- Tournament records

Each new model should follow the same Dojo ECS pattern and be documented here.

