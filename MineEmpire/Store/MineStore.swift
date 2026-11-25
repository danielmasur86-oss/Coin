import StoreKit

/// Mikropłatności (StoreKit 2).
/// Identyfikatory produktów MUSZĄ być identyczne z tymi w App Store Connect i w MineEmpire.storekit.
@MainActor
final class MineStore: ObservableObject {

    enum ProductID {
        static let diamonds80 = "com.twojafirma.mineempire.diamonds80"
        static let diamonds500 = "com.twojafirma.mineempire.diamonds500"
        static let diamonds1200 = "com.twojafirma.mineempire.diamonds1200"
        static let doubleIncome = "com.twojafirma.mineempire.doubleincome"
        static let offlineVault = "com.twojafirma.mineempire.offlinevault"

        /// Ile diamentów daje każdy pakiet (produkty konsumowalne).
        static let diamondAmounts: [String: Int] = [
            diamonds80: 80,
            diamonds500: 500,
            diamonds1200: 1_200
        ]

        static let all: [String] = [diamonds80, diamonds500, diamonds1200, doubleIncome, offlineVault]
    }

    @Published private(set) var diamondPacks: [Product] = []
    @Published private(set) var upgrades: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var purchasingProductID: String?
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let engine: MineEngine
    private var updatesTask: Task<Void, Never>?

    init(engine: MineEngine) {
        self.engine = engine
        updatesTask = listenForTransactions()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    // MARK: - Produkty

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: ProductID.all)
                .sorted { $0.price < $1.price }
            diamondPacks = products.filter { $0.type == .consumable }
            upgrades = products.filter { $0.type == .nonConsumable }
        } catch {
            errorMessage = "Nie udało się wczytać sklepu: \(error.localizedDescription)"
        }
    }

    func diamondAmount(for product: Product) -> Int? {
        ProductID.diamondAmounts[product.id]
    }

    func isOwned(_ product: Product) -> Bool {
        switch product.id {
        case ProductID.doubleIncome: return engine.state.hasDoubleIncome
        case ProductID.offlineVault: return engine.state.hasOfflineVault
        default: return false
        }
    }

    // MARK: - Zakup

    func purchase(_ product: Product) async {
        guard purchasingProductID == nil else { return }
        purchasingProductID = product.id
        defer { purchasingProductID = nil }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await apply(transaction)
                await transaction.finish()
                if let amount = diamondAmount(for: product) {
                    successMessage = "Dodano \(amount) 💎!"
                } else {
                    successMessage = "Odblokowano: \(product.displayName) ✨"
                }
            case .pending:
                successMessage = "Zakup oczekuje na zatwierdzenie."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Zakup nie powiódł się: \(error.localizedDescription)"
        }
    }

    /// Wymagane przez Apple dla produktów niekonsumowalnych.
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            let restored = engine.state.hasDoubleIncome || engine.state.hasOfflineVault
            successMessage = restored
                ? "Zakupy zostały przywrócone."
                : "Nie znaleziono zakupów do przywrócenia."
        } catch {
            errorMessage = "Nie udało się przywrócić zakupów: \(error.localizedDescription)"
        }
    }

    // MARK: - Transakcje

    func refreshEntitlements() async {
        var doubleIncome = false
        var offlineVault = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result, transaction.revocationDate == nil else { continue }
            if transaction.productID == ProductID.doubleIncome { doubleIncome = true }
            if transaction.productID == ProductID.offlineVault { offlineVault = true }
        }
        engine.setEntitlements(doubleIncome: doubleIncome, offlineVault: offlineVault)
    }

    /// Nasłuchuje transakcji spoza aplikacji (Ask to Buy, zakupy na innym urządzeniu, zwroty).
    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await self.apply(transaction)
                    await transaction.finish()
                }
            }
        }
    }

    private func apply(_ transaction: Transaction) async {
        if ProductID.diamondAmounts[transaction.productID] == nil {
            // Produkt niekonsumowalny (lub zwrot) – przelicz uprawnienia od nowa.
            await refreshEntitlements()
            return
        }
        guard transaction.revocationDate == nil,
              let amount = ProductID.diamondAmounts[transaction.productID] else { return }
        engine.creditDiamonds(amount, transactionID: transaction.id)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
