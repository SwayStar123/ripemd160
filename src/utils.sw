library;

use std::bytes::Bytes;

// Converts a u8 to equal value u32
pub fn u8_4_to_u32(bytes: [u8; 4]) -> u32 {
    let i = 8;
    let j = 16;
    let k = 24;

    asm(a: bytes[0], b: bytes[1], c: bytes[2], d: bytes[3], i: i, j: j, k: k, r1, r2, r3) {
        sll  r1 c j;
        sll  r2 d k;
        or   r3 r1 r2;
        sll  r1 b i;
        or   r2 a r1;
        or   r1 r2 r3;
        r1: u32
    }
}

pub fn u32_to_u8s(input: u32) -> [u8; 4] {
    let off = 0xFF;
    let i = 8;
    let j = 16;
    let k = 24;

    let output = [0_u8, 0_u8, 0_u8, 0_u8];

    asm(input: input, off: off, i: i, j: j, k: k, output: output, r1, r2, r3, r4) {
        and  r1 input off;
        srl  r2 input i;
        and  r2 r2 off;
        srl  r3 input j;
        and  r3 r3 off;
        srl  r4 input k;
        and  r4 r4 off;

        sw   output r1 i0;
        sw   output r2 i1;
        sw   output r3 i2;
        sw   output r4 i3;

        output: [u8; 4]
    }
}

pub fn u64_into_bytes(input: u64) -> Bytes {
    let off = 0xFF;
    let i = 8;
    let j = 16;
    let k = 24;
    let l = 32;
    let m = 40;
    let n = 48;
    let o = 56;

    let output = [0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8];

    let output = asm(input: input, off: off, i: i, j: j, k: k, l: l, m: m, n: n, o: o, output: output, r1, r2, r3, r4, r5, r6, r7, r8) {
        and  r1 input off;
        srl  r2 input i;
        and  r2 r2 off;
        srl  r3 input j;
        and  r3 r3 off;
        srl  r4 input k;
        and  r4 r4 off;
        srl  r5 input l;
        and  r5 r5 off;
        srl  r6 input m;
        and  r6 r6 off;
        srl  r7 input n;
        and  r7 r7 off;
        srl  r8 input o;
        and  r8 r8 off;

        sw   output r1 i0;
        sw   output r2 i1;
        sw   output r3 i2;
        sw   output r4 i3;
        sw   output r5 i4;
        sw   output r6 i5;
        sw   output r7 i6;
        sw   output r8 i7;

        output: [u8; 8]
    };

    let mut i = 0;
    let mut output_bytes = Bytes::new();
    while i < 8 {
        output_bytes.push(output[i]);
        i += 1;
    }

    output_bytes
}

pub fn u8_64_into_bytes(input: [u8; 64]) -> Bytes {
    let mut output = Bytes::new();

    let mut i = 0;
    while i < 64 {
        output.push(input[i]);
        i += 1;
    }

    output
}

fn rol(n: u32, x: u32) -> u32 {
    (x << n) | (x >> (32 - n))
}

fn f0(x: u32, y: u32, z: u32) -> u32 {
    x ^ y ^ z
}

fn f1(x: u32, y: u32, z: u32) -> u32 {
    (x & y) | ((!x) & z)
}

fn f2(x: u32, y: u32, z: u32) -> u32 {
    (x | !y) ^ z
}

fn f3(x: u32, y: u32, z: u32) -> u32 {
    (x & z) | (!z & y)
}

fn f4(x: u32, y: u32, z: u32) -> u32 {
    x ^ (y | !z)
}

// let a = rol(
//     sj,
//     a.wrapping_add(f0(b, c, d))
//         .wrapping_add(x[rj])
//         .wrapping_add(kj),
// ).wrapping_add(e);
///
pub fn rf0(
    a: u32,
    b: u32,
    c: u32,
    d: u32,
    e: u32,
    kj: u32,
    sj: u32,
    rj: u64,
    x: [u32; 16],
) -> (u32, u32) {
    let a = rol(sj, a + f0(b, c, d) + x[rj] + kj) + e;

    let c = rol(10, c);
    (a, c)
}

pub fn rf1(
    a: u32,
    b: u32,
    c: u32,
    d: u32,
    e: u32,
    kj: u32,
    sj: u32,
    rj: u64,
    x: [u32; 16],
) -> (u32, u32) {
    let a = rol(sj, a + f1(b, c, d) + x[rj] 
+ kj) + e;

    let c = rol(10, c);
    (a, c)
}

pub fn rf2(
    a: u32,
    b: u32,
    c: u32,
    d: u32,
    e: u32,
    kj: u32,
    sj: u32,
    rj: u64,
    x: [u32; 16],
) -> (u32, u32) {
    let a = rol(sj, a + f2(b, c, d) + x[rj] + kj) + e;

    let c = rol(10, c);
    (a, c)
}

pub fn rf3(
    a: u32,
    b: u32,
    c: u32,
    d: u32,
    e: u32,
    kj: u32,
    sj: u32,
    rj: u64,
    x: [u32; 16],
) -> (u32, u32) {
    let a = rol(sj, a + f3(b, c, d) + x[rj] + kj) + e;

    let c = rol(10, c);
    (a, c)
}

pub fn rf4(
    a: u32,
    b: u32,
    c: u32,
    d: u32,
    e: u32,
    kj: u32,
    sj: u32,
    rj: u64,
    x: [u32; 16],
) -> (u32, u32) {
    let a = rol(sj, a + f4(b, c, d) + x[rj] + kj) + e;

    let c = rol(10, c);
    (a, c)
}

#[test]
fn test_u8_to_u32() {
    let bytes: [u8; 4] = [1_u8, 2_u8, 3_u8, 4_u8];

    let result = u8_4_to_u32(bytes);

    log(result);
    assert(result == 67305985);
}

#[test]
fn test_u32_to_u8() {
    let input: u32 = 67305985;

    let result = u32_to_u8s(input);

    log(result);
    assert(result[0] == 1_u8);
    assert(result[1] == 2_u8);
    assert(result[2] == 3_u8);
    assert(result[3] == 4_u8);
}

#[test]
fn test_u64_to_u8() {
    let input: u64 = 578437695752307201;

    let result = u64_into_bytes(input);

    log(result);
    assert(result.get(0).unwrap() == 1_u8);
    assert(result.get(1).unwrap() == 2_u8);
    assert(result.get(2).unwrap() == 3_u8);
    assert(result.get(3).unwrap() == 4_u8);
    assert(result.get(4).unwrap() == 5_u8);
    assert(result.get(5).unwrap() == 6_u8);
    assert(result.get(6).unwrap() == 7_u8);
    assert(result.get(7).unwrap() == 8_u8);
}

#[test]
fn test_u8_64_into_bytes() {
    let input: [u8; 64] = [1; 64];

    let result = u8_64_into_bytes(input);
    let bits256: b256 = result.into();

    assert(bits256 == 0x0101010101010101010101010101010101010101010101010101010101010101);
}

#[test]
fn test_rf0_with_asm() {
    let x = [9; 16];

    let res = rf0(1, 2, 3, 4, 5, 6, 7, 8, x);

    assert(res.0 == 2693);
    assert(res.1 == 3072);
}
