// Unit tests for Aqua Stark models
// Tests Player, Fish, Tank, and Decoration models

#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use core::option::Option;
    use aqua_stark::models::player::Player;
    use aqua_stark::models::fish::{Fish, FishState};
    use aqua_stark::models::tank::Tank;
    use aqua_stark::models::decoration::{Decoration, DecorationKind};

    // Test constants
    const TEST_FISH_ID: u32 = 1;
    const TEST_DNA: felt252 = 12345;
    const TEST_SPECIES: felt252 = 67890;
    
    // Helper function to create test address
    fn get_test_address() -> ContractAddress {
        starknet::contract_address_const::<0x123>()
    }

    // ============================================================================
    // Player Model Tests
    // ============================================================================

    #[test]
    fn test_player_model_creation() {
        // Test Player model creation with default values
        let test_address = get_test_address();
        let player = Player {
            address: test_address,
            total_xp: 0,
            fish_count: 0,
            tournaments_won: 0,
            reputation: 0,
            offspring_created: 0,
        };

        // Verify all fields are set correctly
        assert(player.address == test_address, 'Invalid address');
        assert(player.total_xp == 0, 'Invalid total_xp');
        assert(player.fish_count == 0, 'Invalid fish_count');
        assert(player.tournaments_won == 0, 'Invalid tournaments');
        assert(player.reputation == 0, 'Invalid reputation');
        assert(player.offspring_created == 0, 'Invalid offspring');
    }

    #[test]
    fn test_player_model_field_updates() {
        // Test Player model field updates
        let test_address = get_test_address();
        let mut player = Player {
            address: test_address,
            total_xp: 0,
            fish_count: 0,
            tournaments_won: 0,
            reputation: 0,
            offspring_created: 0,
        };

        // Update fields
        player.total_xp = 100;
        player.fish_count = 5;
        player.tournaments_won = 2;
        player.reputation = 50;
        player.offspring_created = 10;

        // Verify updates
        assert(player.total_xp == 100, 'total_xp failed');
        assert(player.fish_count == 5, 'fish_count failed');
        assert(player.tournaments_won == 2, 'tournaments failed');
        assert(player.reputation == 50, 'reputation failed');
        assert(player.offspring_created == 10, 'offspring failed');
    }

    // ============================================================================
    // Fish Model Tests
    // ============================================================================

    #[test]
    fn test_fish_model_creation() {
        // Test Fish model creation with all fields
        let test_address = get_test_address();
        let fish = Fish {
            id: TEST_FISH_ID,
            owner: test_address,
            state: FishState::Baby,
            dna: TEST_DNA,
            xp: 0,
            last_fed_at: 0,
            is_ready_to_breed: false,
            parent_ids: (Option::None, Option::None),
            species: TEST_SPECIES,
        };

        // Verify all fields
        assert(fish.id == TEST_FISH_ID, 'Invalid id');
        assert(fish.owner == test_address, 'Invalid owner');
        assert(fish.dna == TEST_DNA, 'Invalid dna');
        assert(fish.xp == 0, 'Invalid xp');
        assert(fish.is_ready_to_breed == false, 'Invalid ready');
        assert(fish.species == TEST_SPECIES, 'Invalid species');
    }

    #[test]
    fn test_fish_state_transitions() {
        // Test all FishState enum variants
        let test_address = get_test_address();
        let mut fish = Fish {
            id: TEST_FISH_ID,
            owner: test_address,
            state: FishState::Baby,
            dna: TEST_DNA,
            xp: 0,
            last_fed_at: 0,
            is_ready_to_breed: false,
            parent_ids: (Option::None, Option::None),
            species: TEST_SPECIES,
        };

        // Test Baby → Juvenile
        fish.state = FishState::Juvenile;
        match fish.state {
            FishState::Juvenile => {},
            _ => assert(false, 'Not Juvenile'),
        }

        // Test Juvenile → YoungAdult
        fish.state = FishState::YoungAdult;
        match fish.state {
            FishState::YoungAdult => {},
            _ => assert(false, 'Not YoungAdult'),
        }

        // Test YoungAdult → Adult
        fish.state = FishState::Adult;
        match fish.state {
            FishState::Adult => {},
            _ => assert(false, 'Not Adult'),
        }
    }

    #[test]
    fn test_fish_parent_ids_none() {
        // Test Fish with no parents (minted, not bred)
        let test_address = get_test_address();
        let fish = Fish {
            id: TEST_FISH_ID,
            owner: test_address,
            state: FishState::Baby,
            dna: TEST_DNA,
            xp: 0,
            last_fed_at: 0,
            is_ready_to_breed: false,
            parent_ids: (Option::None, Option::None),
            species: TEST_SPECIES,
        };

        // Verify parent_ids are None
        let (parent1, parent2) = fish.parent_ids;
        match parent1 {
            Option::None => {},
            Option::Some(_) => assert(false, 'parent1 not None'),
        }
        match parent2 {
            Option::None => {},
            Option::Some(_) => assert(false, 'parent2 not None'),
        }
    }

    #[test]
    fn test_fish_parent_ids_some() {
        // Test Fish with parents (bred)
        let test_address = get_test_address();
        let parent1_id: u32 = 10;
        let parent2_id: u32 = 20;
        let fish = Fish {
            id: TEST_FISH_ID,
            owner: test_address,
            state: FishState::Baby,
            dna: TEST_DNA,
            xp: 0,
            last_fed_at: 0,
            is_ready_to_breed: false,
            parent_ids: (Option::Some(parent1_id), Option::Some(parent2_id)),
            species: TEST_SPECIES,
        };

        // Verify parent_ids are Some
        let (parent1, parent2) = fish.parent_ids;
        match parent1 {
            Option::Some(id) => assert(id == parent1_id, 'parent1 id'),
            Option::None => assert(false, 'parent1 None'),
        }
        match parent2 {
            Option::Some(id) => assert(id == parent2_id, 'parent2 id'),
            Option::None => assert(false, 'parent2 None'),
        }
    }

    #[test]
    fn test_fish_is_ready_to_breed_flag() {
        // Test is_ready_to_breed flag updates
        let test_address = get_test_address();
        let mut fish = Fish {
            id: TEST_FISH_ID,
            owner: test_address,
            state: FishState::Adult,
            dna: TEST_DNA,
            xp: 1000,
            last_fed_at: 0,
            is_ready_to_breed: false,
            parent_ids: (Option::None, Option::None),
            species: TEST_SPECIES,
        };

        // Set to ready
        fish.is_ready_to_breed = true;
        assert(fish.is_ready_to_breed == true, 'Not ready');

        // Set back to not ready
        fish.is_ready_to_breed = false;
        assert(fish.is_ready_to_breed == false, 'Still ready');
    }

    // ============================================================================
    // Tank Model Tests
    // ============================================================================

    #[test]
    fn test_tank_model_creation() {
        // Test Tank model creation
        let test_address = get_test_address();
        let tank = Tank {
            id: 1,
            owner: test_address,
            capacity: 10,
        };

        // Verify all fields
        assert(tank.id == 1, 'Invalid id');
        assert(tank.owner == test_address, 'Invalid owner');
        assert(tank.capacity == 10, 'Invalid capacity');
    }

    #[test]
    fn test_tank_capacity_validation() {
        // Test Tank with different capacity values
        let test_address = get_test_address();
        let tank1 = Tank {
            id: 1,
            owner: test_address,
            capacity: 1,
        };
        assert(tank1.capacity == 1, 'Capacity not 1');

        let tank2 = Tank {
            id: 2,
            owner: test_address,
            capacity: 20,
        };
        assert(tank2.capacity == 20, 'Capacity not 20');
    }

    // ============================================================================
    // Decoration Model Tests
    // ============================================================================

    #[test]
    fn test_decoration_model_creation() {
        // Test Decoration model creation
        let test_address = get_test_address();
        let decoration = Decoration {
            id: 1,
            owner: test_address,
            kind: DecorationKind::Plant,
            xp_multiplier: 10,
            is_active: false,
        };

        // Verify all fields
        assert(decoration.id == 1, 'Invalid id');
        assert(decoration.owner == test_address, 'Invalid owner');
        assert(decoration.xp_multiplier == 10, 'Invalid multiplier');
        assert(decoration.is_active == false, 'Not inactive');
    }

    #[test]
    fn test_decoration_kind_variants() {
        // Test all DecorationKind enum variants
        let test_address = get_test_address();
        let decoration_plant = Decoration {
            id: 1,
            owner: test_address,
            kind: DecorationKind::Plant,
            xp_multiplier: 10,
            is_active: false,
        };
        match decoration_plant.kind {
            DecorationKind::Plant => {},
            _ => assert(false, 'Not Plant'),
        }

        let decoration_statue = Decoration {
            id: 2,
            owner: test_address,
            kind: DecorationKind::Statue,
            xp_multiplier: 15,
            is_active: false,
        };
        match decoration_statue.kind {
            DecorationKind::Statue => {},
            _ => assert(false, 'Not Statue'),
        }

        let decoration_background = Decoration {
            id: 3,
            owner: test_address,
            kind: DecorationKind::Background,
            xp_multiplier: 5,
            is_active: false,
        };
        match decoration_background.kind {
            DecorationKind::Background => {},
            _ => assert(false, 'Not Background'),
        }

        let decoration_ornament = Decoration {
            id: 4,
            owner: test_address,
            kind: DecorationKind::Ornament,
            xp_multiplier: 12,
            is_active: false,
        };
        match decoration_ornament.kind {
            DecorationKind::Ornament => {},
            _ => assert(false, 'Not Ornament'),
        }
    }

    #[test]
    fn test_decoration_activation_state() {
        // Test Decoration activation/deactivation
        let test_address = get_test_address();
        let mut decoration = Decoration {
            id: 1,
            owner: test_address,
            kind: DecorationKind::Plant,
            xp_multiplier: 10,
            is_active: false,
        };

        // Activate
        decoration.is_active = true;
        assert(decoration.is_active == true, 'Not active');

        // Deactivate
        decoration.is_active = false;
        assert(decoration.is_active == false, 'Not inactive');
    }
}

