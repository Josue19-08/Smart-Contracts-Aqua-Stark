// Global game constants for Aqua Stark

// ============================================================================
// Tank Constants
// ============================================================================

// Default fish capacity per tank
pub const DEFAULT_TANK_CAPACITY: u8 = 10;

// Maximum fish per tank (absolute limit)
pub const MAX_FISH_PER_TANK: u8 = 20;

// ============================================================================
// Fish Constants
// ============================================================================

// Base health value for fish (if health system exists)
pub const BASE_FISH_HEALTH: u32 = 100;

// Minimum XP required for breeding (corresponds to Adult state threshold)
pub const MIN_BREEDING_LEVEL: u32 = 600;

// ============================================================================
// XP Thresholds for Evolution Stages
// ============================================================================

// XP needed to evolve from Baby to Juvenile
pub const XP_THRESHOLD_JUVENILE: u32 = 100;

// XP needed to evolve from Juvenile to YoungAdult
pub const XP_THRESHOLD_YOUNG_ADULT: u32 = 300;

// XP needed to evolve from YoungAdult to Adult
pub const XP_THRESHOLD_ADULT: u32 = 600;

// ============================================================================
// Feeding Constants
// ============================================================================

// Base XP gained per feeding
pub const BASE_FEED_XP: u32 = 10;

// Cooldown between feedings in seconds (if implemented)
pub const FEED_COOLDOWN_SECONDS: u64 = 3600;

// ============================================================================
// Decoration Multiplier Constants
// ============================================================================

// XP multiplier percentage for Plant decorations
pub const DECORATION_MULTIPLIER_PLANT: u8 = 10;

// XP multiplier percentage for Statue decorations
pub const DECORATION_MULTIPLIER_STATUE: u8 = 15;

// XP multiplier percentage for Background decorations
pub const DECORATION_MULTIPLIER_BACKGROUND: u8 = 5;

// XP multiplier percentage for Ornament decorations
pub const DECORATION_MULTIPLIER_ORNAMENT: u8 = 12;

