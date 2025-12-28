# Response Format Standards

This document defines standard formats for responses, logs, and return values within the Aqua Stark Smart Contracts.

## Success Responses

For successful operations, systems should emit events or return simple success indicators:

```cairo
// Event emission for successful operations
#[event]
#[derive(Drop, starknet::Event)]
enum PlayerEvent {
    PlayerRegistered: PlayerRegistered,
    // ... other events
}
```

## Error Responses

Errors should be handled using descriptive error codes and messages defined in `error_helpers.cairo`:

```cairo
// Error codes (to be defined in error_helpers.cairo)
// ERROR_INVALID_PLAYER = 1
// ERROR_FISH_NOT_FOUND = 2
// ERROR_TANK_FULL = 3
// etc.
```

Errors should be returned as `Result` types or through revert statements with descriptive messages.

## Warning Indicators

For internal code warnings or notes about potential mutations:

```cairo
// ⚠️ This field may mutate on level-up
// Note: This value is calculated dynamically
```

## Event Structure

All system events should follow a consistent structure:

```cairo
#[derive(Drop, starknet::Event)]
struct EventName {
    // Entity identifier
    entity_id: felt252,
    // Event-specific data
    // ...
}
```

## Return Values

- Use `()` for functions that don't return values
- Use specific types for data retrieval functions
- Use `Result<T, E>` pattern where appropriate (when implemented)

## Logging Standards

- Use descriptive event names
- Include all relevant context in event data
- Ensure events are indexable by Torii
- Follow Dojo event emission patterns

## Response Examples

### Success
```cairo
// Emit success event
self.emit(PlayerRegistered { player: player_address });
```

### Error
```cairo
// Return error or revert
assert(player_exists, 'Player not found');
```

### Warning Comment
```cairo
// ⚠️ This operation may fail if tank is at capacity
```

