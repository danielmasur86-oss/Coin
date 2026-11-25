import SwiftUI

struct UpgradeSheet: View {
    @EnvironmentObject private var engine: MineEngine
    let kind: UnitKind

    private enum Amount: String, CaseIterable, Identifiable {
        case one = "x1", ten = "x10", fifty = "x50", max = "MAX"
        var id: String { rawValue }
    }

    @State private var amount: Amount = .one

    private var count: Int {
        switch amount {
        case .one: return 1
        case .ten: return 10
        case .fifty: return 50
        case .max: return engine.maxAffordableLevels(kind)
        }
    }

    var body: some View {
        let level = engine.level(kind)
        let levels = min(count, Economy.maxLevel(kind) - level)
        let cost = engine.upgradeCost(kind, count: levels)
        let nextRate = Economy.rate(kind, level: level + levels)
        let affordable = levels > 0 && engine.state.cash >= cost

        VStack(spacing: 16) {
            HStack {
                Text(kind.emoji).font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text(kind.title).font(.title2.weight(.heavy))
                    Text("Poziom \(level)").foregroundStyle(.secondary)
                }
                Spacer()
            }

            Picker("Ilość", selection: $amount) {
                ForEach(Amount.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 8) {
                statRow(kind.rateLabel,
                        current: "\(NumberFormat.short(engine.currentRate(kind)))/s",
                        next: "\(NumberFormat.short(nextRate))/s")
                statRow("Poziom", current: "\(level)", next: "\(level + levels)")
                if (level + levels) / 25 > level / 25 {
                    Text("⭐ Kamień milowy – wydajność x2!")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))

            if levels > 0 {
                Button {
                    if engine.upgrade(kind, count: levels) { Haptics.success() } else { Haptics.error() }
                } label: {
                    Text("Ulepsz +\(levels)  •  💰 \(NumberFormat.short(cost))")
                }
                .buttonStyle(BigButtonStyle(color: affordable ? .gold : .gray.opacity(0.5)))
                .disabled(!affordable)
            } else {
                Text("Maksymalny poziom osiągnięty 🏆")
                    .font(.headline)
            }
        }
        .padding(20)
    }

    private func statRow(_ title: String, current: String, next: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(current).monospacedDigit()
            Image(systemName: "arrow.right").foregroundStyle(.secondary)
            Text(next).monospacedDigit().foregroundStyle(Color.cashGreen).fontWeight(.bold)
        }
        .font(.subheadline)
    }
}
