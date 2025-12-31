use starknet::ContractAddress;
use aqua_stark::models::decoration::{Decoration, DecorationKind};

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
    fn get_decorations_by_owner(self: @TContractState, address: ContractAddress) -> core::array::Array<Decoration>;
    fn get_decoration(self: @TContractState, deco_id: u32) -> Decoration;
    fn activate_decoration(ref self: TContractState, deco_id: u32);
}

// Decoration system contract implementation
#[dojo::contract]
mod DecorationSystem {
    use super::{IDecorationSystem, DECORATION_COUNTER_KEY, PLANT_MULTIPLIER, STATUE_MULTIPLIER, BACKGROUND_MULTIPLIER, ORNAMENT_MULTIPLIER};
    use dojo::model::ModelStorage;
    use starknet::{ContractAddress, get_caller_address};
    use core::array::ArrayTrait;
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

        // Returns all decorations owned by the address
        // Searches all decorations and collects those matching the owner
        fn get_decorations_by_owner(self: @ContractState, address: ContractAddress) -> core::array::Array<Decoration> {
            let world = self.world(@"aqua_stark");

            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address');

            // Initialize result array
            let mut result: core::array::Array<Decoration> = ArrayTrait::new();

            // Get current decoration count to know search range
            let counter: DecorationCounter = world.read_model(DECORATION_COUNTER_KEY);
            let max_id = counter.count;

            // Search all decorations and collect those owned by this address
            let mut current_id = 1;
            while current_id <= max_id {
                let decoration: Decoration = world.read_model(current_id);
                
                // Check if this decoration belongs to the address
                let decoration_owner_felt: felt252 = decoration.owner.into();
                if decoration_owner_felt == address_felt {
                    ArrayTrait::append(ref result, decoration);
                }

                current_id = current_id + 1;
            }

            result
        }

        // Returns a specific decoration by ID
        fn get_decoration(self: @ContractState, deco_id: u32) -> Decoration {
            let world = self.world(@"aqua_stark");

            // Validate deco_id is non-zero
            assert(deco_id != 0, 'Invalid deco_id');

            // Read decoration from world by ID
            let decoration: Decoration = world.read_model(deco_id);

            // Return the decoration (if it doesn't exist, returns default values)
            decoration
        }

        // Activates a decoration, making it apply its XP multiplier bonus
        // When activated, the decoration's xp_multiplier contributes to the total multiplier calculation
        fn activate_decoration(ref self: ContractState, deco_id: u32) {
            let mut world = self.world(@"aqua_stark");

            // Validate deco_id is non-zero
            assert(deco_id != 0, 'Invalid deco_id');

            // Get caller address to validate ownership
            let caller = get_caller_address();

            // Read decoration from world
            let mut decoration: Decoration = world.read_model(deco_id);

            // Validate ownership - decoration must belong to caller
            let decoration_owner_felt: felt252 = decoration.owner.into();
            let caller_felt: felt252 = caller.into();
            assert(decoration_owner_felt == caller_felt, 'Not owner');

            // Set is_active = true
            decoration.is_active = true;

            // Update Decoration component in Dojo world
            world.write_model(@decoration);
        }
    }
}
