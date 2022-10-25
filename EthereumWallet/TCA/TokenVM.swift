import Combine
import ComposableArchitecture
import Core
import Foundation
import web3swift
import BigInt

enum TokenVM {
    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .startInitialize:
            guard !state.isInitialized else {
                return .none
            }

            state.shouldShowHUD = true

            let address = state.address
            let token = state.token
            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .background) {
                    let web3 = await Ethereum.shared.web3()
                    let contract = web3.contract(Web3.Utils.erc20ABI, at: token.address, abiVersion: 2)!

                    do {
                        let result = try await contract.createReadOperation(
                            "balanceOf",
                            parameters: [address] as [AnyObject],
                            extraData: Data())!.callContractMethod()
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
                .map(TokenVM.Action.endInitialize)
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
            let token = state.token
            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .background) {
                    let web3 = await Ethereum.shared.web3()
                    let contract = web3.contract(Web3.Utils.erc20ABI, at: token.address, abiVersion: 2)!

                    do {
                        let result = try await contract.createReadOperation(
                            "balanceOf",
                            parameters: [address] as [AnyObject],
                            extraData: Data())!.callContractMethod()
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
                .map(TokenVM.Action.endRefresh)
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
            let amount = state.inputAmount
            let to = state.inputToAddress
            if amount.isEmpty || to.isEmpty {
                return .none
            }

            state.shouldShowHUD = true

            let address = state.address
            let token = state.token
            let flow = Future<String, AppError> { promise in
                Task.detached(priority: .background) {
                    let web3 = await Ethereum.shared.web3()
                    let toAddress = EthereumAddress(to)!
                    let contract = web3.contract(Web3.Utils.erc20ABI, at: token.address, abiVersion: 2)!
                    let amount = Utilities.parseToBigUInt(amount, decimals: 0)!

                    do {
                        let result = try await contract.createWriteOperation(
                            "transfer",
                            parameters: [toAddress, amount] as [AnyObject],
                            extraData: Data())!.writeToChain(password: Ethereum.shared.password)
                        let hash = result.transaction.hash!
                        promise(.success(String(data: hash, encoding: .utf8)!))
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
                .map(TokenVM.Action.endSendTransaction)
        case .endSendTransaction(.success(let txhash)):
            state.inputAmount = ""
            state.inputToAddress = ""
            state.shouldShowHUD = false
            return .none
        case .endSendTransaction(.failure(_)):
            state.shouldShowHUD = false
            return .none
        case .inputAmount(let val):
            state.inputAmount = val
            return .none
        case .inputToAddress(let val):
            state.inputToAddress = val
            return .none
        }
    }
}

extension TokenVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Result<String, AppError>)
        case startRefresh
        case endRefresh(Result<String, AppError>)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
        case startSendTransaction
        case endSendTransaction(Result<String, AppError>)
        case inputAmount(String)
        case inputToAddress(String)
    }

    struct State: Equatable {
        let address: EthereumAddress
        let token: ERC20Token

        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
        var balance = ""

        var inputAmount = ""
        var inputToAddress = ""
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
