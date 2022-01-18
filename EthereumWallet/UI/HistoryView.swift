import ComposableArchitecture
import SwiftUI

struct HistoryView: View {
    let store: Store<HistoryVM.State, HistoryVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                InHistoryView()
                OutHistoryView()
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("履歴", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: HistoryVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
            .pullToRefresh(isShowing: viewStore.binding(
                get: \.shouldPullToRefresh,
                send: HistoryVM.Action.shouldPullToRefresh
            )) {
                viewStore.send(.startRefresh)
            }
        }
    }
}

struct InHistoryView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
            
            Spacer().frame(width: 10)

            VStack(alignment: .leading) {
                Text("トランザクションハッシュ: \n0x1341048E3d37046Ca18A09EFB154Ea9771744f41")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("送り元: \n0x1341048E3d37046Ca18A09EFB154Ea9771744f41")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("総額: 100 Ether")
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("日付: 2022/01/01 12:00")
                    .foregroundColor(Color.white)
            }
            .padding()
            .background(Color(red: 0, green: 201.0 / 255.0, blue: 167.0 / 255.0))
            .cornerRadius(5.0)
        }
    }
}

struct OutHistoryView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("トランザクションハッシュ: \n0x1341048E3d37046Ca18A09EFB154Ea9771744f41")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("送り先: \n0x1341048E3d37046Ca18A09EFB154Ea9771744f41")
                    .lineLimit(nil)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("総額: 100 Ether")
                    .foregroundColor(Color.white)
                Spacer().frame(height: 10)
                Text("日付: 2022/01/01 12:00")
                    .foregroundColor(Color.white)
            }
            .padding()
            .background(Color(red: 219.0 / 255.0, green: 154.0 / 255.0, blue: 4.0 / 255.0))
            .cornerRadius(5.0)
            
            Spacer().frame(width: 10)

            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
        }
    }
}
