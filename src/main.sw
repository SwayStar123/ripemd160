contract;

mod utils;
mod hash;
mod standard_test_vectors;

use hash::ripemd160;
use std::bytes::Bytes;

abi MyContract {
    fn ripemd160(bytes: Bytes) -> [u8; 20];
}

impl MyContract for Contract {
    fn ripemd160(bytes: Bytes) -> [u8; 20] {
        ripemd160(bytes)
    }
}
