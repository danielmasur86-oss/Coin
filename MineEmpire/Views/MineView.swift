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
                    VStack(spacing: 0) {
                        ForEach(engine.state.shafts.indices, id: \.self) { index in
                            ShaftRow(index: index, upgradeTarget: $upgradeTarget)
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        ElevatorTrack(shaftCount: engine.state.shafts.count,
                                      working: engine.isWorking(.elevator))
                            .frame(width: 48)
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

            HaulerWalker(working: engine.isWorking(.warehouse))
                .padding(.bottom, 2)

            HStack(alignment: .bottom, spacing: 8) {
                Station(kind: .elevator, upgradeTarget: $upgradeTarget)
                Spacer(minLength: 0)
                Station(kind: .warehouse, upgradeTarget: $upgradeTarget)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)

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
                    .font(.caption.weight(.heavy).monospacedDigit())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.35), in: Capsule())
                Spacer()
            }
            .padding(.top, 10)
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
    let index: Int
    @Binding var upgradeTarget: UnitKind?

    var body: some View {
        HStack(spacing: 0) {
            // Szyb windy biegnący w dół (kabina rysowana jest nad wszystkimi szybami)
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
                ShaftTunnel(index: index, upgradeTarget: $upgradeTarget)
                    .padding(.vertical, 11)
                    .padding(.horizontal, 6)
            }
        }
        .frame(height: 120)
    }
}

/// Wnętrze szybu: skrzynia z urobkiem, kierownik, górnik chodzący do ściany rudy.
private struct ShaftTunnel: View {
    @EnvironmentObject private var engine: MineEngine
    let index: Int
    @Binding var upgradeTarget: UnitKind?

    var body: some View {
        let kind = UnitKind.shaft(index)
        let working = engine.isWorking(kind)
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let floorY = h - 5
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [Color(red: 0.23, green: 0.17, blue: 0.15), .tunnel],
                                         startPoint: .top, endPoint: .bottom))
                Circle()
                    .fill(Color(red: 1, green: 0.91, blue: 0.63))
                    .frame(width: 8, height: 8)
                    .shadow(color: .yellow.opacity(0.6), radius: 10)
                    .offset(x: w * 0.42, y: 6)
                OreWall(seed: index)
                    .frame(width: w * 0.22, height: h)
                    .offset(x: w - 72 - w * 0.22)
                OreCrate()
                    .frame(width: 44, height: 32)
                    .offset(x: 4, y: floorY - 32)
                VStack(alignment: .leading, spacing: 0) {
                    Text("🪨 \(NumberFormat.short(engine.state.shafts[index].deposit))")
                        .font(.subheadline.weight(.heavy).monospacedDigit())
                    Text("\(NumberFormat.short(engine.currentRate(kind)))/s")
                        .font(.caption2.weight(.semibold).monospacedDigit())
                        .opacity(0.7)
                }
                .foregroundStyle(.white)
                .shadow(radius: 2)
                .offset(x: 6, y: 4)

                if engine.isManaged(kind) {
                    IdleCharacter(role: .boss)
                        .frame(width: 30, height: 42)
                        .offset(x: 46, y: floorY - 42)
                } else {
                    ManagerButton(kind: kind)
                        .offset(x: 50, y: 4)
                }

                MinerWalker(working: working, startX: 86, endX: max(90, w * 0.78 - 98), floorY: floorY)

                if !working {
                    Text("DOTKNIJ")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.gold, in: Capsule())
                        .offset(x: 112, y: floorY - 66)
                        .allowsHitTesting(false)
                }

                LevelButton(kind: kind) { upgradeTarget = kind }
                    .offset(x: w - 68, y: (h - 58) / 2)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.tap()
                engine.tap(kind)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(working ? "\(kind.title) pracuje" : "\(kind.title). Dotknij, aby uruchomić")
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
