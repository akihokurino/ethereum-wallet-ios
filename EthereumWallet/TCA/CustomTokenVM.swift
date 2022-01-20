import BigInt
import Combine
import ComposableArchitecture
import Foundation
import web3swift

let customTokenAddress = "0x803c6922F39792Bd17DE55Db7eFcd7b4a206ebA4"

enum CustomTokenVM {
    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .startInitialize:
                guard !state.isInitialized else {
                    return .none
                }

                state.shouldShowHUD = true

                let address = state.address
                let flow = Future<String, AppError> { promise in
                    DispatchQueue.global(qos: .background).async {
                        let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)
                        let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(customTokenAddress)!, abiVersion: 2)!
                        var options = TransactionOptions.defaultOptions

                        do {
                            let result = try contract.read(
                                "balanceOf",
                                parameters: [address] as [AnyObject],
                                extraData: Data(),
                                transactionOptions: options)!.call()
                            let balance = result["0"] as! BigUInt
                            promise(.success(String(balance)))
                        } catch {
                            promise(.failure(AppError.plain(error.localizedDescription)))
                        }
                    }
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CustomTokenVM.Action.endInitialize)
            case .endInitialize(.success(let balance)):
                state.balance = balance
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .endInitialize(.failure(_)):
                state.shouldShowHUD = false
                return .none
            case .startRefresh:
                state.shouldPullToRefresh = true

                let address = state.address
                let flow = Future<String, AppError> { promise in
                    DispatchQueue.global(qos: .background).async {
                        let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)
                        let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(customTokenAddress)!, abiVersion: 2)!
                        var options = TransactionOptions.defaultOptions

                        do {
                            let result = try contract.read(
                                "balanceOf",
                                parameters: [address] as [AnyObject],
                                extraData: Data(),
                                transactionOptions: options)!.call()
                            let balance = result["0"] as! BigUInt
                            promise(.success(String(balance)))
                        } catch {
                            promise(.failure(AppError.plain(error.localizedDescription)))
                        }
                    }
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CustomTokenVM.Action.endRefresh)
            case .endRefresh(.success(let balance)):
                state.balance = balance
                state.shouldPullToRefresh = false
                return .none
            case .endRefresh(.failure(_)):
                state.shouldPullToRefresh = false
                return .none
            case .shouldShowHUD(let val):
                state.shouldShowHUD = val
                return .none
            case .shouldPullToRefresh(let val):
                state.shouldPullToRefresh = val
                return .none
            case .startSendTransaction:
                let valueCMTN = state.inputValueCMTN
                let to = state.inputToAddress
                if valueCMTN.isEmpty || to.isEmpty {
                    return .none
                }

                state.shouldShowHUD = true

                let address = state.address
                let flow = Future<String, AppError> { promise in
                    DispatchQueue.global(qos: .background).async {
                        let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)
                        let privateKey = DataStore.shared.getPrivateKey()!
                        let keystore = try! EthereumKeystoreV3(privateKey: privateKey)!
                        let keystoreManager = KeystoreManager([keystore])
                        web3.addKeystoreManager(keystoreManager)

                        let toAddress = EthereumAddress(to)!
                        let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(customTokenAddress)!, abiVersion: 2)!
                        let amount = Web3.Utils.parseToBigUInt(valueCMTN, decimals: 0)!
                        var options = TransactionOptions.defaultOptions
                        options.from = address
                        options.gasLimit = .manual(BigUInt(5500000))
                        options.gasPrice = .manual(BigUInt(35000000000))

                        do {
                            let result = try contract.write(
                                "transfer",
                                parameters: [toAddress, amount] as [AnyObject],
                                extraData: Data(),
                                transactionOptions: options)!.send()
                            promise(.success(result.transaction.txhash ?? ""))
                        } catch {
                            print("send tx error: \(error)")
                            promise(.failure(AppError.plain(error.localizedDescription)))
                        }
                    }
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CustomTokenVM.Action.endSendTransaction)
            case .endSendTransaction(.success(let txhash)):
                print("create tx: \(txhash)")
                state.inputValueCMTN = ""
                state.inputToAddress = ""
                state.shouldShowHUD = false
                return .none
            case .endSendTransaction(.failure(_)):
                state.shouldShowHUD = false
                return .none
            case .inputValueCMTN(let val):
                state.inputValueCMTN = val
                return .none
            case .inputToAddress(let val):
                state.inputToAddress = val
                return .none
            }
        }
    )
}

extension CustomTokenVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<String, AppError>)
        case startRefresh
        case endRefresh(Result<String, AppError>)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
        case startSendTransaction
        case endSendTransaction(Result<String, AppError>)
        case inputValueCMTN(String)
        case inputToAddress(String)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""

        var inputValueCMTN = ""
        var inputToAddress = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
