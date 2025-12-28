use starknet::ContractAddress;
use core::option::Option;

// FishState enum representing the life stages of a fish
#[derive(Serde, Drop, Copy, Introspect, DojoStore, Default)]
pub enum FishState {
    #[default]
    Baby,
    Juvenile,
    YoungAdult,
    Adult,
}

// Fish model representing a fish entity in Aqua Stark
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Fish {
    #[key]
    pub id: u32,
    pub owner: ContractAddress,
    pub state: FishState,
    pub dna: felt252,
    pub xp: u32,
    pub last_fed_at: u64,
    pub is_ready_to_breed: bool,
    pub parent_ids: (Option<u32>, Option<u32>),
    pub species: felt252,
}

