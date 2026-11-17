import SwiftUI

extension Color {
    static let backgroundTop = Color(red: 0.10, green: 0.12, blue: 0.32)
    static let backgroundBottom = Color(red: 0.03, green: 0.04, blue: 0.12)
    static let coinGold = Color(red: 1.0, green: 0.78, blue: 0.15)
}

struct GameBackground: View {
    var body: some View {
        LinearGradient(colors: [.backgroundTop, .backgroundBottom], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

struct CoinBadge: View {
    let amount: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("🪙")
            Text(amount, format: .number)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Monety: \(amount)")
    }
}

struct BigButtonStyle: ButtonStyle {
    var color: Color = .coinGold
    var textColor: Color = .black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.heavy))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(color, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
