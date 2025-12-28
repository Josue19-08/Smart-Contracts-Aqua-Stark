// TODO: Define Tank fields (capacity, decorations, etc.)
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Tank {
    #[key]
    pub tank_id: felt252,
    // TODO: Add Tank fields here
    pub placeholder: u8,  // Temporary field - replace with actual fields
}

