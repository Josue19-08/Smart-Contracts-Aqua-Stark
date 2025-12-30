use starknet::ContractAddress;
use aqua_stark::models::decoration::DecorationKind;

// Constant key for singleton DecorationCounter instance
const DECORATION_COUNTER_KEY: u32 = 0;

// XP multiplier constants for each decoration kind (percentage values)
const PLANT_MULTIPLIER: u8 = 10;      // Plant = +10%
const STATUE_MULTIPLIER: u8 = 15;     // Statue = +15%
const BACKGROUND_MULTIPLIER: u8 = 5;  // Background = +5%
const ORNAMENT_MULTIPLIER: u8 = 12;   // Ornament = +12%

// Interface for decoration system functions
#[starknet::interface]
trait IDecorationSystem<TContractState> {
    fn get_next_decoration_id(ref self: TContractState) -> u32;
    fn mint_decoration(ref self: TContractState, address: ContractAddress, kind: DecorationKind) -> u32;
}

// Decoration system contract implementation
#[dojo::contract]
mod DecorationSystem {
    use super::{IDecorationSystem, DECORATION_COUNTER_KEY, PLANT_MULTIPLIER, STATUE_MULTIPLIER, BACKGROUND_MULTIPLIER, ORNAMENT_MULTIPLIER};
    use dojo::model::ModelStorage;
    use starknet::ContractAddress;
    use aqua_stark::models::counters::decoration_counter::DecorationCounter;
    use aqua_stark::models::decoration::{Decoration, DecorationKind};
    use aqua_stark::models::player::Player;

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of decoration system functions
    #[abi(embed_v0)]
    impl DecorationSystemImpl of super::IDecorationSystem<ContractState> {
        // Generates a globally unique decoration ID by atomically incrementing the DecorationCounter
        // Returns the current count value and increments it atomically
        fn get_next_decoration_id(ref self: ContractState) -> u32 {
            let mut world = self.world(@"aqua_stark");
            
            // Read current DecorationCounter state
            let mut counter: DecorationCounter = world.read_model(DECORATION_COUNTER_KEY);
            
            // Get current count value (to return)
            let current_id = counter.count;
            
            // Atomically increment the counter
            counter.count = counter.count + 1;
            
            // Write updated counter back to world
            world.write_model(@counter);
            
            // Return the ID that was assigned (before increment)
            current_id
        }

        // Mints a new decoration NFT to a player's address
        // Generates unique ID, sets XP multiplier based on kind, and initializes it as inactive
        fn mint_decoration(ref self: ContractState, address: ContractAddress, kind: DecorationKind) -> u32 {
            let mut world = self.world(@"aqua_stark");
            
            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address: cannot be zero');
            
            // Validate player exists by reading Player model
            // Note: In Dojo, read_model always returns a value (default if not exists)
            // A registered player will have a Player model in the world
            // The backend should call register_player before mint_decoration, so we assume the player exists
            let _player: Player = world.read_model(address);
            
            // Generate unique decoration ID
            let decoration_id = self.get_next_decoration_id();
            
            // Determine XP multiplier based on decoration kind
            let xp_multiplier = match kind {
                DecorationKind::Plant => PLANT_MULTIPLIER,
                DecorationKind::Statue => STATUE_MULTIPLIER,
                DecorationKind::Background => BACKGROUND_MULTIPLIER,
                DecorationKind::Ornament => ORNAMENT_MULTIPLIER,
            };
            
            // Create Decoration component with specified kind and calculated multiplier
            let new_decoration = Decoration {
                id: decoration_id,
                owner: address,
                kind: kind,
                xp_multiplier: xp_multiplier,
                is_active: false,
            };
            
            // Store Decoration component in Dojo world
            world.write_model(@new_decoration);
            
            // Return the new decoration_id
            decoration_id
        }
    }
}
