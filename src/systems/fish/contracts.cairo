use starknet::ContractAddress;
use aqua_stark::models::fish::{Fish, FamilyTree};

// Constant key for singleton FishCounter instance
const FISH_COUNTER_KEY: u32 = 0;
// Constant key for singleton DecorationCounter instance
const DECORATION_COUNTER_KEY: u32 = 0;

// Interface for fish system functions
#[starknet::interface]
trait IFishSystem<TContractState> {
    fn get_next_fish_id(ref self: TContractState) -> u32;
    fn mint_fish(ref self: TContractState, address: ContractAddress, species: felt252, dna: felt252) -> u32;
    fn get_fish_by_owner(self: @TContractState, address: ContractAddress) -> core::array::Array<Fish>;
    fn get_fish(self: @TContractState, fish_id: u32) -> Fish;
    fn get_fish_family_tree(self: @TContractState, fish_id: u32) -> FamilyTree;
    fn feed_fish_batch(ref self: TContractState, fish_ids: core::array::Array<u32>, timestamp: u64);
    fn gain_fish_xp(ref self: TContractState, fish_id: u32, amount: u32);
    fn set_ready_to_breed(ref self: TContractState, fish_id: u32, ready: bool);
    fn breed_fish(ref self: TContractState, fish_id1: u32, fish_id2: u32) -> u32;
}

// Fish system contract implementation
#[dojo::contract]
mod FishSystem {
    use super::{IFishSystem, FISH_COUNTER_KEY};
    use dojo::model::ModelStorage;
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use core::option::Option;
    use core::array::ArrayTrait;
    use aqua_stark::models::counters::fish_counter::FishCounter;
    use aqua_stark::models::counters::decoration_counter::DecorationCounter;
    use aqua_stark::models::fish::{Fish, FishState, FamilyTree};
    use aqua_stark::models::player::Player;
    use aqua_stark::models::decoration::Decoration;
    use aqua_stark::constants::game_config::{BASE_FEED_XP, XP_THRESHOLD_JUVENILE, XP_THRESHOLD_YOUNG_ADULT, XP_THRESHOLD_ADULT};

    // Component state
    #[storage]
    struct Storage {}

    // Implementation of fish system functions
    #[abi(embed_v0)]
    impl FishSystemImpl of super::IFishSystem<ContractState> {
        // Generates a globally unique fish ID by atomically incrementing the FishCounter
        // Returns the current count value and increments it atomically
        fn get_next_fish_id(ref self: ContractState) -> u32 {
            let mut world = self.world(@"aqua_stark_0_0_1");
            
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
            let mut world = self.world(@"aqua_stark_0_0_1");
            
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
            let world = self.world(@"aqua_stark_0_0_1");

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
            let world = self.world(@"aqua_stark_0_0_1");

            // Validate fish_id is non-zero
            assert(fish_id != 0, 'Invalid fish_id');

            // Read fish from world by ID
            let fish: Fish = world.read_model(fish_id);

            // Return the fish (if it doesn't exist, returns default values)
            fish
        }

        // Returns the complete family tree of a fish, including all relatives
        // Builds family tree structure with parents, siblings, children, grandparents, uncles/aunts, and cousins
        // Note: Due to Cairo's limitations, this is a simplified implementation that searches iteratively
        fn get_fish_family_tree(self: @ContractState, fish_id: u32) -> FamilyTree {
            let world = self.world(@"aqua_stark_0_0_1");

            // Validate fish_id is non-zero
            assert(fish_id != 0, 'Invalid fish_id');

            // Get the target fish
            let target_fish: Fish = world.read_model(fish_id);

            // Initialize all family tree arrays
            let mut parents = ArrayTrait::new();
            let mut siblings = ArrayTrait::new();
            let mut children = ArrayTrait::new();
            let mut grandparents = ArrayTrait::new();
            let mut uncles_aunts = ArrayTrait::new();
            let mut cousins = ArrayTrait::new();

            // Get current fish count to know search range
            let counter: FishCounter = world.read_model(FISH_COUNTER_KEY);
            let max_id = counter.count;

            // Extract parent IDs
            let (parent1_opt, parent2_opt) = target_fish.parent_ids;

            // Collect parents
            let mut parent1_id = 0;
            let mut parent2_id = 0;
            match parent1_opt {
                Option::Some(id) => {
                    parent1_id = id;
                    let parent1: Fish = world.read_model(id);
                    ArrayTrait::append(ref parents, parent1);
                },
                Option::None => {},
            };
            match parent2_opt {
                Option::Some(id) => {
                    parent2_id = id;
                    let parent2: Fish = world.read_model(id);
                    ArrayTrait::append(ref parents, parent2);
                },
                Option::None => {},
            };

            // Search all fish to find siblings, children, and extended family
            let mut current_id = 1;
            while current_id <= max_id {
                if current_id == fish_id {
                    current_id = current_id + 1;
                    continue;
                }

                let fish: Fish = world.read_model(current_id);
                let (fish_parent1_opt, fish_parent2_opt) = fish.parent_ids;

                // Check if this fish is a sibling (has same parents as target)
                let mut is_sibling_flag = false;
                match fish_parent1_opt {
                    Option::Some(p1) => {
                        match fish_parent2_opt {
                            Option::Some(p2) => {
                                // Both parents match
                                if (p1 == parent1_id && p2 == parent2_id) || (p1 == parent2_id && p2 == parent1_id) {
                                    is_sibling_flag = true;
                                }
                            },
                            Option::None => {},
                        }
                    },
                    Option::None => {},
                }
                if is_sibling_flag {
                    ArrayTrait::append(ref siblings, fish);
                }

                // Check if this fish is a child (has target fish as one of its parents)
                let mut is_child_flag = false;
                match fish_parent1_opt {
                    Option::Some(p1) => {
                        if p1 == fish_id {
                            is_child_flag = true;
                        }
                    },
                    Option::None => {},
                }
                match fish_parent2_opt {
                    Option::Some(p2) => {
                        if p2 == fish_id {
                            is_child_flag = true;
                        }
                    },
                    Option::None => {},
                }
                if is_child_flag {
                    ArrayTrait::append(ref children, fish);
                }

                current_id = current_id + 1;
            }

            // Collect grandparents (parents of parents)
            let mut i = 0;
            let parents_len = parents.len();
            while i < parents_len {
                let parent = *parents.at(i);
                let (gp1_opt, gp2_opt) = parent.parent_ids;
                match gp1_opt {
                    Option::Some(gp_id) => {
                        let grandparent: Fish = world.read_model(gp_id);
                        ArrayTrait::append(ref grandparents, grandparent);
                    },
                    Option::None => {},
                }
                match gp2_opt {
                    Option::Some(gp_id) => {
                        let grandparent: Fish = world.read_model(gp_id);
                        ArrayTrait::append(ref grandparents, grandparent);
                    },
                    Option::None => {},
                }
                i = i + 1;
            }

            // Collect uncles/aunts (siblings of parents)
            // For each parent, find their siblings (these are uncles/aunts of the target fish)
            let mut parent_idx = 0;
            while parent_idx < parents_len {
                let parent = *parents.at(parent_idx);
                let parent_sibling_id = parent.id;
                let (parent_sibling_parent1_opt, parent_sibling_parent2_opt) = parent.parent_ids;

                // Search for siblings of this parent
                let mut current_id2 = 1;
                while current_id2 <= max_id {
                    // Skip target fish, the parent itself, and the other parent
                    if current_id2 == fish_id || current_id2 == parent_sibling_id 
                       || (parent_idx == 0 && current_id2 == parent2_id)
                       || (parent_idx == 1 && current_id2 == parent1_id) {
                        current_id2 = current_id2 + 1;
                        continue;
                    }

                    let fish: Fish = world.read_model(current_id2);
                    let (fish_parent1_opt, fish_parent2_opt) = fish.parent_ids;

                    // Check if this fish is a sibling of the parent (has same parents)
                    let mut is_parent_sibling = false;
                    match fish_parent1_opt {
                        Option::Some(p1) => {
                            match fish_parent2_opt {
                                Option::Some(p2) => {
                                    match parent_sibling_parent1_opt {
                                        Option::Some(pp1) => {
                                            match parent_sibling_parent2_opt {
                                                Option::Some(pp2) => {
                                                    if (p1 == pp1 && p2 == pp2) || (p1 == pp2 && p2 == pp1) {
                                                        is_parent_sibling = true;
                                                    }
                                                },
                                                Option::None => {},
                                            }
                                        },
                                        Option::None => {},
                                    }
                                },
                                Option::None => {},
                            }
                        },
                        Option::None => {},
                    }
                    if is_parent_sibling {
                        ArrayTrait::append(ref uncles_aunts, fish);
                    }

                    current_id2 = current_id2 + 1;
                }

                parent_idx = parent_idx + 1;
            }

            // Collect cousins (children of uncles/aunts)
            // Note: This is simplified - in a full implementation, we'd need to track uncle/aunt IDs
            // For now, we'll collect children of uncles/aunts by checking if their parent is an uncle/aunt
            let mut current_id3 = 1;
            while current_id3 <= max_id {
                if current_id3 == fish_id {
                    current_id3 = current_id3 + 1;
                    continue;
                }

                let fish: Fish = world.read_model(current_id3);
                let (fish_parent1_opt, fish_parent2_opt) = fish.parent_ids;

                // Check if this fish's parent is an uncle/aunt
                let mut is_cousin_flag = false;
                let uncles_aunts_len = uncles_aunts.len();
                let mut j = 0;
                while j < uncles_aunts_len {
                    let uncle_aunt = *uncles_aunts.at(j);
                    match fish_parent1_opt {
                        Option::Some(p1) => {
                            if p1 == uncle_aunt.id {
                                is_cousin_flag = true;
                            }
                        },
                        Option::None => {},
                    }
                    match fish_parent2_opt {
                        Option::Some(p2) => {
                            if p2 == uncle_aunt.id {
                                is_cousin_flag = true;
                            }
                        },
                        Option::None => {},
                    }
                    j = j + 1;
                }
                if is_cousin_flag {
                    ArrayTrait::append(ref cousins, fish);
                }

                current_id3 = current_id3 + 1;
            }

            // Build and return FamilyTree struct
            FamilyTree {
                parents: parents,
                siblings: siblings,
                children: children,
                grandparents: grandparents,
                uncles_aunts: uncles_aunts,
                cousins: cousins,
            }
        }

        // Feeds multiple fish at once, applying XP bonuses based on active decorations
        // For each fish: validates ownership, calculates XP multiplier, applies XP with bonus, updates last_fed_at
        fn feed_fish_batch(ref self: ContractState, fish_ids: core::array::Array<u32>, timestamp: u64) {
            let mut world = self.world(@"aqua_stark_0_0_1");

            // Get caller address to validate ownership
            let caller = get_caller_address();

            // Get fish array length
            let fish_count = fish_ids.len();

            // Process each fish in the batch
            let mut i = 0;
            while i < fish_count {
                let fish_id = *fish_ids.at(i);

                // Validate fish_id is non-zero
                assert(fish_id != 0, 'Invalid fish_id');

                // Read fish from world
                let mut fish: Fish = world.read_model(fish_id);

                // Validate ownership - fish must belong to caller
                let fish_owner_felt: felt252 = fish.owner.into();
                let caller_felt: felt252 = caller.into();
                assert(fish_owner_felt == caller_felt, 'Not owner');

                // Get the owner's address (from fish)
                let owner_address = fish.owner;

                // Calculate XP multiplier from active decorations (inline calculation)
                let mut total_multiplier: u32 = 0;
                let deco_counter: DecorationCounter = world.read_model(0);
                let deco_max_id = deco_counter.count;
                let mut deco_id = 1;
                while deco_id <= deco_max_id {
                    let decoration: Decoration = world.read_model(deco_id);
                    let decoration_owner_felt: felt252 = decoration.owner.into();
                    let owner_felt: felt252 = owner_address.into();
                    if decoration_owner_felt == owner_felt && decoration.is_active {
                        // Convert u8 to u32 for addition
                        let multiplier_u32: u32 = decoration.xp_multiplier.into();
                        total_multiplier = total_multiplier + multiplier_u32;
                    }
                    deco_id = deco_id + 1;
                }

                // Calculate base XP gain (from constants)
                let base_xp = BASE_FEED_XP;

                // Apply XP with multiplier: base_xp * (100 + multiplier) / 100
                let xp_gain = base_xp * (100 + total_multiplier) / 100;

                // Update fish XP
                fish.xp = fish.xp + xp_gain;

                // Update last_fed_at timestamp
                fish.last_fed_at = timestamp;

                // Write updated fish back to world
                world.write_model(@fish);

                i = i + 1;
            }
        }

        // Increases XP for a specific fish and handles evolution state changes
        // When XP reaches thresholds, fish evolves: Baby → Juvenile → YoungAdult → Adult
        fn gain_fish_xp(ref self: ContractState, fish_id: u32, amount: u32) {
            let mut world = self.world(@"aqua_stark_0_0_1");

            // Validate fish_id is non-zero
            assert(fish_id != 0, 'Invalid fish_id');

            // Validate amount is greater than zero
            assert(amount > 0, 'Invalid amount');

            // Get caller address to validate ownership
            let caller = get_caller_address();

            // Read fish from world
            let mut fish: Fish = world.read_model(fish_id);

            // Validate ownership - fish must belong to caller
            let fish_owner_felt: felt252 = fish.owner.into();
            let caller_felt: felt252 = caller.into();
            assert(fish_owner_felt == caller_felt, 'Not owner');

            // Add amount to fish XP
            fish.xp = fish.xp + amount;

            // Check XP thresholds for evolution based on current state
            match fish.state {
                FishState::Baby => {
                    // Check if XP reaches threshold for Juvenile
                    if fish.xp >= XP_THRESHOLD_JUVENILE {
                        fish.state = FishState::Juvenile;
                    }
                },
                FishState::Juvenile => {
                    // Check if XP reaches threshold for YoungAdult
                    if fish.xp >= XP_THRESHOLD_YOUNG_ADULT {
                        fish.state = FishState::YoungAdult;
                    }
                },
                FishState::YoungAdult => {
                    // Check if XP reaches threshold for Adult
                    if fish.xp >= XP_THRESHOLD_ADULT {
                        fish.state = FishState::Adult;
                    }
                },
                FishState::Adult => {
                    // Adult is final stage, no further evolution
                },
            }

            // Write updated fish back to world
            world.write_model(@fish);
        }

        // Marks a fish as ready or not ready to breed
        // Validates that the fish is in Adult state before allowing the flag to be set
        fn set_ready_to_breed(ref self: ContractState, fish_id: u32, ready: bool) {
            let mut world = self.world(@"aqua_stark_0_0_1");

            // Validate fish_id is non-zero
            assert(fish_id != 0, 'Invalid fish_id');

            // Get caller address to validate ownership
            let caller = get_caller_address();

            // Read fish from world
            let mut fish: Fish = world.read_model(fish_id);

            // Validate ownership - fish must belong to caller
            let fish_owner_felt: felt252 = fish.owner.into();
            let caller_felt: felt252 = caller.into();
            assert(fish_owner_felt == caller_felt, 'Not owner');

            // Validate fish is in Adult state
            match fish.state {
                FishState::Adult => {},
                _ => {
                    assert(false, 'Not Adult');
                },
            }

            // Update is_ready_to_breed flag
            fish.is_ready_to_breed = ready;

            // Write updated fish back to world
            world.write_model(@fish);
        }

        // Breeds two fish to create a new offspring
        // Validates prerequisites, generates new fish with mixed DNA from parents, sets parent lineage, and updates player statistics
        fn breed_fish(ref self: ContractState, fish_id1: u32, fish_id2: u32) -> u32 {
            let mut world = self.world(@"aqua_stark_0_0_1");

            // Validate fish IDs are non-zero
            assert(fish_id1 != 0, 'Invalid fish_id1');
            assert(fish_id2 != 0, 'Invalid fish_id2');

            // Validate fish are different (cannot breed with itself)
            assert(fish_id1 != fish_id2, 'Same fish');

            // Get caller address to validate ownership
            let caller = get_caller_address();

            // Read both parent fish from world
            let mut parent1: Fish = world.read_model(fish_id1);
            let mut parent2: Fish = world.read_model(fish_id2);

            // Validate ownership - both fish must belong to caller
            let parent1_owner_felt: felt252 = parent1.owner.into();
            let parent2_owner_felt: felt252 = parent2.owner.into();
            let caller_felt: felt252 = caller.into();
            assert(parent1_owner_felt == caller_felt, 'Not owner 1');
            assert(parent2_owner_felt == caller_felt, 'Not owner 2');

            // Validate both parents are in Adult state
            match parent1.state {
                FishState::Adult => {},
                _ => {
                    assert(false, 'Parent1 not Adult');
                },
            }
            match parent2.state {
                FishState::Adult => {},
                _ => {
                    assert(false, 'Parent2 not Adult');
                },
            }

            // Validate both parents have is_ready_to_breed == true
            assert(parent1.is_ready_to_breed == true, 'Parent1 not ready');
            assert(parent2.is_ready_to_breed == true, 'Parent2 not ready');

            // Get the owner address (same for both parents)
            let owner_address = parent1.owner;

            // Generate new fish_id
            let new_fish_id = self.get_next_fish_id();

            // Generate mixed DNA from parents (basic implementation: additive combination)
            // Note: This is a simplified version - DNA utilities (Issue 8.1) will provide more sophisticated mixing
            // Using addition to combine parent DNA values
            let mixed_dna = parent1.dna + parent2.dna;

            // Derive species from parents (use first parent's species as default)
            // Note: This can be enhanced later with more sophisticated species combination logic
            let offspring_species = parent1.species;

            // Get current timestamp
            let current_timestamp = get_block_timestamp();

            // Create new Fish component with mixed genetics from parents
            let new_fish = Fish {
                id: new_fish_id,
                owner: owner_address,
                state: FishState::Baby,
                dna: mixed_dna,
                xp: 0,
                last_fed_at: current_timestamp,
                is_ready_to_breed: false,
                parent_ids: (Option::Some(fish_id1), Option::Some(fish_id2)),
                species: offspring_species,
            };

            // Store new Fish component in Dojo world
            world.write_model(@new_fish);

            // Update player statistics
            let mut player: Player = world.read_model(owner_address);
            player.offspring_created = player.offspring_created + 1;
            player.fish_count = player.fish_count + 1;
            world.write_model(@player);

            // Set both parents' is_ready_to_breed = false (breeding cooldown)
            parent1.is_ready_to_breed = false;
            parent2.is_ready_to_breed = false;
            world.write_model(@parent1);
            world.write_model(@parent2);

            // Return the new fish_id
            new_fish_id
        }
    }
}
