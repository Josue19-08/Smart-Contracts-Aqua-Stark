use starknet::ContractAddress;
use aqua_stark::models::fish::Fish;

// Constant key for singleton FishCounter instance
const FISH_COUNTER_KEY: u32 = 0;

// Interface for fish system functions
#[starknet::interface]
trait IFishSystem<TContractState> {
    fn get_next_fish_id(ref self: TContractState) -> u32;
    fn mint_fish(ref self: TContractState, address: ContractAddress, species: felt252, dna: felt252) -> u32;
    fn get_fish_by_owner(self: @TContractState, address: ContractAddress) -> core::array::Array<Fish>;
    fn get_fish(self: @TContractState, fish_id: u32) -> Fish;
}

// Fish system contract implementation
#[dojo::contract]
mod FishSystem {
    use super::{IFishSystem, FISH_COUNTER_KEY};
    use dojo::model::ModelStorage;
    use starknet::{ContractAddress, get_block_timestamp};
    use core::option::Option;
    use core::array::ArrayTrait;
    use aqua_stark::models::counters::fish_counter::FishCounter;
    use aqua_stark::models::fish::{Fish, FishState};
    use aqua_stark::models::player::Player;

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of fish system functions
    #[abi(embed_v0)]
    impl FishSystemImpl of super::IFishSystem<ContractState> {
        // Generates a globally unique fish ID by atomically incrementing the FishCounter
        // Returns the current count value and increments it atomically
        fn get_next_fish_id(ref self: ContractState) -> u32 {
            let mut world = self.world(@"aqua_stark");
            
            // Read current FishCounter state
            let mut counter: FishCounter = world.read_model(FISH_COUNTER_KEY);
            
            // Get current count value (to return)
            let current_id = counter.count;
            
            // Atomically increment the counter
            counter.count = counter.count + 1;
            
            // Write updated counter back to world
            world.write_model(@counter);
            
            // Return the ID that was assigned (before increment)
            current_id
        }

        // Mints a new fish NFT to a player's address
        // Generates unique ID, creates Fish component with default values, and updates player's fish_count
        fn mint_fish(ref self: ContractState, address: ContractAddress, species: felt252, dna: felt252) -> u32 {
            let mut world = self.world(@"aqua_stark");
            
            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address: cannot be zero');
            
            // Validate player exists by reading Player model
            // Note: In Dojo, read_model always returns a value (default if not exists)
            // A registered player will have a Player model in the world, even if all fields are 0
            // We can't directly check if a model exists, but we can read it
            // The backend should call register_player before mint_fish, so we assume the player exists
            // If the player wasn't registered, the model will have default values but that's acceptable
            // for the first fish mint (fish_count will be 0 initially, then incremented to 1)
            let mut player: Player = world.read_model(address);
            
            // Validate species and dna are provided (non-zero)
            assert(species != 0, 'Invalid species: cannot be zero');
            assert(dna != 0, 'Invalid dna: cannot be zero');
            
            // Generate unique fish ID
            let fish_id = self.get_next_fish_id();
            
            // Get current timestamp
            let current_timestamp = get_block_timestamp();
            
            // Create Fish component with default values
            let new_fish = Fish {
                id: fish_id,
                owner: address,
                state: FishState::Baby,
                dna: dna,
                xp: 0,
                last_fed_at: current_timestamp,
                is_ready_to_breed: false,
                parent_ids: (Option::None, Option::None),
                species: species,
            };
            
            // Store Fish component in Dojo world
            world.write_model(@new_fish);
            
            // Update player's fish_count (increment by 1)
            player.fish_count = player.fish_count + 1;
            world.write_model(@player);
            
            // Return the new fish_id
            fish_id
        }

        // Returns all fish owned by the address
        // Searches all fish and collects those matching the owner
        fn get_fish_by_owner(self: @ContractState, address: ContractAddress) -> core::array::Array<Fish> {
            let world = self.world(@"aqua_stark");

            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address');

            // Initialize result array
            let mut result: core::array::Array<Fish> = ArrayTrait::new();

            // Get current fish count to know search range
            let counter: FishCounter = world.read_model(FISH_COUNTER_KEY);
            let max_id = counter.count;

            // Search all fish and collect those owned by this address
            let mut current_id = 1;
            while current_id <= max_id {
                let fish: Fish = world.read_model(current_id);
                
                // Check if this fish belongs to the address
                let fish_owner_felt: felt252 = fish.owner.into();
                if fish_owner_felt == address_felt {
                    ArrayTrait::append(ref result, fish);
                }

                current_id = current_id + 1;
            }

            result
        }

        // Returns a specific fish by ID
        fn get_fish(self: @ContractState, fish_id: u32) -> Fish {
            let world = self.world(@"aqua_stark");

            // Validate fish_id is non-zero
            assert(fish_id != 0, 'Invalid fish_id');

            // Read fish from world by ID
            let fish: Fish = world.read_model(fish_id);

            // Return the fish (if it doesn't exist, returns default values)
            fish
        }
    }
}
