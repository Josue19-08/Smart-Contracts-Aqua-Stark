# Coding Standards

This document defines the coding standards and conventions for the Aqua Stark Smart Contracts project.

## Naming Conventions

### Files
- Use **kebab-case** for all file names
- Examples: `player.cairo`, `fish_system.cairo`, `dna_utils.cairo`

### Structs and Types
- Use **PascalCase** for struct and type names
- Examples: `Player`, `Fish`, `Tank`, `Decoration`

### Functions
- Use **snake_case** for function names
- Examples: `register_player`, `feed_fish`, `breed_fish`

### Constants
- Use **SCREAMING_SNAKE_CASE** for constants
- Examples: `MAX_FISH_PER_TANK`, `BASE_FISH_HEALTH`

## Comments

- All comments must be in **English**
- Use `// TODO:` comments to mark areas that need implementation
- Add descriptive comments for complex logic
- Document public interfaces and functions

## Code Structure

### Models
```cairo
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct ModelName {
    #[key]
    pub id: felt252,
    // TODO: Define fields
}
```

### Systems
Each system should be in its own directory: `systems/<system_name>/contracts.cairo`

```cairo
#[starknet::interface]
pub trait ISystemName<TContractState> {
    // TODO: Define function signatures
}

#[dojo::contract]
mod system_name {
    // TODO: Implement system logic
    #[abi(embed_v0)]
    impl SystemName = ISystemName<ContractState> {
        // TODO: Implement functions
    }
}
```

## Import Organization

1. Standard library imports
2. Dojo framework imports
3. Local component imports
4. Local system imports
5. Local utility imports

## Error Handling

- Use descriptive error messages
- Define error codes in `error_helpers.cairo`
- Validate inputs before processing

## Code Style

- Use 4 spaces for indentation (Cairo standard)
- Keep functions focused and single-purpose
- Avoid deeply nested code structures
- Group related functionality together

## Documentation

- Document all public interfaces
- Explain complex algorithms
- Include usage examples where helpful
- Keep documentation up to date with code changes

## Testing

- Write tests for all systems
- Test edge cases and error conditions
- Keep tests in separate test files
- Use descriptive test names

## Version Control

- Commit related changes together
- Write clear commit messages
- Follow conventional commit format
- Keep commits focused and atomic

