import Combine
import ComposableArchitecture
import Foundation
import web3swift

enum HomeVM {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            guard !state.isInitialized else {
                return .none
            }

            state.shouldShowHUD = true

            let address = state.address
            let flow = Future<String, AppError> { promise in
                let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)

                do {
                    let balanceWei = try web3.eth.getBalance(address: address)
                    let balanceEther = Web3.Utils.formatToEthereumUnits(balanceWei, toUnits: .eth, decimals: 3)!
                    promise(.success(balanceEther))
                } catch {
                    promise(.failure(AppError.plain(error.localizedDescription)))
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(HomeVM.Action.endInitialize)
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
                let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)

                do {
                    let balanceWei = try web3.eth.getBalance(address: address)
                    let balanceEther = Web3.Utils.formatToEthereumUnits(balanceWei, toUnits: .eth, decimals: 3)!
                    promise(.success(balanceEther))
                } catch {
                    promise(.failure(AppError.plain(error.localizedDescription)))
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(HomeVM.Action.endRefresh)
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
            let valueEth = state.inputValueEth
            let to = state.inputToAddress
            if valueEth.isEmpty || to.isEmpty {
                return .none
            }

            state.shouldShowHUD = true

            let address = state.address
            let flow = Future<String, AppError> { promise in
                let web3 = web3(provider: Web3HttpProvider(URL(string: Env["NETWORK_URL"]!)!)!)
                let privateKey = DataStore.shared.getPrivateKey()!
                let keystore = try! EthereumKeystoreV3(privateKey: privateKey)!
                let keystoreManager = KeystoreManager([keystore])
                web3.addKeystoreManager(keystoreManager)

                let toAddress = EthereumAddress(to)!
                let amount = Web3.Utils.parseToBigUInt(valueEth, units: .eth)!
                var options = TransactionOptions.defaultOptions
                options.value = amount
                options.from = address
                options.to = toAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic

                let tx = web3.eth.sendETH(
                    from: address,
                    to: toAddress,
                    amount: valueEth,
                    units: .eth,
                    extraData: Data(),
                    transactionOptions: options
                )!

                do {
                    let result = try tx.send()
                    promise(.success(result.transaction.txhash ?? ""))
                } catch {
                    print("send tx error: \(error)")
                    promise(.failure(AppError.plain(error.localizedDescription)))
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(HomeVM.Action.endSendTransaction)
        case .endSendTransaction(.success(let txhash)):
            print("create tx: \(txhash)")
            state.inputValueEth = ""
            state.inputToAddress = ""
            state.shouldShowHUD = false
            return .none
        case .endSendTransaction(.failure(_)):
            state.shouldShowHUD = false
            return .none
        case .inputValueEth(let val):
            state.inputValueEth = val
            return .none
        case .inputToAddress(let val):
            state.inputToAddress = val
            return .none
        }
    }
}

extension HomeVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<String, AppError>)
        case startRefresh
        case endRefresh(Result<String, AppError>)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
        case startSendTransaction
        case endSendTransaction(Result<String, AppError>)
        case inputValueEth(String)
        case inputToAddress(String)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""

        var inputValueEth = ""
        var inputToAddress = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
