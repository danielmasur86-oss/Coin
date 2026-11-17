import SpriteKit
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var data: GameData
    @StateObject private var session = GameSession()
    @State private var showShop = false
    let onExit: () -> Void

    var body: some View {
        ZStack {
            SpriteView(scene: session.scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()

            VStack {
                hud
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            if session.isGameOver {
                gameOverPanel
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35), value: session.isGameOver)
        .onAppear {
            session.configure(with: data)
            session.start()
        }
        .sheet(isPresented: $showShop) {
            ShopView()
        }
        .statusBarHidden()
    }

    private var hud: some View {
        HStack {
            Button {
                session.quit()
                onExit()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Zakończ grę")

            Spacer()

            Text("\(session.score)")
                .font(.system(size: 34, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .accessibilityLabel("Wynik \(session.score)")

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(repeating: "❤️", count: max(session.lives, 0)))
                    .font(.footnote)
                    .accessibilityLabel("Życia: \(session.lives)")
                Text("+\(session.coinsEarned) 🪙")
                    .font(.footnote.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.coinGold)
            }
        }
    }

    private var gameOverPanel: some View {
        VStack(spacing: 16) {
            Text("Koniec gry")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.white)

            if session.isNewRecord {
                Text("🏆 Nowy rekord!")
                    .font(.headline)
                    .foregroundStyle(Color.coinGold)
            }

            Text("Wynik: \(session.score)")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("Zdobyte monety: +\(session.lastRoundCoins) 🪙")
                .font(.headline)
                .foregroundStyle(Color.coinGold)

            if !session.hasRevived {
                if data.coins >= GameSession.reviveCost {
                    Button("Kontynuuj za \(GameSession.reviveCost) 🪙") {
                        _ = session.revive()
                    }
                    .buttonStyle(BigButtonStyle(color: .green, textColor: .white))
                } else {
                    Button("Kup monety, aby kontynuować") {
                        showShop = true
                    }
                    .buttonStyle(BigButtonStyle(color: .green.opacity(0.8), textColor: .white))
                }
            }

            Button("Zagraj ponownie") {
                session.configure(with: data)
                session.start()
            }
            .buttonStyle(BigButtonStyle())

            Button("Menu", action: onExit)
                .buttonStyle(BigButtonStyle(color: .white.opacity(0.15), textColor: .white))
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(24)
    }
}
