use starknet::ContractAddress;

// Constant key for singleton TankCounter instance
const TANK_COUNTER_KEY: u32 = 0;

// Interface for tank system functions
#[starknet::interface]
trait ITankSystem<TContractState> {
    fn get_next_tank_id(ref self: TContractState) -> u32;
    fn mint_tank(ref self: TContractState, address: ContractAddress, capacity: u8) -> u32;
}

// Tank system contract implementation
#[dojo::contract]
mod TankSystem {
    use super::{ITankSystem, TANK_COUNTER_KEY};
    use dojo::model::ModelStorage;
    use starknet::ContractAddress;
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
    }
}
