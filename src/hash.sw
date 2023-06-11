library;

use ::utils::{u32_to_u8s, u8_4_to_u32, u8_64_into_bytes, u64_into_bytes, rf0, rf1, rf2, rf3, rf4};

use std::bytes::Bytes;
use std::flags::{disable_panic_on_overflow, enable_panic_on_overflow};

const K0: u32 = 0x00000000;
const K1: u32 = 0x5A827999;
const K2: u32 = 0x6ED9EBA1;
const K3: u32 = 0x8F1BBCDC;
const K4: u32 = 0xA953FD4E;
const KK0: u32 = 0x50A28BE6;
const KK1: u32 = 0x5C4DD124;
const KK2: u32 = 0x6D703EF3;
const KK3: u32 = 0x7A6D76E9;
const KK4: u32 = 0x00000000;

struct RMDContext {
    state: [u32; 5],
    count: u64,
    buffer: [u8; 64],
}

impl RMDContext {
    fn new() -> RMDContext {
        RMDContext {
            state: [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0],
            count: 0,
            buffer: [0; 64],
        }
    }
}

pub fn ripemd160(input: Bytes) -> [u8; 20] {
    let mut ctx = RMDContext::new();
    rmd160_update(ctx, input);
    rmd160_final(ctx)
}

fn rmd160_update(ref mut ctx: RMDContext, input: Bytes) {
    let mut have = (ctx.count / 8) % 64;
    let inplen = input.len();
    let need = 64 - have;
    ctx.count += 8 * inplen;
    let mut off = 0;

    if inplen >= need {
        if have > 0 {
            let mut i = 0;
            while i < need {
                ctx.buffer[(have + i)] = input.get(i).unwrap();
                i += 1;
            }
            let mut state = ctx.state;
            rmd160_transform(state, u8_64_into_bytes(ctx.buffer));
            ctx.state = state;
            off = need;
            have = 0;
        }
        while off + 64 <= inplen {
            let (_, right) = input.split_at(off);
            let mut state = ctx.state;
            rmd160_transform(state, right);
            ctx.state = state;
            off += 64;
        }
    }
    if off < inplen {
        let mut i = 0;
        while i < inplen - off {
            ctx.buffer[(have + i)] = input.get((off + i)).unwrap();
            i += 1;
        }
    }
}

fn padding_bytes() -> Bytes {
    let mut padding = Bytes::with_capacity(64);
    padding.push(0x80);
    let mut i = 0;
    while i < 63 {
        padding.push(0);
        i += 1;
    }
    padding
}

fn rmd160_final(ref mut ctx: RMDContext) -> [u8; 20] {
    let size = u64_into_bytes(ctx.count);
    let mut padlen = 64 - ((ctx.count / 8) % 64);
    if padlen < 1 + 8 {
        padlen += 64;
    }
    let padding = padding_bytes();
    let (left, _) = padding.split_at(padlen - 8);

    rmd160_update(ctx, left);
    rmd160_update(ctx, size);
    let mut result = [0u8; 20];
    let mut i = 0;
    while i < 5 {
        let bytes = u32_to_u8s(ctx.state[i]);
        result[i*4] = bytes[0];
        result[i*4 + 1] = bytes[1];
        result[i*4 + 2] = bytes[2];
        result[i*4 + 3] = bytes[3];
        i += 1;
    }
    result
}

fn rmd160_transform(ref mut state: [u32; 5], block: Bytes) {
    assert(block.len() == 64);

    let mut x = [0u32; 16];
    let mut i = 0;
    while i < 16 {
        let chunk1 = block.get(i*4).unwrap();
        let chunk2 = block.get(i*4 + 1).unwrap();
        let chunk3 = block.get(i*4 + 2).unwrap();
        let chunk4 = block.get(i*4 + 3).unwrap();
        x[i] = u8_4_to_u32([chunk1, chunk2, chunk3, chunk4]);
        i += 1;
    }
    
    let mut a = state[0];
    let mut b = state[1];
    let mut c = state[2];
    let mut d = state[3];
    let mut e = state[4];

    // disable_panic_on_overflow();

    /* Round 1 */
    let (a, c) = rf0(a, b, c, d, e, K0, 11,  0, x);
    let (e, b) = rf0(e, a, b, c, d, K0, 14,  1, x);
    let (d, a) = rf0(d, e, a, b, c, K0, 15,  2, x);
    let (c, e) = rf0(c, d, e, a, b, K0, 12,  3, x);
    let (b, d) = rf0(b, c, d, e, a, K0,  5,  4, x);
    let (a, c) = rf0(a, b, c, d, e, K0,  8,  5, x);
    let (e, b) = rf0(e, a, b, c, d, K0,  7,  6, x);
    let (d, a) = rf0(d, e, a, b, c, K0,  9,  7, x);
    let (c, e) = rf0(c, d, e, a, b, K0, 11,  8, x);
    let (b, d) = rf0(b, c, d, e, a, K0, 13,  9, x);
    let (a, c) = rf0(a, b, c, d, e, K0, 14, 10, x);
    let (e, b) = rf0(e, a, b, c, d, K0, 15, 11, x);
    let (d, a) = rf0(d, e, a, b, c, K0,  6, 12, x);
    let (c, e) = rf0(c, d, e, a, b, K0,  7, 13, x);
    let (b, d) = rf0(b, c, d, e, a, K0,  9, 14, x);
    let (a, c) = rf0(a, b, c, d, e, K0,  8, 15, x); /* #15 */

    /* Round 2 */
    let (e, b) = rf1(e, a, b, c, d, K1,  7,  7, x);
    let (d, a) = rf1(d, e, a, b, c, K1,  6,  4, x);
    let (c, e) = rf1(c, d, e, a, b, K1,  8, 13, x);
    let (b, d) = rf1(b, c, d, e, a, K1, 13,  1, x);
    let (a, c) = rf1(a, b, c, d, e, K1, 11, 10, x);
    let (e, b) = rf1(e, a, b, c, d, K1,  9,  6, x);
    let (d, a) = rf1(d, e, a, b, c, K1,  7, 15, x);
    let (c, e) = rf1(c, d, e, a, b, K1, 15,  3, x);
    let (b, d) = rf1(b, c, d, e, a, K1,  7, 12, x);
    let (a, c) = rf1(a, b, c, d, e, K1, 12,  0, x);
    let (e, b) = rf1(e, a, b, c, d, K1, 15,  9, x);
    let (d, a) = rf1(d, e, a, b, c, K1,  9,  5, x);
    let (c, e) = rf1(c, d, e, a, b, K1, 11,  2, x);
    let (b, d) = rf1(b, c, d, e, a, K1,  7, 14, x);
    let (a, c) = rf1(a, b, c, d, e, K1, 13, 11, x);
    let (e, b) = rf1(e, a, b, c, d, K1, 12,  8, x); /* #31 */

    /* Round 3 */
    let (d, a) = rf2(d, e, a, b, c, K2, 11,  3, x);
    let (c, e) = rf2(c, d, e, a, b, K2, 13, 10, x);
    let (b, d) = rf2(b, c, d, e, a, K2,  6, 14, x);
    let (a, c) = rf2(a, b, c, d, e, K2,  7,  4, x);
    let (e, b) = rf2(e, a, b, c, d, K2, 14,  9, x);
    let (d, a) = rf2(d, e, a, b, c, K2,  9, 15, x);
    let (c, e) = rf2(c, d, e, a, b, K2, 13,  8, x);
    let (b, d) = rf2(b, c, d, e, a, K2, 15,  1, x);
    let (a, c) = rf2(a, b, c, d, e, K2, 14,  2, x);
    let (e, b) = rf2(e, a, b, c, d, K2,  8,  7, x);
    let (d, a) = rf2(d, e, a, b, c, K2, 13,  0, x);
    let (c, e) = rf2(c, d, e, a, b, K2,  6,  6, x);
    let (b, d) = rf2(b, c, d, e, a, K2,  5, 13, x);
    let (a, c) = rf2(a, b, c, d, e, K2, 12, 11, x);
    let (e, b) = rf2(e, a, b, c, d, K2,  7,  5, x);
    let (d, a) = rf2(d, e, a, b, c, K2,  5, 12, x); /* #47 */

    /* Round 4 */
    let (c, e) = rf3(c, d, e, a, b, K3, 11,  1, x);
    let (b, d) = rf3(b, c, d, e, a, K3, 12,  9, x);
    let (a, c) = rf3(a, b, c, d, e, K3, 14, 11, x);
    let (e, b) = rf3(e, a, b, c, d, K3, 15, 10, x);
    let (d, a) = rf3(d, e, a, b, c, K3, 14,  0, x);
    let (c, e) = rf3(c, d, e, a, b, K3, 15,  8, x);
    let (b, d) = rf3(b, c, d, e, a, K3,  9, 12, x);
    let (a, c) = rf3(a, b, c, d, e, K3,  8,  4, x);
    let (e, b) = rf3(e, a, b, c, d, K3,  9, 13, x);
    let (d, a) = rf3(d, e, a, b, c, K3, 14,  3, x);
    let (c, e) = rf3(c, d, e, a, b, K3,  5,  7, x);
    let (b, d) = rf3(b, c, d, e, a, K3,  6, 15, x);
    let (a, c) = rf3(a, b, c, d, e, K3,  8, 14, x);
    let (e, b) = rf3(e, a, b, c, d, K3,  6,  5, x);
    let (d, a) = rf3(d, e, a, b, c, K3,  5,  6, x);
    let (c, e) = rf3(c, d, e, a, b, K3, 12,  2, x); /* #63 */

    /* Round 5 */
    let (b, d) = rf4(b, c, d, e, a, K4,  9,  4, x);
    let (a, c) = rf4(a, b, c, d, e, K4, 15,  0, x);
    let (e, b) = rf4(e, a, b, c, d, K4,  5,  5, x);
    let (d, a) = rf4(d, e, a, b, c, K4, 11,  9, x);
    let (c, e) = rf4(c, d, e, a, b, K4,  6,  7, x);
    let (b, d) = rf4(b, c, d, e, a, K4,  8, 12, x);
    let (a, c) = rf4(a, b, c, d, e, K4, 13,  2, x);
    let (e, b) = rf4(e, a, b, c, d, K4, 12, 10, x);
    let (d, a) = rf4(d, e, a, b, c, K4,  5, 14, x);
    let (c, e) = rf4(c, d, e, a, b, K4, 12,  1, x);
    let (b, d) = rf4(b, c, d, e, a, K4, 13,  3, x);
    let (a, c) = rf4(a, b, c, d, e, K4, 14,  8, x);
    let (e, b) = rf4(e, a, b, c, d, K4, 11, 11, x);
    let (d, a) = rf4(d, e, a, b, c, K4,  8,  6, x);
    let (c, e) = rf4(c, d, e, a, b, K4,  5, 15, x);
    let (b, d) = rf4(b, c, d, e, a, K4,  6, 13, x); /* #79 */

    let aa = a;
    let bb = b;
    let cc = c;
    let dd = d;
    let ee = e;

    let a = state[0];
    let b = state[1];
    let c = state[2];
    let d = state[3];
    let e = state[4];
    
    /* Parallel round 1 */
    let (a, c) = rf4(a, b, c, d, e, KK0,  8,  5, x);
    let (e, b) = rf4(e, a, b, c, d, KK0,  9, 14, x);
    let (d, a) = rf4(d, e, a, b, c, KK0,  9,  7, x);
    let (c, e) = rf4(c, d, e, a, b, KK0, 11,  0, x);
    let (b, d) = rf4(b, c, d, e, a, KK0, 13,  9, x);
    let (a, c) = rf4(a, b, c, d, e, KK0, 15,  2, x);
    let (e, b) = rf4(e, a, b, c, d, KK0, 15, 11, x);
    let (d, a) = rf4(d, e, a, b, c, KK0,  5,  4, x);
    let (c, e) = rf4(c, d, e, a, b, KK0,  7, 13, x);
    let (b, d) = rf4(b, c, d, e, a, KK0,  7,  6, x);
    let (a, c) = rf4(a, b, c, d, e, KK0,  8, 15, x);
    let (e, b) = rf4(e, a, b, c, d, KK0, 11,  8, x);
    let (d, a) = rf4(d, e, a, b, c, KK0, 14,  1, x);
    let (c, e) = rf4(c, d, e, a, b, KK0, 14, 10, x);
    let (b, d) = rf4(b, c, d, e, a, KK0, 12,  3, x);
    let (a, c) = rf4(a, b, c, d, e, KK0,  6, 12, x); /* #15 */
    /* Parallel round 2 */
    let (e, b) = rf3(e, a, b, c, d, KK1,  9,  6, x);
    let (d, a) = rf3(d, e, a, b, c, KK1, 13, 11, x);
    let (c, e) = rf3(c, d, e, a, b, KK1, 15,  3, x);
    let (b, d) = rf3(b, c, d, e, a, KK1,  7,  7, x);
    let (a, c) = rf3(a, b, c, d, e, KK1, 12,  0, x);
    let (e, b) = rf3(e, a, b, c, d, KK1,  8, 13, x);
    let (d, a) = rf3(d, e, a, b, c, KK1,  9,  5, x);
    let (c, e) = rf3(c, d, e, a, b, KK1, 11, 10, x);
    let (b, d) = rf3(b, c, d, e, a, KK1,  7, 14, x);
    let (a, c) = rf3(a, b, c, d, e, KK1,  7, 15, x);
    let (e, b) = rf3(e, a, b, c, d, KK1, 12,  8, x);
    let (d, a) = rf3(d, e, a, b, c, KK1,  7, 12, x);
    let (c, e) = rf3(c, d, e, a, b, KK1,  6,  4, x);
    let (b, d) = rf3(b, c, d, e, a, KK1, 15,  9, x);
    let (a, c) = rf3(a, b, c, d, e, KK1, 13,  1, x);
    let (e, b) = rf3(e, a, b, c, d, KK1, 11,  2, x); /* #31 */
    /* Parallel round 3 */
    let (d, a) = rf2(d, e, a, b, c, KK2,  9, 15, x);
    let (c, e) = rf2(c, d, e, a, b, KK2,  7,  5, x);
    let (b, d) = rf2(b, c, d, e, a, KK2, 15,  1, x);
    let (a, c) = rf2(a, b, c, d, e, KK2, 11,  3, x);
    let (e, b) = rf2(e, a, b, c, d, KK2,  8,  7, x);
    let (d, a) = rf2(d, e, a, b, c, KK2,  6, 14, x);
    let (c, e) = rf2(c, d, e, a, b, KK2,  6,  6, x);
    let (b, d) = rf2(b, c, d, e, a, KK2, 14,  9, x);
    let (a, c) = rf2(a, b, c, d, e, KK2, 12, 11, x);
    let (e, b) = rf2(e, a, b, c, d, KK2, 13,  8, x);
    let (d, a) = rf2(d, e, a, b, c, KK2,  5, 12, x);
    let (c, e) = rf2(c, d, e, a, b, KK2, 14,  2, x);
    let (b, d) = rf2(b, c, d, e, a, KK2, 13, 10, x);
    let (a, c) = rf2(a, b, c, d, e, KK2, 13,  0, x);
    let (e, b) = rf2(e, a, b, c, d, KK2,  7,  4, x);
    let (d, a) = rf2(d, e, a, b, c, KK2,  5, 13, x); /* #47 */
    /* Parallel round 4 */
    let (c, e) = rf1(c, d, e, a, b, KK3, 15,  8, x);
    let (b, d) = rf1(b, c, d, e, a, KK3,  5,  6, x);
    let (a, c) = rf1(a, b, c, d, e, KK3,  8,  4, x);
    let (e, b) = rf1(e, a, b, c, d, KK3, 11,  1, x);
    let (d, a) = rf1(d, e, a, b, c, KK3, 14,  3, x);
    let (c, e) = rf1(c, d, e, a, b, KK3, 14, 11, x);
    let (b, d) = rf1(b, c, d, e, a, KK3,  6, 15, x);
    let (a, c) = rf1(a, b, c, d, e, KK3, 14,  0, x);
    let (e, b) = rf1(e, a, b, c, d, KK3,  6,  5, x);
    let (d, a) = rf1(d, e, a, b, c, KK3,  9, 12, x);
    let (c, e) = rf1(c, d, e, a, b, KK3, 12,  2, x);
    let (b, d) = rf1(b, c, d, e, a, KK3,  9, 13, x);
    let (a, c) = rf1(a, b, c, d, e, KK3, 12,  9, x);
    let (e, b) = rf1(e, a, b, c, d, KK3,  5,  7, x);
    let (d, a) = rf1(d, e, a, b, c, KK3, 15, 10, x);
    let (c, e) = rf1(c, d, e, a, b, KK3,  8, 14, x); /* #63 */
    /* Parallel round 5 */
    let (b, d) = rf0(b, c, d, e, a, KK4,  8, 12, x);
    let (a, c) = rf0(a, b, c, d, e, KK4,  5, 15, x);
    let (e, b) = rf0(e, a, b, c, d, KK4, 12, 10, x);
    let (d, a) = rf0(d, e, a, b, c, KK4,  9,  4, x);
    let (c, e) = rf0(c, d, e, a, b, KK4, 12,  1, x);
    let (b, d) = rf0(b, c, d, e, a, KK4,  5,  5, x);
    let (a, c) = rf0(a, b, c, d, e, KK4, 14,  8, x);
    let (e, b) = rf0(e, a, b, c, d, KK4,  6,  7, x);
    let (d, a) = rf0(d, e, a, b, c, KK4,  8,  6, x);
    let (c, e) = rf0(c, d, e, a, b, KK4, 13,  2, x);
    let (b, d) = rf0(b, c, d, e, a, KK4,  6, 13, x);
    let (a, c) = rf0(a, b, c, d, e, KK4,  5, 14, x);
    let (e, b) = rf0(e, a, b, c, d, KK4, 15,  0, x);
    let (d, a) = rf0(d, e, a, b, c, KK4, 13,  3, x);
    let (c, e) = rf0(c, d, e, a, b, KK4, 11,  9, x);
    let (b, d) = rf0(b, c, d, e, a, KK4, 11, 11, x); /* #79 */

    let t = state[1].wrapping_add(cc).wrapping_add(d);
    state[1] = state[2].wrapping_add(dd).wrapping_add(e);
    state[2] = state[3].wrapping_add(ee).wrapping_add(a);
    state[3] = state[4].wrapping_add(aa).wrapping_add(b);
    state[4] = state[0].wrapping_add(bb).wrapping_add(c);
    state[0] = t;

    // enable_panic_on_overflow();
}

#[test]
fn test_hash() {
    let input = [72, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33]; // b"Hello, world!"
    let mut input_bytes = Bytes::with_capacity(14);

    let mut i = 0;
    while i < 13 {
        input_bytes.push(input[i]);
        i += 1;
    }

    let output = ripemd160(input_bytes);
    // log(output[2]);
    

    // let expected = [88, 38, 45, 31, 189, 190, 69, 48, 216, 134, 93, 53, 24, 198, 214, 228, 16, 2, 97, 15];
    // log(expected[2]);

    // i = 0;
    // while i < 20 {
    //     assert(output[i] == expected[i]);
    //     i += 1;
    // }
}
