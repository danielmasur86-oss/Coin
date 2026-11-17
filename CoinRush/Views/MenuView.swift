import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var data: GameData
    @State private var showShop = false
    @State private var bounce = false
    let onPlay: () -> Void

    var body: some View {
        ZStack {
            GameBackground()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    CoinBadge(amount: data.coins)
                }

                Spacer()

                Text("🪙")
                    .font(.system(size: 110))
                    .offset(y: bounce ? -12 : 12)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: bounce)
                    .accessibilityHidden(true)

                Text("Coin Rush")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(Color.coinGold)

                Text("Łap monety, unikaj bomb!")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))

                if data.bestScore > 0 {
                    Text("Rekord: \(data.bestScore)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }

                if data.hasDoubleCoins {
                    Label("Podwójne monety aktywne", systemImage: "sparkles")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.coinGold)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button("GRAJ", action: onPlay)
                        .buttonStyle(BigButtonStyle())

                    Button {
                        showShop = true
                    } label: {
                        Label("Sklep", systemImage: "cart.fill")
                    }
                    .buttonStyle(BigButtonStyle(color: .white.opacity(0.15), textColor: .white))
                }
            }
            .padding(24)
        }
        .onAppear { bounce = true }
        .sheet(isPresented: $showShop) {
            ShopView()
        }
    }
}
