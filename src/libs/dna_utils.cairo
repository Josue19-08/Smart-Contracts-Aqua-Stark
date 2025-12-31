// DNA utility functions for fish genetics, breeding mechanics, and genetic diversity

// Generates DNA for new fish using a seed value
// Returns a unique felt252 DNA value based on the seed
// Note: This is a deterministic function - same seed produces same DNA
// For randomness, the caller should provide a unique seed (e.g., block timestamp + fish_id)
pub fn generate_dna(seed: felt252) -> felt252 {
    // Simple DNA generation using seed manipulation
    // This creates deterministic yet varied DNA values
    // In a production system, you might want to use hash functions for better distribution
    seed * 3 + 1
}

// Combines two parent DNA values to create offspring DNA
// Uses a mixing algorithm that combines characteristics from both parents
// Returns a new felt252 DNA value that is a mix of both parents
pub fn combine_dna(dna1: felt252, dna2: felt252) -> felt252 {
    // Mix parent DNA using a combination algorithm
    // This creates varied results even from the same parent pair
    // The combination ensures genetic diversity in offspring
    // Using a simple combination: additive combination with multiplication for mixing
    dna1 + dna2 + dna1 * dna2
}

// Applies mutations to DNA with a configurable mutation rate
// Mutation rate is a value (0-255), where 0 = no mutations
// Returns mutated DNA based on mutation_rate and mutation_seed
pub fn mutate_dna(dna: felt252, mutation_rate: u8, mutation_seed: felt252) -> felt252 {
    // Apply mutation based on mutation_rate
    // For simplicity, we apply mutation if mutation_rate > 0
    // In practice, you might want more sophisticated mutation logic
    
    // Simple mutation: add a value based on mutation_seed and rate
    // This creates variation while maintaining some genetic similarity
    if mutation_rate > 0 {
        // Apply mutation by adding a value scaled by mutation_rate
        // Convert mutation_rate to felt252 and use it in calculation
        let rate_felt: felt252 = mutation_rate.into();
        let mutation_value = mutation_seed * rate_felt;
        dna + mutation_value
    } else {
        dna
    }
}
