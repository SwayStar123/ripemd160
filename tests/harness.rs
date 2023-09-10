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

fn bit_xor(a: &[u8], b: &[u8]) -> Vec<u8> {
    a.iter().zip(b.iter()).map(|(&x1, &x2)| x1 ^ x2).collect()
}

#[tokio::test]
async fn test_oaep_encoding() {
    let contract = setup().await;
    let seed: Vec<u8> = "aafd12f659cae63489b479e5076ddec2f06cb58f".as_bytes().to_vec();
    let message: Vec<u8> = hex::decode("54859b342c49ea2a").unwrap();

    let encoding_parameters = ["", "3bf4c66f209e05f2a86eae213322fbf9252d6408", "2771857832caf8f054940134a736233269f00d42"];
    
    for encoding_parameter in &encoding_parameters {
        let hashed_label: Vec<u8> = Ripemd160::digest(encoding_parameter.as_bytes()).as_slice().to_vec();

        let k0 = 63;
        let ps: Vec<u8> = vec![0; k0 - message.len() - hashed_label.len() - 1];
        let db: Vec<u8> = [&hashed_label[..], &ps, &[1], &message].concat();
        let db_mask = contract.methods().ripemd160(Bytes(seed.clone())).call().await.unwrap().value;
        let masked_db = bit_xor(&db, &db_mask);
        let seed_mask = contract.methods().ripemd160(Bytes(masked_db.clone())).call().await.unwrap().value;
        let masked_seed = bit_xor(&seed, &seed_mask);
        let result = [masked_seed.as_slice(), masked_db.as_slice()].concat();
        let expected = Ripemd160::digest(&result);
        let expected_hex = hex::encode(expected.as_slice());
        let result_hash = Ripemd160::digest(&result);
        let result_hash_hex = hex::encode(result_hash.as_slice());
        assert_eq!(result_hash_hex, expected_hex);
    }
}