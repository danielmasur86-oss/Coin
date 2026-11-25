import StoreKit
import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var engine: MineEngine
    @EnvironmentObject private var store: MineStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Twoje diamenty")
                        Spacer()
                        Text("💎 \(engine.state.diamonds)")
                            .font(.headline.monospacedDigit())
                    }
                }

                Section("Wydaj diamenty") {
                    spendRow(icon: "🚀", title: "Boost x2 na 30 min",
                             subtitle: "Podwaja cały dochód",
                             cost: Economy.boostDiamondCost) { engine.buyBoost() }
                    spendRow(icon: "💰", title: "Walizka gotówki",
                             subtitle: "+\(NumberFormat.short(engine.instantCashAmount)) od razu (1 h produkcji)",
                             cost: Economy.instantCashDiamondCost) { engine.buyInstantCash() }
                }

                Section("Diamenty") {
                    if store.isLoading && store.diamondPacks.isEmpty {
                        ProgressView()
                    }
                    ForEach(store.diamondPacks, id: \.id) { product in
                        productRow(product,
                                   icon: "💎",
                                   title: "\(store.diamondAmount(for: product) ?? 0) diamentów",
                                   subtitle: product.description)
                    }
                }

                Section {
                    ForEach(store.upgrades, id: \.id) { product in
                        productRow(product,
                                   icon: product.id == MineStore.ProductID.doubleIncome ? "✖️2" : "🏦",
                                   title: product.displayName,
                                   subtitle: product.description)
                    }
                } header: {
                    Text("Ulepszenia na zawsze")
                } footer: {
                    Text("Zakupy są realizowane przez App Store. Ulepszenia na zawsze można przywrócić na nowym urządzeniu.")
                }

                Section {
                    Button("Przywróć zakupy") {
                        Task { await store.restorePurchases() }
                    }
                }
            }
            .navigationTitle("Sklep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zamknij") { dismiss() }
                }
            }
            .alert("Sklep", isPresented: Binding(
                get: { store.errorMessage != nil || store.successMessage != nil },
                set: { if !$0 { store.errorMessage = nil; store.successMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.errorMessage ?? store.successMessage ?? "")
            }
            .task {
                if store.diamondPacks.isEmpty { await store.loadProducts() }
            }
        }
    }

    private func spendRow(icon: String, title: String, subtitle: String, cost: Int,
                          action: @escaping () -> Bool) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.title)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("💎 \(cost)") {
                if action() { Haptics.success() } else { Haptics.error() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(engine.state.diamonds < cost)
        }
    }

    private func productRow(_ product: Product, icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.title)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if store.isOwned(product) {
                Text("Kupione ✓")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.cashGreen)
            } else if store.purchasingProductID == product.id {
                ProgressView()
            } else {
                Button(product.displayPrice) {
                    Task { await store.purchase(product) }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(store.purchasingProductID != nil)
            }
        }
    }
}
