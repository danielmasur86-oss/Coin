import SwiftUI

/// Główny ekran: górny pasek, powierzchnia z windą i magazynem, szyby pod ziemią.
struct MineView: View {
    @EnvironmentObject private var engine: MineEngine
    @State private var upgradeTarget: UnitKind?
    @State private var showShop = false

    var body: some View {
        VStack(spacing: 0) {
            TopBar(showShop: $showShop)

            ScrollView {
                VStack(spacing: 0) {
                    SurfaceView(upgradeTarget: $upgradeTarget)
                    ForEach(engine.state.shafts.indices, id: \.self) { index in
                        ShaftRow(index: index, upgradeTarget: $upgradeTarget)
                    }
                    NewShaftPanel(showShop: $showShop)
                }
            }
            .background(Color.dirt)

            BottomBar(showShop: $showShop)
        }
        .background(Color.panelBlue.ignoresSafeArea())
        .sheet(item: $upgradeTarget) { kind in
            UpgradeSheet(kind: kind)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showShop) {
            ShopView()
        }
        .sheet(item: $engine.offlineReport) { report in
            OfflineSheet(report: report)
                .presentationDetents([.height(340)])
                .interactiveDismissDisabled()
        }
    }
}

// MARK: - Górny pasek

private struct TopBar: View {
    @EnvironmentObject private var engine: MineEngine
    @Binding var showShop: Bool

    var body: some View {
        HStack(spacing: 6) {
            StatPill(icon: "💤", title: "Pasywnie", value: "\(NumberFormat.short(engine.idleIncomePerSecond))/s")
            StatPill(icon: "💰", title: "Gotówka", value: NumberFormat.short(engine.state.cash))
            Button { showShop = true } label: {
                StatPill(icon: "💎", title: "Diamenty", value: "\(engine.state.diamonds)", showsPlus: true)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.panelBlue)
    }
}

// MARK: - Powierzchnia

private struct SurfaceView: View {
    @EnvironmentObject private var engine: MineEngine
    @Binding var upgradeTarget: UnitKind?

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [.skyTop, .skyBottom], startPoint: .top, endPoint: .bottom)
            Mountains()
                .fill(Color.white.opacity(0.85))
                .frame(height: 120)
                .padding(.bottom, 30)
            Rectangle()
                .fill(Color.grass)
                .frame(height: 30)

            HStack(alignment: .bottom, spacing: 8) {
                Station(kind: .elevator, upgradeTarget: $upgradeTarget)
                Spacer(minLength: 0)
                VStack(spacing: 4) {
                    if engine.boostRemaining > 0 {
                        Text("🚀 x2  \(NumberFormat.duration(engine.boostRemaining))")
                            .font(.caption.weight(.heavy).monospacedDigit())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange, in: Capsule())
                    }
                    Text("💰 \(NumberFormat.short(engine.potentialIncomePerSecond))/s")
                        .font(.caption.weight(.heavy).monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.35), in: Capsule())
                    Text("🪨 \(NumberFormat.short(engine.state.surfaceStock))")
                        .font(.subheadline.weight(.heavy).monospacedDigit())
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                    Text("🏔️⛺")
                        .font(.system(size: 34))
                }
                .padding(.bottom, 6)
                Spacer(minLength: 0)
                Station(kind: .warehouse, upgradeTarget: $upgradeTarget)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .frame(height: 250)
    }
}

/// Winda / magazyn na powierzchni.
private struct Station: View {
    let kind: UnitKind
    @Binding var upgradeTarget: UnitKind?

    var body: some View {
        VStack(spacing: 6) {
            Text(kind.title.uppercased())
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.panelBlueDark, in: Capsule())
            LevelButton(kind: kind) { upgradeTarget = kind }
            WorkerButton(kind: kind)
            ManagerButton(kind: kind)
        }
        .padding(8)
        .background(Color.panelBlue.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Szyb

private struct ShaftRow: View {
    @EnvironmentObject private var engine: MineEngine
    let index: Int
    @Binding var upgradeTarget: UnitKind?

    var body: some View {
        let kind = UnitKind.shaft(index)
        HStack(spacing: 0) {
            // Szyb windy biegnący w dół
            ZStack {
                Color.tunnel.opacity(0.9)
                Rectangle()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 3)
                Text("\(index + 1)")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.panelBlueDark, in: RoundedRectangle(cornerRadius: 8))
            }
            .frame(width: 48)

            ZStack {
                LinearGradient(colors: [.dirt, .dirtDark], startPoint: .top, endPoint: .bottom)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.tunnel)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 6)

                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(kind.title.uppercased())
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Color.gold)
                        Text("🪨 \(NumberFormat.short(engine.state.shafts[index].deposit))")
                            .font(.headline.weight(.heavy).monospacedDigit())
                            .foregroundStyle(.white)
                        Text("\(NumberFormat.short(engine.currentRate(kind)))/s")
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer(minLength: 0)
                    ManagerButton(kind: kind)
                    WorkerButton(kind: kind)
                    LevelButton(kind: kind) { upgradeTarget = kind }
                }
                .padding(.horizontal, 18)
            }
        }
        .frame(height: 120)
    }
}

// MARK: - Nowy szyb

private struct NewShaftPanel: View {
    @EnvironmentObject private var engine: MineEngine
    @Binding var showShop: Bool

    var body: some View {
        VStack(spacing: 10) {
            if engine.canUnlockShaft {
                Text("Nowy szyb")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)
                HStack(spacing: 10) {
                    let cashCost = engine.nextShaftCashCost
                    let diamondCost = engine.nextShaftDiamondCost
                    Button {
                        if engine.unlockShaftWithCash() { Haptics.success() } else { Haptics.error() }
                    } label: {
                        Text("💰 \(NumberFormat.short(cashCost))")
                    }
                    .buttonStyle(BigButtonStyle(color: engine.state.cash >= cashCost ? .gold : .gray.opacity(0.6)))

                    Button {
                        if engine.unlockShaftWithDiamonds() {
                            Haptics.success()
                        } else {
                            showShop = true
                        }
                    } label: {
                        Text("💎 \(diamondCost)")
                    }
                    .buttonStyle(BigButtonStyle(color: .panelBlue, textColor: .white))
                }
            } else {
                Text("🏆 Wszystkie szyby odblokowane!")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.dirtDark)
    }
}

// MARK: - Dolny pasek

private struct BottomBar: View {
    @EnvironmentObject private var engine: MineEngine
    @Binding var showShop: Bool

    var body: some View {
        HStack(spacing: 10) {
            Button { showShop = true } label: {
                Label("Sklep", systemImage: "cart.fill")
            }
            .buttonStyle(BigButtonStyle(color: .gold))

            let wait = engine.freeBoostAvailableIn
            Button {
                if engine.claimFreeBoost() { Haptics.success() }
            } label: {
                if wait > 0 {
                    Text("🎁 \(NumberFormat.duration(wait))")
                        .monospacedDigit()
                } else {
                    Text("🎁 Darmowy x2")
                }
            }
            .buttonStyle(BigButtonStyle(color: wait > 0 ? .gray.opacity(0.6) : .cashGreen, textColor: .white))
            .disabled(wait > 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.panelBlue)
    }
}
