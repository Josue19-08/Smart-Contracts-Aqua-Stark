use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;
use aqua_stark::models::tank_counter::TankCounter;

// Constant key for singleton TankCounter instance
const TANK_COUNTER_KEY: u32 = 0;

// Interface for tank system functions
#[starknet::interface]
trait ITankSystem<TContractState> {
    fn get_next_tank_id(ref self: TContractState) -> u32;
}

// Tank system contract implementation
#[dojo::contract]
mod TankSystem {
    use super::{ITankSystem, TANK_COUNTER_KEY};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use starknet::ContractAddress;
    use aqua_stark::models::tank_counter::TankCounter;

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of tank system functions
    #[abi(embed_v0)]
    impl TankSystemImpl = super::ITankSystem<ContractState>;

    #[generate_trait]
    impl InternalImpl = Internal<ContractState>;

    impl Internal<TContractState> {
        // Internal function to get world dispatcher
        fn _world(self: @TContractState) -> IWorldDispatcher {
            self.world_dispatcher.read()
        }
    }

    #[abi(embed_v0)]
    impl TankSystem<ContractState> of super::ITankSystem<ContractState> {
        // Generates a globally unique tank ID by atomically incrementing the TankCounter
        // Returns the current count value and increments it atomically
        fn get_next_tank_id(ref self: ContractState) -> u32 {
            let world = self._world();
            
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
    }
}
