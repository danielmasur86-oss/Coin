import StoreKit
import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var data: GameData
    @EnvironmentObject private var store: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Twoje monety")
                        Spacer()
                        CoinBadge(amount: data.coins)
                    }
                }

                Section("Pakiety monet") {
                    if store.coinPacks.isEmpty {
                        storeUnavailableRow
                    } else {
                        ForEach(store.coinPacks, id: \.id) { product in
                            productRow(product, icon: icon(for: product))
                        }
                    }
                }

                if !store.upgrades.isEmpty {
                    Section {
                        ForEach(store.upgrades, id: \.id) { product in
                            productRow(product, icon: "✨")
                        }
                    } header: {
                        Text("Ulepszenia")
                    } footer: {
                        Text("Podwójne monety to zakup jednorazowy – działa na zawsze i na wszystkich Twoich urządzeniach.")
                    }
                }

                Section("Skórki koszyka (za monety)") {
                    ForEach(BasketSkin.all) { skin in
                        skinRow(skin)
                    }
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
                    Button("Gotowe") { dismiss() }
                }
            }
            .alert("Błąd", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.errorMessage ?? "")
            }
            .alert("Sukces", isPresented: successBinding) {
                Button("Super!", role: .cancel) {}
            } message: {
                Text(store.successMessage ?? "")
            }
        }
    }

    // MARK: - Wiersze

    private func productRow(_ product: Product, icon: String) -> some View {
        let owned = store.isOwned(product)
        let isBuying = store.purchasingProductID == product.id

        return HStack(spacing: 14) {
            Text(icon).font(.largeTitle)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName).font(.headline)
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if owned {
                Label("Kupione", systemImage: "checkmark.seal.fill")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.green)
                    .accessibilityLabel("Kupione")
            } else if isBuying {
                ProgressView()
            } else {
                Button(product.displayPrice) {
                    Task { await store.purchase(product) }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.coinGold)
                .foregroundStyle(.black)
                .disabled(store.purchasingProductID != nil)
            }
        }
        .padding(.vertical, 4)
    }

    private func skinRow(_ skin: BasketSkin) -> some View {
        let owned = data.owns(skin)
        let selected = data.selectedSkinID == skin.id

        return HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: skin.color))
                .frame(width: 48, height: 18)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white, lineWidth: 2))
                .accessibilityHidden(true)
            Text(skin.name).font(.headline)
            Spacer()
            if selected {
                Text("Wybrany").font(.subheadline.weight(.semibold)).foregroundStyle(.green)
            } else if owned {
                Button("Wybierz") { data.selectedSkinID = skin.id }
                    .buttonStyle(.bordered)
            } else {
                Button("\(skin.price) 🪙") { data.buySkin(skin) }
                    .buttonStyle(.bordered)
                    .disabled(data.coins < skin.price)
            }
        }
    }

    private var storeUnavailableRow: some View {
        HStack {
            if store.isLoading {
                ProgressView()
                Text("Wczytywanie sklepu…").foregroundStyle(.secondary)
            } else {
                Text("Sklep jest chwilowo niedostępny.").foregroundStyle(.secondary)
                Spacer()
                Button("Ponów") { Task { await store.loadProducts() } }
            }
        }
    }

    private func icon(for product: Product) -> String {
        switch store.coinAmount(for: product) ?? 0 {
        case ..<1_000: return "🪙"
        case ..<5_000: return "💰"
        default: return "🏦"
        }
    }

    // MARK: - Alerty

    private var errorBinding: Binding<Bool> {
        Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })
    }

    private var successBinding: Binding<Bool> {
        Binding(get: { store.successMessage != nil }, set: { if !$0 { store.successMessage = nil } })
    }
}
