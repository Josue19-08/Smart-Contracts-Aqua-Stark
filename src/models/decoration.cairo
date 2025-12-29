use starknet::ContractAddress;

// DecorationKind enum representing the types of decorations
#[derive(Serde, Drop, Copy, Introspect, DojoStore, Default)]
pub enum DecorationKind {
    #[default]
    Plant,
    Statue,
    Background,
    Ornament,
}

// Decoration model representing a decorative item in Aqua Stark
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Decoration {
    #[key]
    pub id: u32,
    pub owner: ContractAddress,
    pub kind: DecorationKind,
    pub xp_multiplier: u8,
    pub is_active: bool,
}

