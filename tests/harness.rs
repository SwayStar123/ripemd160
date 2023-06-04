use fuels::prelude::*;

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

    let bytes: [u8; 4] = [1, 2, 3, 4];

    // combine into a u32
    let x = u32::from_le_bytes(bytes);

    let result = instance.methods().u8s_to_u32(bytes).call().await.unwrap().value;

    assert_eq!(result, x);
}

#[tokio::test]
async fn u32_to_u8s() {
    let instance = setup().await;

    let x: u32 = 0x04030201;

    let bytes: [u8; 4] = x.to_le_bytes();

    let result = instance.methods().u32_to_u8s(x).call().await.unwrap().value;

    assert_eq!(result, bytes);
}
