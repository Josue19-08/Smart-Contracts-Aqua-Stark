use starknet::ContractAddress;

// Tank model representing an aquarium container in Aqua Stark
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Tank {
    #[key]
    pub id: u32,
    pub owner: ContractAddress,
    pub capacity: u8,
}

