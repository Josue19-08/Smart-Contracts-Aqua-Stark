// TODO: Define Fish fields (dna, level, health, etc.)
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct Fish {
    #[key]
    pub fish_id: felt252,
    // TODO: Add Fish fields here
    pub placeholder: u8,  // Temporary field - replace with actual fields
}

