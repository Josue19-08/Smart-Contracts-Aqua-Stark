use starknet::ContractAddress;
use aqua_stark::models::player::Player;

// Interface for player system functions
#[starknet::interface]
trait IPlayerSystem<TContractState> {
    fn register_player(ref self: TContractState, address: ContractAddress);
    fn get_player(self: @TContractState, address: ContractAddress) -> Player;
    fn get_player_stats(self: @TContractState, address: ContractAddress) -> Player;
    fn gain_player_xp(ref self: TContractState, address: ContractAddress, amount: u32);
}

// Player system contract implementation
#[dojo::contract]
mod PlayerSystem {
    use dojo::model::ModelStorage;
    use starknet::ContractAddress;
    use aqua_stark::models::player::Player;

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of player system functions
    #[abi(embed_v0)]
    impl PlayerSystemImpl of super::IPlayerSystem<ContractState> {
        // Registers a new player on-chain with default values
        // Validates address is non-zero and player doesn't already exist
        fn register_player(ref self: ContractState, address: ContractAddress) {
            let mut world = self.world(@"aqua_stark");
            
            // Validate address is non-zero (address key cannot be zero)
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address: cannot be zero');
            
            // Check if player already exists by reading the model
            let existing_player: Player = world.read_model(address);
            
            // Verify if player has been initialized (check if any field indicates existing player)
            // If total_xp > 0 or any other field is non-zero, player already exists
            assert(
                existing_player.total_xp == 0 && 
                existing_player.fish_count == 0 && 
                existing_player.tournaments_won == 0 && 
                existing_player.reputation == 0 && 
                existing_player.offspring_created == 0,
                'Player already registered'
            );
            
            // Create new Player with default values
            let new_player = Player {
                address: address,
                total_xp: 0,
                fish_count: 0,
                tournaments_won: 0,
                reputation: 0,
                offspring_created: 0,
            };
            
            // Write Player to world state
            world.write_model(@new_player);
        }

        // Returns a player's data by address
        fn get_player(self: @ContractState, address: ContractAddress) -> Player {
            let world = self.world(@"aqua_stark");

            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address');

            // Read player from world by address (address is the key)
            let player: Player = world.read_model(address);

            // Return the player (if it doesn't exist, returns default values)
            player
        }

        // Returns a summary of player statistics
        // Since Player already contains all statistics, we return the Player component directly
        fn get_player_stats(self: @ContractState, address: ContractAddress) -> Player {
            let world = self.world(@"aqua_stark");

            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address');

            // Read player from world by address
            let player: Player = world.read_model(address);

            // Return the player (contains all stats: total_xp, fish_count, tournaments_won, reputation, offspring_created)
            player
        }

        // Increases the player's total XP
        // Updates the Player component's total_xp field with the amount provided
        fn gain_player_xp(ref self: ContractState, address: ContractAddress, amount: u32) {
            let mut world = self.world(@"aqua_stark");

            // Validate address is non-zero
            let address_felt: felt252 = address.into();
            assert(address_felt != 0, 'Invalid address');

            // Validate amount is greater than zero
            assert(amount > 0, 'Invalid amount');

            // Read player from world by address
            let mut player: Player = world.read_model(address);

            // Add amount to player's total_xp
            player.total_xp = player.total_xp + amount;

            // Write updated player back to world
            world.write_model(@player);
        }
    }
}
