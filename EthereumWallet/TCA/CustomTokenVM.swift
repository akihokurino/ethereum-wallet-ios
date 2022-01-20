import ComposableArchitecture
import Foundation
import web3swift

enum CustomTokenVM {
    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { _, action, _ in
            switch action {
            case .initialize:
                return .none
            }
        }
    )
}

extension CustomTokenVM {
    enum Action: Equatable {
        case initialize
    }

    struct State: Equatable {
        let address: EthereumAddress
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
