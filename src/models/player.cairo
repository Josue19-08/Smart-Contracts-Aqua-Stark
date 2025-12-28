// TODO: Define Player fields (address, xp, count, etc.)
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub player: felt252,
    // TODO: Add Player fields here
    pub placeholder: u8,  // Temporary field - replace with actual fields
}

