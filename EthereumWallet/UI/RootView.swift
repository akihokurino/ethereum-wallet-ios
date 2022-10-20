import ComposableArchitecture
import SwiftUI

struct RootView: View {
    let store: Store<RootVM.State, RootVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                NavigationView {
                    IfLetStore(
                        store.scope(
                            state: { $0.homeView },
                            action: RootVM.Action.homeView
                        ),
                        then: HomeView.init(store:)
                    )
                }
                .tabItem {
                    VStack {
                        Image(systemName: "wallet.pass")
                        Text("イーサ")
                    }
                }.tag(1)

                NavigationView {
                    IfLetStore(
                        store.scope(
                            state: { $0.selectTokenView },
                            action: RootVM.Action.selectTokenView
                        ),
                        then: SelectTokenView.init(store:)
                    )
                }
                .tabItem {
                    VStack {
                        Image(systemName: "folder")
                        Text("トークン")
                    }
                }.tag(2)

                NavigationView {
                    IfLetStore(
                        store.scope(
                            state: { $0.historyView },
                            action: RootVM.Action.historyView
                        ),
                        then: HistoryView.init(store:)
                    )
                }
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("履歴")
                    }
                }.tag(3)
            }
            .onAppear {
                viewStore.send(.initialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: RootVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
        }
    }
}
