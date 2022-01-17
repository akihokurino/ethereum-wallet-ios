import Combine
import ComposableArchitecture
import Foundation

enum HomeVM {
    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { state, action, environment in
            switch action {
            case .startInitialize:
                guard !state.isInitialized else {
                    return .none
                }
                
                state.shouldShowHUD = true

                let flow = Future<Void, Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        promise(.success(()))
                    }
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map { _ in true }
                    .map(HomeVM.Action.endInitialize)
            case .endInitialize:
                state.isInitialized = true
                state.shouldShowHUD = false
                return .none
            case .startRefresh:
                state.shouldPullToRefresh = true

                let flow = Future<Void, Never> { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        promise(.success(()))
                    }
                }

                return flow
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map { _ in true }
                    .map(HomeVM.Action.endRefresh)
            case .endRefresh:
                state.shouldPullToRefresh = false
                return .none
            case .shouldShowHUD(let val):
                state.shouldShowHUD = val
                return .none
            case .shouldPullToRefresh(let val):
                state.shouldPullToRefresh = val
                return .none
            }
        }
    )
}

extension HomeVM {
    enum Action: Equatable {
        case startInitialize
        case endInitialize(Bool)
        case startRefresh
        case endRefresh(Bool)
        case shouldShowHUD(Bool)
        case shouldPullToRefresh(Bool)
    }

    struct State: Equatable {
        var shouldShowHUD = false
        var shouldPullToRefresh = false
        var isInitialized = false
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
