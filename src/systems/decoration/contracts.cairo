use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;
use aqua_stark::models::counters::decoration_counter::DecorationCounter;

// Constant key for singleton DecorationCounter instance
const DECORATION_COUNTER_KEY: u32 = 0;

// Interface for decoration system functions
#[starknet::interface]
trait IDecorationSystem<TContractState> {
    fn get_next_decoration_id(ref self: TContractState) -> u32;
}

// Decoration system contract implementation
#[dojo::contract]
mod DecorationSystem {
    use super::{IDecorationSystem, DECORATION_COUNTER_KEY};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use starknet::ContractAddress;
    use aqua_stark::models::counters::decoration_counter::DecorationCounter;

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of decoration system functions
    #[abi(embed_v0)]
    impl DecorationSystemImpl = super::IDecorationSystem<ContractState>;

    #[generate_trait]
    impl InternalImpl = Internal<ContractState>;

    impl Internal<TContractState> {
        // Internal function to get world dispatcher
        fn _world(self: @TContractState) -> IWorldDispatcher {
            self.world_dispatcher.read()
        }
    }

    #[abi(embed_v0)]
    impl DecorationSystem<ContractState> of super::IDecorationSystem<ContractState> {
        // Generates a globally unique decoration ID by atomically incrementing the DecorationCounter
        // Returns the current count value and increments it atomically
        fn get_next_decoration_id(ref self: ContractState) -> u32 {
            let world = self._world();
            
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
    }
}
