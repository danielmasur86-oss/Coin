import SwiftUI

/// „Witaj z powrotem” – zarobki kierowników, gdy gracza nie było.
struct OfflineSheet: View {
    @EnvironmentObject private var engine: MineEngine
    let report: OfflineReport

    var body: some View {
        VStack(spacing: 14) {
            Text("Witaj z powrotem! 👋")
                .font(.title2.weight(.heavy))
            Text("Twoi kierownicy pracowali przez \(NumberFormat.duration(report.seconds)).")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("💰 \(NumberFormat.short(report.amount))")
                .font(.system(size: 38, weight: .heavy).monospacedDigit())

            Button {
                Haptics.success()
                engine.claimOffline(report, doubled: true)
            } label: {
                Text("Odbierz x2  •  💎 \(Economy.doubleOfflineDiamondCost)")
            }
            .buttonStyle(BigButtonStyle(color: .panelBlue, textColor: .white))
            .disabled(engine.state.diamonds < Economy.doubleOfflineDiamondCost)

            Button {
                engine.claimOffline(report, doubled: false)
            } label: {
                Text("Odbierz")
            }
            .buttonStyle(BigButtonStyle())

            Text("Limit dochodu offline: \(Int(engine.offlineCapHours)) h")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
    }
}
