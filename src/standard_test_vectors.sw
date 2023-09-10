library;
/// This file contains tests for the ripemd160 function using the standard test vectors.

use std::bytes::Bytes;
use ::hash::ripemd160;

// #[test]
// fn empty_string() {
//     let bytes = Bytes::new();
//     let hash = ripemd160(bytes);
// }

#[test]
fn one_million_times_a() {
    let mut bytes = Bytes::with_capacity(1000000);
    let mut i = 0;
    while i < 1000000 {
        bytes.push(0x61);
        i += 1;
    }

    let hash = ripemd160(bytes);
    let expected = [82, 120, 50, 67, 193, 105, 123, 219, 225, 109, 55, 249, 127, 104, 240, 131, 37, 220, 21, 40];
    log(hash[0]);
    i = 0;
    while i < 20 {
        assert(hash[i] == expected[i]);
        i+=1;
    }
}