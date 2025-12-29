// TankCounter model representing a global counter for unique tank ID generation
// Singleton pattern: uses constant key (0) to maintain a single global counter instance
#[derive(Drop, Copy, Serde)]
#[dojo::model]
pub struct TankCounter {
    #[key]
    pub id: u32, // Constant key (0) for singleton pattern
    pub count: u32, // Current counter value
}
