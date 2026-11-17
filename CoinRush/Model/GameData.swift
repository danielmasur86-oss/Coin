import Foundation

/// Trwały stan gracza: monety, rekord, skórki i zakupione ulepszenia.
final class GameData: ObservableObject {
    static let shared = GameData()

    private enum Key {
        static let coins = "coins"
        static let bestScore = "bestScore"
        static let ownedSkins = "ownedSkins"
        static let selectedSkin = "selectedSkin"
        static let doubleCoins = "hasDoubleCoins"
        static let processedTransactions = "processedTransactions"
    }

    private let defaults: UserDefaults

    @Published private(set) var coins: Int
    @Published private(set) var bestScore: Int
    @Published private(set) var ownedSkins: Set<String>
    @Published var selectedSkinID: String {
        didSet { defaults.set(selectedSkinID, forKey: Key.selectedSkin) }
    }
    @Published var hasDoubleCoins: Bool {
        didSet { defaults.set(hasDoubleCoins, forKey: Key.doubleCoins) }
    }

    var coinMultiplier: Int { hasDoubleCoins ? 2 : 1 }
    var selectedSkin: BasketSkin { BasketSkin.skin(withID: selectedSkinID) }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        coins = defaults.integer(forKey: Key.coins)
        bestScore = defaults.integer(forKey: Key.bestScore)
        ownedSkins = Set(defaults.stringArray(forKey: Key.ownedSkins) ?? [BasketSkin.classic.id])
        selectedSkinID = defaults.string(forKey: Key.selectedSkin) ?? BasketSkin.classic.id
        hasDoubleCoins = defaults.bool(forKey: Key.doubleCoins)
    }

    // MARK: - Monety

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        defaults.set(coins, forKey: Key.coins)
    }

    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, coins >= amount else { return false }
        coins -= amount
        defaults.set(coins, forKey: Key.coins)
        return true
    }

    /// Dodaje monety z zakupu tylko raz na transakcję (ochrona przed podwójnym naliczeniem).
    @discardableResult
    func creditPurchase(transactionID: UInt64, coins amount: Int) -> Bool {
        var processed = Set(defaults.stringArray(forKey: Key.processedTransactions) ?? [])
        let id = String(transactionID)
        guard !processed.contains(id) else { return false }
        processed.insert(id)
        defaults.set(Array(processed), forKey: Key.processedTransactions)
        addCoins(amount)
        return true
    }

    // MARK: - Wyniki

    func submitScore(_ score: Int) {
        guard score > bestScore else { return }
        bestScore = score
        defaults.set(bestScore, forKey: Key.bestScore)
    }

    // MARK: - Skórki

    func owns(_ skin: BasketSkin) -> Bool { ownedSkins.contains(skin.id) }

    @discardableResult
    func buySkin(_ skin: BasketSkin) -> Bool {
        guard !owns(skin), spendCoins(skin.price) else { return false }
        ownedSkins.insert(skin.id)
        defaults.set(Array(ownedSkins), forKey: Key.ownedSkins)
        selectedSkinID = skin.id
        return true
    }
}
