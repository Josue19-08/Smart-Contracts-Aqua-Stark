use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;
use aqua_stark::models::fish_counter::FishCounter;

// Constant key for singleton FishCounter instance
const FISH_COUNTER_KEY: u32 = 0;

// Interface for fish system functions
#[starknet::interface]
trait IFishSystem<TContractState> {
    fn get_next_fish_id(ref self: TContractState) -> u32;
}

// Fish system contract implementation
#[dojo::contract]
mod FishSystem {
    use super::{IFishSystem, FISH_COUNTER_KEY};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use starknet::ContractAddress;
    use aqua_stark::models::fish_counter::FishCounter;

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of fish system functions
    #[abi(embed_v0)]
    impl FishSystemImpl = super::IFishSystem<ContractState>;

    #[generate_trait]
    impl InternalImpl = Internal<ContractState>;

    impl Internal<TContractState> {
        // Internal function to get world dispatcher
        fn _world(self: @TContractState) -> IWorldDispatcher {
            self.world_dispatcher.read()
        }
    }

    #[abi(embed_v0)]
    impl FishSystem<ContractState> of super::IFishSystem<ContractState> {
        // Generates a globally unique fish ID by atomically incrementing the FishCounter
        // Returns the current count value and increments it atomically
        fn get_next_fish_id(ref self: ContractState) -> u32 {
            let world = self._world();
            
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
    }
}
