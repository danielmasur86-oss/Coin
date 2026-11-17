import StoreKit

/// Obsługa mikropłatności (StoreKit 2).
/// Identyfikatory produktów MUSZĄ być identyczne z tymi w App Store Connect.
@MainActor
final class StoreManager: ObservableObject {

    enum ProductID {
        static let coins500 = "com.twojafirma.coinrush.coins500"
        static let coins3000 = "com.twojafirma.coinrush.coins3000"
        static let coins10000 = "com.twojafirma.coinrush.coins10000"
        static let doubleCoins = "com.twojafirma.coinrush.doublecoins"

        /// Ile monet daje każdy pakiet (produkty konsumowalne).
        static let coinAmounts: [String: Int] = [
            coins500: 500,
            coins3000: 3_000,
            coins10000: 10_000
        ]

        static let all: [String] = [coins500, coins3000, coins10000, doubleCoins]
    }

    @Published private(set) var coinPacks: [Product] = []
    @Published private(set) var upgrades: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var purchasingProductID: String?
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let gameData: GameData
    private var updatesTask: Task<Void, Never>?

    init(gameData: GameData) {
        self.gameData = gameData
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
            coinPacks = products.filter { $0.type == .consumable }
            upgrades = products.filter { $0.type == .nonConsumable }
        } catch {
            errorMessage = "Nie udało się wczytać sklepu: \(error.localizedDescription)"
        }
    }

    func coinAmount(for product: Product) -> Int? {
        ProductID.coinAmounts[product.id]
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
                apply(transaction)
                await transaction.finish()
                if let amount = coinAmount(for: product) {
                    successMessage = "Dodano \(amount) monet! 🪙"
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
            successMessage = gameData.hasDoubleCoins
                ? "Zakupy zostały przywrócone."
                : "Nie znaleziono zakupów do przywrócenia."
        } catch {
            errorMessage = "Nie udało się przywrócić zakupów: \(error.localizedDescription)"
        }
    }

    func isOwned(_ product: Product) -> Bool {
        product.id == ProductID.doubleCoins && gameData.hasDoubleCoins
    }

    // MARK: - Transakcje

    func refreshEntitlements() async {
        var ownsDoubleCoins = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == ProductID.doubleCoins,
               transaction.revocationDate == nil {
                ownsDoubleCoins = true
            }
        }
        gameData.hasDoubleCoins = ownsDoubleCoins
    }

    /// Nasłuchuje transakcji spoza aplikacji (Ask to Buy, zakupy na innym urządzeniu, zwroty).
    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    self.apply(transaction)
                    await transaction.finish()
                }
            }
        }
    }

    private func apply(_ transaction: Transaction) {
        if transaction.revocationDate != nil {
            if transaction.productID == ProductID.doubleCoins {
                gameData.hasDoubleCoins = false
            }
            return
        }

        if transaction.productID == ProductID.doubleCoins {
            gameData.hasDoubleCoins = true
        } else if let amount = ProductID.coinAmounts[transaction.productID] {
            gameData.creditPurchase(transactionID: transaction.id, coins: amount)
        }
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
