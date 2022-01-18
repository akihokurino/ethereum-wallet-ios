import ComposableArchitecture
import SwiftUI
import SwiftUIRefresh

struct HomeView: View {
    let store: Store<HomeVM.State, HomeVM.Action>

    @State private var valueEth: String = ""
    @State private var address: String = ""

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                VStack(alignment: .leading) {
                    Text("アドレス: \n0x1341048E3d37046Ca18A09EFB154Ea9771744f41")
                        .lineLimit(nil)
                    Spacer().frame(height: 20)
                    Text("100 Ether")
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 100,
                            maxHeight: 100,
                            alignment: .center
                        )
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(5.0)
                        .font(.largeTitle)
                }
                .padding()
                .background(Color.black)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())

                Spacer().frame(height: 30)

                VStack {
                    Text("取引作成")
                    Spacer().frame(height: 10)
                    TextFieldView(value: $valueEth, label: "取引額（Ether）", keyboardType: .decimalPad)
                    Spacer().frame(height: 10)
                    TextFieldView(value: $address, label: "宛先", keyboardType: .emailAddress)
                    Spacer().frame(height: 30)
                    ActionButton(text: "送信", background: .primary) {}
                }
                .padding()
                .background(Color.black)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("ホーム", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: HomeVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
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
