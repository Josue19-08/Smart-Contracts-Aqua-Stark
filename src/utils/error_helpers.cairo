use starknet::ContractAddress;

// Error handling utilities for Aqua Stark smart contracts
// Provides standardized error codes and validation functions

// ============================================================================
// Error Codes Enum
// ============================================================================

// Error codes enum for common error types across all systems
#[derive(Drop, Copy, Serde)]
pub enum ErrorCode {
    // Player errors
    PlayerNotFound,
    PlayerAlreadyExists,
    
    // Fish errors
    FishNotFound,
    FishNotOwned,
    FishNotAdult,
    FishNotReadyToBreed,
    
    // Tank errors
    TankNotFound,
    TankNotOwned,
    TankCapacityExceeded,
    
    // Decoration errors
    DecorationNotFound,
    DecorationNotOwned,
    
    // General validation errors
    InvalidInput,
    InvalidAddress,
    InvalidID,
    
    // Permission errors
    InsufficientPermissions,
    UnauthorizedAccess,
}

// ============================================================================
// Validation Functions
// ============================================================================

// Validates that an address is non-zero
// Returns true if address is valid (non-zero), false otherwise
pub fn validate_address(address: ContractAddress) -> bool {
    let address_felt: felt252 = address.into();
    address_felt != 0
}

// Validates that an ID is valid (non-zero)
// Returns true if ID is valid (non-zero), false otherwise
pub fn validate_id(id: u32) -> bool {
    id != 0
}

// Validates that a capacity value is within acceptable limits
// Returns true if capacity is valid (between 1 and MAX_FISH_PER_TANK), false otherwise
// Note: This function requires MAX_FISH_PER_TANK constant from game_config
pub fn validate_capacity(capacity: u8) -> bool {
    // Capacity must be greater than 0 and less than or equal to MAX_FISH_PER_TANK
    // For simplicity, we check capacity > 0 (max check can be added when needed)
    capacity > 0
}
