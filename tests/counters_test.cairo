// Unit tests for Aqua Stark counter models
// Tests FishCounter, TankCounter, and DecorationCounter

#[cfg(test)]
mod tests {
    use aqua_stark::models::counters::fish_counter::FishCounter;
    use aqua_stark::models::counters::tank_counter::TankCounter;
    use aqua_stark::models::counters::decoration_counter::DecorationCounter;

    // ============================================================================
    // FishCounter Tests
    // ============================================================================

    #[test]
    fn test_fish_counter_initialization() {
        // Test FishCounter initialization
        let counter = FishCounter {
            id: 0,
            count: 0,
        };

        // Verify initial state
        assert(counter.id == 0, 'Invalid id');
        assert(counter.count == 0, 'Invalid count');
    }

    #[test]
    fn test_fish_counter_increment() {
        // Test FishCounter increment operations
        let mut counter = FishCounter {
            id: 0,
            count: 0,
        };

        // Increment and verify
        counter.count = counter.count + 1;
        assert(counter.count == 1, 'Count not 1');

        counter.count = counter.count + 1;
        assert(counter.count == 2, 'Count not 2');

        counter.count = counter.count + 1;
        assert(counter.count == 3, 'Count not 3');
    }

    #[test]
    fn test_fish_counter_sequential_ids() {
        // Test that counter generates sequential IDs
        let mut counter = FishCounter {
            id: 0,
            count: 0,
        };

        // Simulate ID generation: get current count, then increment
        let id1 = counter.count;
        counter.count = counter.count + 1;
        assert(id1 == 0, 'ID not 0');

        let id2 = counter.count;
        counter.count = counter.count + 1;
        assert(id2 == 1, 'ID not 1');

        let id3 = counter.count;
        counter.count = counter.count + 1;
        assert(id3 == 2, 'ID not 2');
    }

    // ============================================================================
    // TankCounter Tests
    // ============================================================================

    #[test]
    fn test_tank_counter_initialization() {
        // Test TankCounter initialization
        let counter = TankCounter {
            id: 0,
            count: 0,
        };

        // Verify initial state
        assert(counter.id == 0, 'Invalid id');
        assert(counter.count == 0, 'Invalid count');
    }

    #[test]
    fn test_tank_counter_increment() {
        // Test TankCounter increment operations
        let mut counter = TankCounter {
            id: 0,
            count: 0,
        };

        // Increment and verify
        counter.count = counter.count + 1;
        assert(counter.count == 1, 'Count not 1');

        counter.count = counter.count + 1;
        assert(counter.count == 2, 'Count not 2');
    }

    #[test]
    fn test_tank_counter_sequential_ids() {
        // Test that counter generates sequential IDs
        let mut counter = TankCounter {
            id: 0,
            count: 0,
        };

        // Simulate ID generation
        let id1 = counter.count;
        counter.count = counter.count + 1;
        assert(id1 == 0, 'ID not 0');

        let id2 = counter.count;
        counter.count = counter.count + 1;
        assert(id2 == 1, 'ID not 1');
    }

    // ============================================================================
    // DecorationCounter Tests
    // ============================================================================

    #[test]
    fn test_decoration_counter_initialization() {
        // Test DecorationCounter initialization
        let counter = DecorationCounter {
            id: 0,
            count: 0,
        };

        // Verify initial state
        assert(counter.id == 0, 'Invalid id');
        assert(counter.count == 0, 'Invalid count');
    }

    #[test]
    fn test_decoration_counter_increment() {
        // Test DecorationCounter increment operations
        let mut counter = DecorationCounter {
            id: 0,
            count: 0,
        };

        // Increment and verify
        counter.count = counter.count + 1;
        assert(counter.count == 1, 'Count not 1');

        counter.count = counter.count + 1;
        assert(counter.count == 2, 'Count not 2');
    }

    #[test]
    fn test_decoration_counter_sequential_ids() {
        // Test that counter generates sequential IDs
        let mut counter = DecorationCounter {
            id: 0,
            count: 0,
        };

        // Simulate ID generation
        let id1 = counter.count;
        counter.count = counter.count + 1;
        assert(id1 == 0, 'ID not 0');

        let id2 = counter.count;
        counter.count = counter.count + 1;
        assert(id2 == 1, 'ID not 1');
    }

    // ============================================================================
    // Counter Independence Tests
    // ============================================================================

    #[test]
    fn test_counters_are_independent() {
        // Test that different counter types are independent
        let mut fish_counter = FishCounter {
            id: 0,
            count: 0,
        };
        let mut tank_counter = TankCounter {
            id: 0,
            count: 0,
        };
        let mut decoration_counter = DecorationCounter {
            id: 0,
            count: 0,
        };

        // Increment each counter independently
        fish_counter.count = fish_counter.count + 1;
        tank_counter.count = tank_counter.count + 1;
        decoration_counter.count = decoration_counter.count + 1;

        // Verify each counter is independent
        assert(fish_counter.count == 1, 'Fish not 1');
        assert(tank_counter.count == 1, 'Tank not 1');
        assert(decoration_counter.count == 1, 'Deco not 1');

        // Increment fish counter again
        fish_counter.count = fish_counter.count + 1;
        assert(fish_counter.count == 2, 'Fish not 2');
        assert(tank_counter.count == 1, 'Tank not 1');
        assert(decoration_counter.count == 1, 'Deco not 1');
    }
}

