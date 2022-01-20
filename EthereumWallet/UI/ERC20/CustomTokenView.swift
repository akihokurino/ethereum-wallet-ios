import ComposableArchitecture
import SwiftUI
import SwiftUIRefresh
import web3swift

struct CustomTokenView: View {
    let store: Store<CustomTokenVM.State, CustomTokenVM.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                VStack(alignment: .leading) {
                    Button(action: {
                        print(viewStore.state.address)
                    }) {
                        Text("アドレス: \n\(viewStore.state.address.address)")
                            .lineLimit(nil)
                    }
                    Spacer().frame(height: 20)
                    Text("\(viewStore.state.balance) CMTN")
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
                    TextFieldView(value: viewStore.binding(
                        get: \.inputValueCMTN,
                        send: CustomTokenVM.Action.inputValueCMTN
                    ), label: "取引額（CMTN）", keyboardType: .decimalPad)
                    Spacer().frame(height: 10)
                    TextFieldView(value: viewStore.binding(
                        get: \.inputToAddress,
                        send: CustomTokenVM.Action.inputToAddress
                    ), label: "宛先", keyboardType: .emailAddress)
                    Spacer().frame(height: 30)
                    ActionButton(text: "送信", background: .primary) {
                        viewStore.send(.startSendTransaction)
                    }
                }
                .padding()
                .background(Color.black)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("CustomToken", displayMode: .inline)
            .onAppear {
                viewStore.send(.startInitialize)
            }
            .overlay(
                Group {
                    if viewStore.state.shouldShowHUD {
                        HUD(isLoading: viewStore.binding(
                            get: \.shouldShowHUD,
                            send: CustomTokenVM.Action.shouldShowHUD
                        ))
                    }
                }, alignment: .center
            )
            .pullToRefresh(isShowing: viewStore.binding(
                get: \.shouldPullToRefresh,
                send: CustomTokenVM.Action.shouldPullToRefresh
            )) {
                viewStore.send(.startRefresh)
            }
        }
    }
}
