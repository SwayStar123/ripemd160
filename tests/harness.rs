use fuels::prelude::*;
use ripemd::Ripemd160;
use ripemd::Digest;

abigen!(
    Contract(
        name="MyContract",
        abi="./out/debug/ripemd160-abi.json",
    )
);


async fn setup() -> MyContract<WalletUnlocked> {
    let wallet = launch_provider_and_get_wallet().await;
    let contract_id = Contract::load_from(
        "./out/debug/ripemd160.bin",
        LoadConfiguration::default(),
    ).unwrap().deploy(&wallet, TxParameters::default()).await.unwrap();

    MyContract::new(contract_id, wallet)
}

#[tokio::test]
async fn hello_world() {
    let contract = setup().await;

    let result = contract.methods().ripemd160(Bytes("Hello_world".as_bytes().to_vec())).call().await.unwrap().value;

    let expected = Ripemd160::digest("Hello_world".as_bytes());

    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_empty_string() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("".as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("".as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_a() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("a".as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("a".as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_abc() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("abc".as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("abc".as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_message_digest() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("message digest".as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("message digest".as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_alphabet() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("abcdefghijklmnopqrstuvwxyz".as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("abcdefghijklmnopqrstuvwxyz".as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_mixed_sequence() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_alphanumeric() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

#[tokio::test]
async fn test_repeated_sequence() {
    let contract = setup().await;
    let result = contract.methods().ripemd160(Bytes("1234567890".repeat(8).as_bytes().to_vec())).call().await.unwrap().value;
    let expected = Ripemd160::digest("1234567890".repeat(8).as_bytes());
    let result_hex = hex::encode(result);
    let expected_hex = hex::encode(expected.as_slice());
    assert_eq!(result_hex, expected_hex);
}

// #[tokio::test]
// async fn test_million_a() {
//     let contract = setup().await;
//     let result = contract.methods().ripemd160(Bytes("a".repeat(1000000).as_bytes().to_vec())).call().await.unwrap().value;
//     let expected = Ripemd160::digest("a".repeat(1000000).as_bytes());
//     let result_hex = hex::encode(result);
//     let expected_hex = hex::encode(expected.as_slice());
//     assert_eq!(result_hex, expected_hex);
// }
