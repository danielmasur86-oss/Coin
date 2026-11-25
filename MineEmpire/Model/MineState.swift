import Foundation

struct UnitState: Codable, Equatable {
    var level: Int = 1
    var hasManager: Bool = false
    /// Do kiedy jednostka pracuje po ręcznym uruchomieniu.
    var activeUntil: Date?
}

struct ShaftState: Codable, Equatable {
    var unit = UnitState()
    /// Urobek czekający na windę.
    var deposit: Double = 0
}

/// Cały zapisywany stan gracza.
struct MineState: Codable, Equatable {
    var cash: Double = Economy.startingCash
    var diamonds: Int = Economy.startingDiamonds
    var totalEarned: Double = 0

    var shafts: [ShaftState] = [ShaftState()]
    var elevator = UnitState()
    var warehouse = UnitState()
    /// Urobek na powierzchni czekający na sprzedaż.
    var surfaceStock: Double = 0

    var boostUntil: Date?
    var lastFreeBoost: Date?
    var lastSaved: Date = Date()

    // Zakupy na zawsze (StoreKit)
    var hasDoubleIncome: Bool = false
    var hasOfflineVault: Bool = false
    var processedTransactions: [String] = []
}

struct OfflineReport: Identifiable {
    let id = UUID()
    let seconds: TimeInterval
    let amount: Double
}
