use starknet::ContractAddress;
use aqua_stark::models::tank::Tank;

// Constant key for singleton TankCounter instance
const TANK_COUNTER_KEY: u32 = 0;

// Interface for tank system functions
#[starknet::interface]
trait ITankSystem<TContractState> {
    fn get_next_tank_id(ref self: TContractState) -> u32;
    fn mint_tank(ref self: TContractState, address: ContractAddress, capacity: u8) -> u32;
    fn get_tank_by_owner(self: @TContractState, address: ContractAddress) -> Tank;
    fn get_tanks_by_owner(self: @TContractState, address: ContractAddress) -> core::array::Array<Tank>;
    fn get_tank(self: @TContractState, tank_id: u32) -> Tank;
}

// Tank system contract implementation
#[dojo::contract]
mod TankSystem {
    use super::{ITankSystem, TANK_COUNTER_KEY};
    use dojo::model::ModelStorage;
    use starknet::ContractAddress;
    use core::array::ArrayTrait;
    use aqua_stark::models::counters::tank_counter::TankCounter;
    use aqua_stark::models::tank::Tank;
    use aqua_stark::models::player::Player;

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of tank system functions
    #[abi(embed_v0)]
    impl TankSystemImpl of super::ITankSystem<ContractState> {
        // Generates a globally unique tank ID by atomically incrementing the TankCounter
        // Returns the current count value and increments it atomically
        fn get_next_tank_id(ref self: ContractState) -> u32 {
            let mut world = self.world(@"aqua_stark");
            
            // Read current TankCounter state
            let mut counter: TankCounter = world.read_model(TANK_COUNTER_KEY);
            
            // Get current count value (to return)
            let current_id = counter.count;
            
            // Atomically increment the counter
            counter.count = counter.count + 1;
            
            // Write updated counter back to world
            world.write_model(@counter);
            
            // Return the ID that was assigned (before increment)
            current_id
        }

        // Mints a new tank NFT to a player's address
        // Generates unique ID, creates Tank component with specified capacity, and links it to the player owner
        fn mint_tank(ref self: ContractState, address: ContractAddress, capacity: u8) -> u32 {
            let mut world = self.world(@"aqua_stark");
            
            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address: cannot be zero');
            
            // Validate capacity > 0
            assert(capacity > 0, 'Invalid capacity');
            
            // Validate player exists by reading Player model
            // Note: In Dojo, read_model always returns a value (default if not exists)
            // A registered player will have a Player model in the world
            // The backend should call register_player before mint_tank, so we assume the player exists
            let _player: Player = world.read_model(address);
            
            // Generate unique tank ID
            let tank_id = self.get_next_tank_id();
            
            // Create Tank component with specified capacity
            let new_tank = Tank {
                id: tank_id,
                owner: address,
                capacity: capacity,
            };
            
            // Store Tank component in Dojo world
            world.write_model(@new_tank);
            
            // Return the new tank_id
            tank_id
        }

        // Returns the first tank owned by the address
        // Searches tanks sequentially starting from ID 1 until finding one owned by the address
        fn get_tank_by_owner(self: @ContractState, address: ContractAddress) -> Tank {
            let world = self.world(@"aqua_stark");

            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address');

            // Get current tank count to know search range
            let counter: TankCounter = world.read_model(TANK_COUNTER_KEY);
            let max_id = counter.count;

            // Search for first tank owned by this address
            // Start from ID 1 (tanks are numbered starting from 1)
            let mut current_id = 1;
            while current_id <= max_id {
                let tank: Tank = world.read_model(current_id);
                
                // Check if this tank belongs to the address
                // Compare addresses using felt252 conversion
                let tank_owner_felt: felt252 = tank.owner.into();
                if tank_owner_felt == address_felt {
                    return tank;
                }

                current_id = current_id + 1;
            }

            // If no tank found, return default (should not happen if player has tanks)
            // In production, this could be handled with Option<Tank> or error
            Tank { id: 0, owner: address, capacity: 0 }
        }

        // Returns all tanks owned by the address
        // Searches all tanks and collects those matching the owner
        fn get_tanks_by_owner(self: @ContractState, address: ContractAddress) -> core::array::Array<Tank> {
            let world = self.world(@"aqua_stark");

            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address');

            // Initialize result array
            let mut result: core::array::Array<Tank> = ArrayTrait::new();

            // Get current tank count to know search range
            let counter: TankCounter = world.read_model(TANK_COUNTER_KEY);
            let max_id = counter.count;

            // Search all tanks and collect those owned by this address
            let mut current_id = 1;
            while current_id <= max_id {
                let tank: Tank = world.read_model(current_id);
                
                // Check if this tank belongs to the address
                let tank_owner_felt: felt252 = tank.owner.into();
                if tank_owner_felt == address_felt {
                    ArrayTrait::append(ref result, tank);
                }

                current_id = current_id + 1;
            }

            result
        }

        // Returns a specific tank by ID
        fn get_tank(self: @ContractState, tank_id: u32) -> Tank {
            let world = self.world(@"aqua_stark");

            // Validate tank_id is non-zero
            assert(tank_id != 0, 'Invalid tank_id');

            // Read tank from world by ID
            let tank: Tank = world.read_model(tank_id);

            // Return the tank (if it doesn't exist, returns default values)
            tank
        }
    }
}
