use fuels::prelude::*;

abigen!(Contract(
    name = "MyContract",
    abi = "./out/debug/ripemd160-abi.json",
));

async fn setup() -> MyContract<WalletUnlocked> {
    let wallet = launch_provider_and_get_wallet().await;
    let contract_id =
        Contract::load_from("./out/debug/ripemd160.bin", LoadConfiguration::default())
            .unwrap()
            .deploy(&wallet, TxParameters::default())
            .await
            .unwrap();

    MyContract::new(contract_id, wallet)
}

#[tokio::test]
async fn test_empty_string() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes("".as_bytes().to_vec()))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "9c1185a5c5e9fc54612808977ee8f548b2258d31";
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_a() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes("a".as_bytes().to_vec()))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "0bdc9d2d256b3ee9daae347be6f4dc835a467ffe";
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_abc() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes("abc".as_bytes().to_vec()))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc";
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_message_digest() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes("message digest".as_bytes().to_vec()))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "5d0689ef49d2fae572b881b123a85ffa21595f36";
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_alphabet() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes("abcdefghijklmnopqrstuvwxyz".as_bytes().to_vec()))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "f71c27109c692c1b56bbdceb5b9d2865b3708dbc";
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_mixed_sequence() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes(
            "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
                .as_bytes()
                .to_vec(),
        ))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "12a053384a9c0c88e405a06c27dcf49ada62eb2b";
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_alphanumeric() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
                .as_bytes()
                .to_vec(),
        ))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "b0e20b6e3116640286ed3a87a5713079b21f5189";
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_repeated_sequence() {
    let contract = setup().await;
    let result = contract
        .methods()
        .ripemd160(Bytes("1234567890".repeat(8).as_bytes().to_vec()))
        .call()
        .await
        .unwrap()
        .value;

    let result_hex = hex::encode(result);
    let expected_hex = "9b752e45573d4b39f4dbd3323cab82bf63326bfb";
    assert_eq!(result_hex, expected_hex);
}

// #[tokio::test]
// async fn test_million_a() {
//     let contract = setup().await;
//     let result = contract
//         .methods()
//         .ripemd160(Bytes("a".repeat(1000000).as_bytes().to_vec()))
//         .call()
//         .await
//         .unwrap()
//         .value;

//     let result_hex = hex::encode(result);
//     let expected_hex = "52783243c1697bdbe16d37f97f68f08325dc1528";
//     assert_eq!(result_hex, expected_hex);
// }

// fn bit_xor(a: &[u8], b: &[u8]) -> Vec<u8> {
//     a.iter().zip(b.iter()).map(|(&x1, &x2)| x1 ^ x2).collect()
// }

// #[tokio::test]
// async fn test_oaep_encoding() {
//     let contract = setup().await;
//     let seed: Vec<u8> = "aafd12f659cae63489b479e5076ddec2f06cb58f"
//         .as_bytes()
//         .to_vec();
//     let message: Vec<u8> = hex::decode("54859b342c49ea2a").unwrap();

//     let encoding_parameters = [
//         "",
//         "3bf4c66f209e05f2a86eae213322fbf9252d6408",
//         "2771857832caf8f054940134a736233269f00d42",
//     ];
//     let expected_hashes = ["7dcfd33b1ca1107625a3fbd99075e7c8adc134bf3f5c201b7ad3e8b3ede0b48136002dd2ec034f04cda492db86973642dd59f018b0908a6504b4f845be3236",
//         "62732b7784ac93f3ed97ed1d89c7aedf1e98a21f171240b14fa63ee789e54e78fc34dc63650b0395cda492db86973642dd59f018b0908a6504b4f845be3236",
//         "071c2309ec131348e4faeeb5a409135a9c728b72e42e655755cdca7764183c4872204bb51c9bbb2ecda492db86973642dd59f018b0908a6504b4f845be3236"];
//     let intended_length_of_message = 63; // 63 bytes

//     for (param, expected_hash) in encoding_parameters.iter().zip(expected_hashes.iter()) {}
// }
