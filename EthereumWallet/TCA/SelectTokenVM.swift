import Combine
import ComposableArchitecture
import Core
import Foundation
import web3swift

enum SelectTokenVM {
    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .initialize:
            let tokens = DataStore.shared.getTokens().map { ERC20Token.restore(from: $0) }
            state.tokens = tokens
            return .none
        case .presentTokenView(let token):
            state.tokenView = TokenVM.State(address: state.address, token: token)
            return .none
        case .popTokenView:
            state.tokenView = nil
            return .none
        case .tokenView(let action):
            return .none
        case .addToken:
            guard let address = EthereumAddress(state.inputERC20Address) else {
                return .none
            }

            let flow = Future<ERC20Token, AppError> { promise in
                Task.detached(priority: .background) {
                    let web3 = await Ethereum.shared.web3()
                    let contract = web3.contract(Web3.Utils.erc20ABI, at: address, abiVersion: 2)!

                    do {
                        let result = try await contract.createReadOperation(
                            "name",
                            parameters: [],
                            extraData: Data()
                        )!.callContractMethod()
                        let name = result["0"] as! String
                        let token = ERC20Token(address: address, name: name)
                        var current = DataStore.shared.getTokens()
                        current.append(token.data)
                        DataStore.shared.saveTokens(val: current)
                        promise(.success(token))
                    } catch {
                        promise(.failure(AppError.plain(error.localizedDescription)))
                    }
                }
            }

            return flow
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(SelectTokenVM.Action.addedToken)
        case .addedToken(.success(let token)):
            var current = state.tokens
            current.append(token)
            state.inputERC20Address = ""
            state.tokens = current
            return .none
        case .addedToken(.failure(_)):
            return .none
        case .inputERC20Address(let val):
            state.inputERC20Address = val
            return .none
        }
    }
    .connect(
        TokenVM.reducer,
        state: \.tokenView,
        action: /SelectTokenVM.Action.tokenView,
        environment: { _environment in
            TokenVM.Environment(
                mainQueue: _environment.mainQueue,
                backgroundQueue: _environment.backgroundQueue
            )
        }
    )
}

struct ERC20Token: Hashable, Equatable {
    let address: EthereumAddress
    let name: String

    var id: String {
        return address.address
    }

    var data: [String: String] {
        return [
            "address": id,
            "name": name
        ]
    }

    static func restore(from: [String: Any]) -> ERC20Token {
        return ERC20Token(address: EthereumAddress(from["address"] as! String)!, name: from["name"] as! String)
    }
}

extension SelectTokenVM {
    enum Action: Equatable {
        case initialize
        case presentTokenView(ERC20Token)
        case popTokenView
        case addToken
        case addedToken(Result<ERC20Token, AppError>)
        case inputERC20Address(String)

        case tokenView(TokenVM.Action)
    }

    struct State: Equatable {
        let address: EthereumAddress

        var inputERC20Address = ""
        var tokens: [ERC20Token] = []

        var tokenView: TokenVM.State?
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
