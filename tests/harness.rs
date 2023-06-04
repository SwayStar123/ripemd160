use fuels::prelude::*;

use crypto::digest::Digest;
use ripemd::Ripemd160;

abigen!(Contract(
    name = "RipeMD160",
    abi = "out/debug/ripemd160-abi.json",
));


pub async fn setup() -> RipeMD160<WalletUnlocked> {
    let wallet = launch_provider_and_get_wallet().await;

    let storage_configuration = StorageConfiguration::load_from("out/debug/ripemd160-storage_slots.json");
    let configuration =
        LoadConfiguration::default().set_storage_configuration(storage_configuration.unwrap());

    let id = Contract::load_from("out/debug/ripemd160.bin", configuration)
        .unwrap()
        .deploy(&wallet, TxParameters::default())
        .await
        .unwrap();

    let instance: RipeMD160<WalletUnlocked> = RipeMD160::new(id, wallet.clone());

    instance
}

#[tokio::test]
async fn u8s_to_u32() {
    let instance = setup().await;

    let input: &[u8] = b"Hello, world!";

    let result = instance.methods().ripemd160(bytes).call().await.unwrap().value;

    // Compute using `rust-crypto`
    let mut hasher = Ripemd160::new();
    hasher.update(input);
    let expected_result = hasher.finalize();

    assert_eq!(result, expected_result);
}