use starknet::ContractAddress;

// Player model representing a user's identity and statistics in Aqua Stark
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub total_xp: u32,
    pub fish_count: u16,
    pub tournaments_won: u16,
    pub reputation: u16,
    pub offspring_created: u16,
}

