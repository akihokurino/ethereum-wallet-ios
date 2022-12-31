import BigInt
import Core
import Foundation
import web3swift

final class Ethereum {
    private var cli: Web3?
    private var keystore: EthereumKeystoreV3!
    private let password = "web3swift"
    private let gasLimit: BigUInt = 8500000
    private let gasPrice: BigUInt = 40000000000

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

    private func web3() async -> Web3 {
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

    func sendEth(to: EthereumAddress, amount: String) async throws -> String {
        var transaction: CodableTransaction = .emptyTransaction
        transaction.from = address
        transaction.to = to
        transaction.value = Utilities.parseToBigUInt(amount, units: .eth)!
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        transaction.chainID = BigUInt(Env["NETWORK_CHAIN_ID"]!)

        let resolver = PolicyResolver(provider: await web3().provider)
        try await resolver.resolveAll(for: &transaction)
        try Web3Signer.signTX(transaction: &transaction,
                              keystore: keystore,
                              account: address,
                              password: password)

        guard let txEncoded = transaction.encode() else { return "" }
        let res = try await web3().eth.send(raw: txEncoded)
        let txhash = res.transaction.hash?.toHexString() ?? ""
        print("result tx: \(txhash)")
        return txhash
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

    func erc20Balance(at: EthereumAddress) async throws -> String {
        let web3 = await web3()
        let contract = ERC20(web3: web3, provider: web3.provider, address: at, transaction: .emptyTransaction)
        let balance = try await contract.getBalance(account: address)
        return String(balance)
    }

    // FIXME: https://github.com/web3swift-team/web3swift/issues/711
    func erc20Transfer(at: EthereumAddress, to: EthereumAddress, amount: String) async throws -> String {
        let web3 = await web3()
        let contract = web3.contract(Web3.Utils.erc20ABI, at: at, abiVersion: 2)!
        let amount = Utilities.parseToBigUInt(amount, decimals: 0)!
        let method = "transfer"

        var transaction: CodableTransaction = .emptyTransaction
        transaction.from = address
        transaction.to = to
        transaction.gasLimit = gasLimit
        transaction.gasPrice = gasPrice
        transaction.chainID = BigUInt(Env["NETWORK_CHAIN_ID"]!)
        transaction.callOnBlock = .latest
        transaction.data = contract.contract.method(method, parameters: [to, amount] as [AnyObject], extraData: Data())!

        let tx: WriteOperation = .init(transaction: transaction, web3: web3, contract: contract.contract, method: method)
        let res = try await tx.writeToChain(password: password)
        let txhash = res.transaction.hash?.toHexString() ?? ""
        print("result tx: \(txhash)")
        return txhash

//        let contract = ERC20(web3: web3, provider: web3.provider, address: at, transaction: .emptyTransaction)
//        let tx = try await contract.transfer(from: address, to: to, amount: amount)
//        tx.transaction.from = address
//        tx.transaction.to = to
//        tx.transaction.gasLimit = gasLimit
//        tx.transaction.gasPrice = gasPrice
//        tx.transaction.chainID = BigUInt(Env["NETWORK_CHAIN_ID"]!)
//        tx.transaction.callOnBlock = .latest
//        let res = try await tx.writeToChain(password: password)
//        let txhash = res.transaction.hash?.toHexString() ?? ""
//        print("result tx: \(txhash)")
//        return txhash
    }
}
