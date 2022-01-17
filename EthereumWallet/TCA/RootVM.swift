import ComposableArchitecture
import Foundation

enum RootVM {
    static let reducer = Reducer<State, Action, Environment>.combine(
        HomeVM.reducer.optional().pullback(
            state: \RootVM.State.homeView,
            action: /RootVM.Action.homeView,
            environment: { _environment in
                HomeVM.Environment(mainQueue: _environment.mainQueue, backgroundQueue: _environment.backgroundQueue)
            }
        ),
        HistoryVM.reducer.optional().pullback(
            state: \RootVM.State.historyView,
            action: /RootVM.Action.historyView,
            environment: { _environment in
                HistoryVM.Environment(mainQueue: _environment.mainQueue, backgroundQueue: _environment.backgroundQueue)
            }
        ),
        Reducer { _, action, _ in
            switch action {
            case .onAppear:
                return .none
            case .homeView(let action):
                return .none
            case .historyView(let action):
                return .none
            }
        }
    )
}

extension RootVM {
    enum Action: Equatable {
        case onAppear

        case homeView(HomeVM.Action)
        case historyView(HistoryVM.Action)
    }

    struct State: Equatable {
        var homeView: HomeVM.State? = HomeVM.State()
        var historyView: HistoryVM.State? = HistoryVM.State()
    }

    struct Environment {
        let mainQueue: AnySchedulerOf<DispatchQueue>
        let backgroundQueue: AnySchedulerOf<DispatchQueue>
    }
}
