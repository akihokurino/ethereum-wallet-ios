import ComposableArchitecture
import SwiftUI
import SwiftUIRefresh

struct HomeView: View {
    let store: Store<HomeVM.State, HomeVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Text("Item 1")
                    .listRowSeparator(.hidden)
                Text("Item 2")
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("ホーム", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                HUD(isLoading: viewStore.binding(
                    get: \.shouldShowHUD,
                    send: HomeVM.Action.shouldShowHUD
                )), alignment: .center
            )
            .pullToRefresh(isShowing: viewStore.binding(
                get: \.shouldPullToRefresh,
                send: HomeVM.Action.shouldPullToRefresh
            )) {
                viewStore.send(.startRefresh)
            }
        }
    }
}
