import BigInt
import Core
import Foundation
import web3swift

final class Ethereum {
    private var cli: Web3?
    private var keystore: EthereumKeystoreV3!
    private let password = "web3swift"

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

    func balance() async throws -> String {
        let balanceWei: BigUInt = try await web3().eth.getBalance(for: address)
        return Units.toEtherString(wei: balanceWei)
    }

    // TODO: https://github.com/skywinder/web3swift/blob/master/Tests/web3swiftTests/localTests/UserCases.swift#L37
    func sendEth(to: EthereumAddress, amount: String) async throws -> String {
        var transaction: CodableTransaction = .emptyTransaction
        transaction.from = address
        transaction.to = to
        transaction.value = Utilities.parseToBigUInt(amount, units: .eth)!
        transaction.gasLimit = 8500000
        transaction.gasPrice = 40000000000
        let result = try await web3().eth.send(transaction)
        let hash = result.transaction.hash!
        return String(data: hash, encoding: .utf8)!
    }

    func erc20Contract(at: EthereumAddress) async throws -> ERC20Token {
        let contract = await web3().contract(Web3.Utils.erc20ABI, at: at, abiVersion: 2)!
        let result = try await contract.createReadOperation(
            "name",
            parameters: [],
            extraData: Data()
        )!.callContractMethod()
        let name = result["0"] as! String
        return ERC20Token(address: at, name: name)
    }

    func erc20ContractBalance(at: EthereumAddress) async throws -> String {
        let web3 = await web3()
        let contract = ERC20(web3: web3, provider: web3.provider, address: at, transaction: .emptyTransaction)
        let balance = try await contract.getBalance(account: address)
        return String(balance)
    }

    // TODO: https://github.com/skywinder/web3swift/blob/develop/Tests/web3swiftTests/localTests/ERC20Tests.swift#L36
    func erc20ContractTransfer(at: EthereumAddress, to: EthereumAddress, amount: String) async throws -> String {
        let web3 = await web3()
        let amount = Utilities.parseToBigUInt(amount, decimals: 0)!
        let contract = web3.contract(Web3.Utils.erc20ABI, at: at, abiVersion: 2)!
        var transaction: CodableTransaction = .emptyTransaction
        transaction.from = address
        transaction.to = to
        transaction.gasLimit = 8500000
        transaction.gasPrice = 40000000000
        transaction.callOnBlock = .latest
        contract.transaction = transaction
        let tx = contract.createWriteOperation("transfer", parameters: [to, amount] as [AnyObject], extraData: Data())!
        let result = try await tx.writeToChain(password: password)
        let hash = result.transaction.hash!
        return String(data: hash, encoding: .utf8)!
    }
}
