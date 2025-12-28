# Development Roadmap

This roadmap outlines the planned development phases for the Aqua Stark Smart Contracts, with specific issues for each phase.

## Phase 1: Foundation Setup ✓ (COMPLETED)

- [x] Project structure creation
- [x] Configuration files setup
- [x] Base model definitions (empty structure)
- [x] Base system definitions (empty structure)
- [x] Documentation framework

## Phase 2: Model Implementation

**Issue 2.1: Implement Player Model**
- Define Player struct with fields: address (key, ContractAddress), total_xp (u32), fish_count (u16), tournaments_won (u16), reputation (u16), offspring_created (u16)
- Add `#[dojo::model]` decorator
- Implement validation logic

**Issue 2.2: Implement Fish Model and FishState Enum**
- Define FishState enum: Baby, Juvenile, YoungAdult, Adult
- Define Fish struct with fields: id (key, u32), owner (ContractAddress), state (FishState), dna (felt252), xp (u32), last_fed_at (u64), is_ready_to_breed (bool), parent_ids (Option<u32>, Option<u32>), species (felt252)
- Add `#[dojo::model]` decorator
- Implement validation logic

**Issue 2.3: Implement Tank Model**
- Define Tank struct with fields: id (key, u32), owner (ContractAddress), capacity (u8)
- Add `#[dojo::model]` decorator
- Implement validation logic

**Issue 2.4: Implement Decoration Model and DecorationKind Enum**
- Define DecorationKind enum: Plant, Statue, Background, Ornament
- Define Decoration struct with fields: id (key, u32), owner (ContractAddress), kind (DecorationKind), xp_multiplier (u8), is_active (bool)
- Add `#[dojo::model]` decorator
- Implement validation logic

## Phase 3: Global Counters Implementation

**Issue 3.1: Implement FishCounter Model**
- Create FishCounter model with count field
- Implement get_next_fish_id() function
- Ensure atomic increment logic

**Issue 3.2: Implement TankCounter Model**
- Create TankCounter model with count field
- Implement get_next_tank_id() function
- Ensure atomic increment logic

**Issue 3.3: Implement DecorationCounter Model**
- Create DecorationCounter model with count field
- Implement get_next_decoration_id() function
- Ensure atomic increment logic

## Phase 4: Registration & Initialization Systems

**Issue 4.1: Implement register_player System**
- Create player_system/contracts.cairo
- Implement register_player(address: ContractAddress) function
- Create Player component with default values (total_xp=0, fish_count=0, tournaments_won=0, reputation=0, offspring_created=0)
- Validate player doesn't already exist
- Return: nothing

**Issue 4.2: Implement mint_fish System**
- Implement mint_fish(address: ContractAddress, species: felt252, dna: felt252) function
- Use get_next_fish_id() for unique ID generation
- Initialize Fish with default values:
  - state = Baby
  - xp = 0
  - last_fed_at = current timestamp
  - is_ready_to_breed = false
  - parent_ids = (None, None)
- Set species and dna as provided
- Return: fish_id (u32)

**Issue 4.3: Implement mint_tank System**
- Implement mint_tank(address: ContractAddress, capacity: u8) function
- Use get_next_tank_id() for unique ID generation
- Create Tank with default capacity (10)
- Link to player owner
- Return: tank_id (u32)

**Issue 4.4: Implement mint_decoration System**
- Implement mint_decoration(address: ContractAddress, kind: DecorationKind) function
- Use get_next_decoration_id() for unique ID generation
- Set xp_multiplier based on decoration kind
- Initialize is_active as false
- Return: decoration_id (u32)

## Phase 5: Query Systems

**Issue 5.1: Implement Tank Queries**
- get_tank_by_owner(address: ContractAddress) → Tank
- get_tanks_by_owner(address: ContractAddress) → Array<Tank>
- get_tank(tank_id: u32) → Tank

**Issue 5.2: Implement Fish Queries**
- get_fish_by_owner(address: ContractAddress) → Array<Fish>
- get_fish(fish_id: u32) → Fish

**Issue 5.3: Implement Decoration Queries**
- get_decorations_by_owner(address: ContractAddress) → Array<Decoration>
- get_decoration(deco_id: u32) → Decoration

**Issue 5.4: Implement Player Queries**
- get_player(address: ContractAddress) → Player
- get_player_stats(address: ContractAddress) → Player stats summary

**Issue 5.5: Implement get_fish_family_tree System**
- get_fish_family_tree(fish_id: u32) → Family tree structure
- Include: Parents, Siblings, Children, Grandparents, Uncles/Aunts, Cousins
- Return structured result grouped by relation

## Phase 6: Action Systems

**Issue 6.1: Implement Feed Fish System**
- Implement feed_fish_batch(fish_ids: Array<u32>, timestamp: u64) function
- Validate ownership for each fish
- Calculate get_xp_multiplier(tank_id) for bonus
- Apply XP with multiplier bonus to each fish
- Update last_fed_at for each fish
- Return: nothing

**Issue 6.2: Implement XP Gain Systems**
- Implement gain_fish_xp(fish_id: u32, amount: u32) function
- Implement gain_player_xp(address: ContractAddress, amount: u32) function
- Handle fish evolution state changes (Baby → Juvenile → YoungAdult → Adult) based on XP thresholds
- Update player total_xp
- Return: nothing

**Issue 6.3: Implement Breeding Readiness System**
- Implement set_ready_to_breed(fish_id: u32, ready: bool) function
- Validate fish is in Adult state
- Update is_ready_to_breed flag
- Return: nothing

**Issue 6.4: Implement Breed Fish System**
- Implement breed_fish(fish_id1: u32, fish_id2: u32) function
- Validate both fish ownership (same owner)
- Validate both fish are in Adult state
- Validate both fish have is_ready_to_breed == true
- Generate new fish_id using get_next_fish_id()
- Generate mixed DNA from parents using DNA utilities
- Derive or combine species from parents
- Set parent_ids to (Some(fish_id1), Some(fish_id2))
- Increment player offspring_created counter
- Return: new fish_id (u32)

## Phase 7: Decoration Systems

**Issue 7.1: Implement Decoration Activation System**
- Implement activate_decoration(deco_id: u32) function
- Validate ownership
- Set is_active = true
- Apply xp_multiplier bonus to tank (affects get_xp_multiplier calculation)
- Return: nothing

**Issue 7.2: Implement Decoration Deactivation System**
- Implement deactivate_decoration(deco_id: u32) function
- Validate ownership
- Set is_active = false
- Remove xp_multiplier bonus from tank
- Return: nothing

**Issue 7.3: Implement XP Multiplier Calculation**
- Implement get_xp_multiplier(tank_id: u32) → u8 function
- Sum xp_multiplier of all active decorations owned by tank owner
- Return total multiplier percentage

## Phase 8: Utilities and Constants

**Issue 8.1: Implement DNA Utilities**
- Create libs/dna_utils.cairo
- Implement DNA generation functions
- Implement DNA combination functions (for breeding - mixing parent DNA)
- Implement DNA mutation functions

**Issue 8.2: Implement Game Constants**
- Create constants/game_config.cairo
- Define MAX_FISH_PER_TANK constant
- Define BASE_FISH_HEALTH constant
- Define MIN_BREEDING_LEVEL constant (XP threshold for breeding)
- Define XP thresholds for evolution stages (Baby → Juvenile → YoungAdult → Adult)
- Define default tank capacity (10)

**Issue 8.3: Implement Error Helpers**
- Create utils/error_helpers.cairo
- Define error codes enum
- Implement validation functions
- Implement error formatting functions

## Phase 9: Testing

**Issue 9.1: Unit Tests for Models**
- Test Player model creation and updates
- Test Fish model lifecycle (state transitions)
- Test Tank capacity limits
- Test Decoration activation/deactivation

**Issue 9.2: Unit Tests for Counters**
- Test ID generation uniqueness
- Test counter increments
- Test atomic operations

**Issue 9.3: Integration Tests for Systems**
- Test register_player flow
- Test mint_fish flow
- Test mint_tank flow
- Test feed_fish_batch flow
- Test breed_fish flow
- Test decoration activation flow

**Issue 9.4: Edge Case Testing**
- Test capacity limits
- Test ownership validation
- Test breeding prerequisites
- Test XP multiplier calculations
- Test family tree queries

**Issue 9.5: Error Condition Testing**
- Test invalid inputs
- Test unauthorized access
- Test state transition errors
- Test counter overflow scenarios

## Phase 10: Local Development

**Issue 10.1: Setup Katana Local Testnet**
- Configure katana for local testing
- Setup test accounts
- Verify connectivity

**Issue 10.2: Deploy Contracts to Local Testnet**
- Deploy Dojo world
- Deploy all systems
- Verify deployment success

**Issue 10.3: Configure Torii Indexer**
- Setup Torii for local indexing
- Configure event indexing
- Test query capabilities

**Issue 10.4: End-to-End Testing**
- Test complete player registration flow
- Test fish breeding flow
- Test decoration activation flow
- Test XP gain and evolution flow

## Phase 11: Testnet Deployment

**Issue 11.1: Deploy to Starknet Testnet**
- Configure dojo_sepolia.toml
- Deploy contracts to testnet
- Verify deployment

**Issue 11.2: Backend Integration Testing**
- Test API integration
- Test event handling
- Test state synchronization

**Issue 11.3: Frontend Integration Testing**
- Test UI interactions
- Test transaction flows
- Test real-time updates

## Phase 12: Mainnet Preparation

**Issue 12.1: Security Audit**
- Code review for vulnerabilities
- Gas optimization review
- Access control verification

**Issue 12.2: Final Testing on Testnet**
- Comprehensive test suite execution
- Load testing
- Performance optimization

**Issue 12.3: Documentation Completion**
- Update all documentation
- Create user guides
- Create developer guides

## Phase 13: Mainnet Deployment

**Issue 13.1: Deploy to Starknet Mainnet**
- Final deployment configuration
- Deploy contracts
- Verify deployment

**Issue 13.2: Post-Deployment Verification**
- Verify all systems operational
- Monitor initial transactions
- Validate data integrity

## Notes

- Each issue should be created as a GitHub issue for tracking
- Issues should be completed and tested before moving to the next phase
- Regular code reviews should be conducted
- Documentation should be updated as features are implemented
- Security considerations should be prioritized throughout development
