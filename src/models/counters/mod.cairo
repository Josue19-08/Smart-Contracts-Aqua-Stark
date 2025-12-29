// Re-export counters from the counters subdirectory
pub mod counters {
    pub mod fish_counter;
    pub mod tank_counter;
    pub mod decoration_counter;
}

// Re-export for convenience
pub use counters::fish_counter::FishCounter;
pub use counters::tank_counter::TankCounter;
pub use counters::decoration_counter::DecorationCounter;

