import Combine
import ComposableArchitecture
import Core
import Foundation
import BigInt

enum HomeVM {
    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            guard !state.isInitialized else {
                return .none
            }

            state.shouldShowHUD = true

            let address = state.address
            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .background) {
                    let web3 = await Ethereum.shared.web3()
                    do {
                        let balanceWei: BigUInt = try await web3.eth.getBalance(for: address)
                        let balanceEther = Units.toEtherString(wei: balanceWei)
                        promise(.success(balanceEther))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
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
                Task.detached(priority: .background) {
                    let web3 = await Ethereum.shared.web3()
                    do {
                        let balanceWei = try await web3.eth.getBalance(for: address)
                        let balanceEther = Units.toEtherString(wei: balanceWei)
                        promise(.success(balanceEther))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
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

            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .background) {
                    let web3 = await Ethereum.shared.web3()
                   
                    var transaction: CodableTransaction = .emptyTransaction
                    transaction.from = transaction.sender
                    transaction.to = EthereumAddress(to)!
                    transaction.value = Utilities.parseToBigUInt(valueEth, units: .eth)!
                    transaction.gasLimitPolicy = .manual(78423)
                    transaction.gasPricePolicy = .manual(20000000000)
                    
                    do {
                        let result = try await web3.eth.send(transaction)
                        let hash = result.transaction.hash!
                        promise(.success(String(data: hash, encoding: .utf8)!))
                    } catch {
                        print(error.localizedDescription)
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(HomeVM.Action.endSendTransaction)
        case .endSendTransaction(.success(let txhash)):
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
        case .startExportPrivateKey:
            state.shouldShowHUD = true

            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .background) {
                    do {
                        promise(.success(try Ethereum.shared.export()))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(HomeVM.Action.endExportPrivateKey)
        case .endExportPrivateKey(.success(let key)):
            state.privateKey = key
            state.shouldShowHUD = false
            return .none
        case .endExportPrivateKey(.failure(_)):
            state.shouldShowHUD = false
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
        case startExportPrivateKey
        case endExportPrivateKey(Result<String, AppError>)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""
        var privateKey = ""

        var inputValueEth = ""
        var inputToAddress = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
