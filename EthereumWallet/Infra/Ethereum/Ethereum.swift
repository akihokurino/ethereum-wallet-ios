import Core
import Foundation
import web3swift

final class Ethereum {
    private var cli: Web3?
    private var keystore: EthereumKeystoreV3!
    
    let password = "web3swift"

    static let shared = Ethereum()

    private init() {}

    var address: EthereumAddress {
        return keystore.addresses!.first!
    }

    func initialize() {
        var privateKey = DataStore.shared.getPrivateKey()
        if privateKey == nil {
            let privateKeyFromEnv = Env["WALLET_SECRET"] ?? ""
            if privateKeyFromEnv.isEmpty {
                privateKey = SECP256K1.generatePrivateKey()
                DataStore.shared.savePrivateKey(val: privateKey!)
            } else {
                let formattedKey = privateKeyFromEnv.trimmingCharacters(in: .whitespacesAndNewlines)
                privateKey = Data.fromHex(formattedKey)
                DataStore.shared.savePrivateKey(val: privateKey!)
            }
        }

        keystore = try! EthereumKeystoreV3(privateKey: privateKey!, password: password)!
    }

    func web3() async -> Web3 {
        if let cli = self.cli {
            return cli
        }
        let provider = await Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!, network: .Goerli)
        let web3 = Web3(provider: provider!)
        let keystoreManager = KeystoreManager([keystore])
        web3.addKeystoreManager(keystoreManager)
        cli = web3
        return web3
    }
    
    func export() throws -> String {
        let keystoreManager = KeystoreManager([keystore])
        let pkData = try keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: address)
        return pkData.toHexString()
    }
}
