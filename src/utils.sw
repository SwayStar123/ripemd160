library;

use std::bytes::Bytes;

impl u32 {
    pub fn wrapping_add(self, other: u32) -> u32 {
        asm(se: self, other: other, ttm: 4294967296, r1) {
            add r1 se other;
            mod r1 r1 ttm;
            r1: u32
        }
    }
}


// Converts a u8 to equal value u32
pub fn u8_4_to_u32(bytes: [u8; 4]) -> u32 {
    asm(a: bytes[0], b: bytes[1], c: bytes[2], d: bytes[3], i: 8, j: 16, k: 24, r1, r2, r3) {
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
    let output = [0; 4];

    asm(input: input, off: 0xFF, i: 8, j: 16, k: 24, output: output, r1, r2, r3, r4) {
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
    let output = [0; 8];

    let output = asm(input: input, off: 0xFF, i: 0x8, j: 0x10, k: 0x18, l: 0x20, m: 0x28, n: 0x30, o: 0x38, output: output, r1) {
        and  r1 input off;
        sw  output r1 i0;

        srl  r1 input i;
        and  r1 r1 off;
        sw  output r1 i1;

        srl  r1 input j;
        and  r1 r1 off;
        sw  output r1 i2;

        srl  r1 input k;
        and  r1 r1 off;
        sw  output r1 i3;

        srl  r1 input l;
        and  r1 r1 off;
        sw  output r1 i4;

        srl  r1 input m;
        and  r1 r1 off;
        sw  output r1 i5;

        srl  r1 input n;
        and  r1 r1 off;
        sw  output r1 i6;

        srl  r1 input o;
        and  r1 r1 off;
        sw  output r1 i7;

        output: [u8; 8]
    };

    let mut i = 0;
    let mut output_bytes = Bytes::with_capacity(8);
    while i < 8 {
        output_bytes.push(output[i]);
        i += 1;
    }

    output_bytes
}

pub fn u8_64_into_bytes(input: [u8; 64]) -> Bytes {
    let mut output = Bytes::with_capacity(64);

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
    let a = rol(
        sj,
        a.wrapping_add(f0(b, c, d))
            .wrapping_add(x[rj])
            .wrapping_add(kj),
    ).wrapping_add(e);
    

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
    let a = rol(
        sj,
        a.wrapping_add(f1(b, c, d))
            .wrapping_add(x[rj])
            .wrapping_add(kj),
    ).wrapping_add(e);

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
    let a = rol(
        sj,
        a.wrapping_add(f2(b, c, d))
            .wrapping_add(x[rj])
            .wrapping_add(kj),
    ).wrapping_add(e);

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
    let a = rol(
        sj,
        a.wrapping_add(f3(b, c, d))
            .wrapping_add(x[rj])
            .wrapping_add(kj),
    ).wrapping_add(e);

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
    let a = rol(
        sj,
        a.wrapping_add(f4(b, c, d))
            .wrapping_add(x[rj])
            .wrapping_add(kj),
    ).wrapping_add(e);

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

#[test]
fn test_wrapping_add() {
    let a: u32 = 0xFFFFFFFF;
    let b: u32 = 1;
    let c: u32 = a.wrapping_add(b);
    log(c);
    assert(c == 0);
}