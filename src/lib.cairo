// SPDX-License-Identifier: UNLICENSED

pub mod systems {
    pub mod player {
        pub mod contracts;
    }
    pub mod fish {
        pub mod contracts;
    }
    pub mod tank {
        pub mod contracts;
    }
    pub mod decoration {
        pub mod contracts;
    }
}

pub mod models {
    pub mod player;
    pub mod fish;
    pub mod tank;
    pub mod decoration;
    pub mod counters;
}

pub mod constants {
    pub mod game_config;
}

pub mod libs {
    pub mod dna_utils;
}

pub mod utils {
    pub mod error_helpers;
}

