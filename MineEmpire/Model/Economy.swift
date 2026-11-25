import Foundation

/// Rodzaj jednostki w kopalni.
enum UnitKind: Hashable, Identifiable {
    case shaft(Int)
    case elevator
    case warehouse

    var id: String {
        switch self {
        case .shaft(let index): return "shaft-\(index)"
        case .elevator: return "elevator"
        case .warehouse: return "warehouse"
        }
    }

    var title: String {
        switch self {
        case .shaft(let index): return "Szyb \(index + 1)"
        case .elevator: return "Winda"
        case .warehouse: return "Magazyn"
        }
    }

    var emoji: String {
        switch self {
        case .shaft: return "⛏️"
        case .elevator: return "🛗"
        case .warehouse: return "🚚"
        }
    }

    var rateLabel: String {
        switch self {
        case .shaft: return "Wydobycie"
        case .elevator: return "Transport"
        case .warehouse: return "Sprzedaż"
        }
    }
}

/// Wszystkie liczby balansu gry w jednym miejscu.
enum Economy {
    static let maxShafts = 10
    /// Ile sekund pracuje jednostka po dotknięciu (bez kierownika).
    static let manualCycle: TimeInterval = 8
    static let startingCash: Double = 25
    static let startingDiamonds = 10

    // Dochód offline
    static let offlineCapHours: Double = 4
    static let offlineCapHoursWithVault: Double = 24

    // Wydatki diamentów
    static let boostDiamondCost = 15
    static let boostDuration: TimeInterval = 30 * 60
    static let freeBoostDuration: TimeInterval = 10 * 60
    static let freeBoostCooldown: TimeInterval = 4 * 60 * 60
    static let instantCashDiamondCost = 25
    static let instantCashHours: Double = 1
    static let doubleOfflineDiamondCost = 10

    // MARK: - Szyby

    static func shaftUnlockCost(_ index: Int) -> Double {
        index == 0 ? 0 : 500 * pow(25, Double(index - 1))
    }

    static func shaftUnlockDiamondCost(_ index: Int) -> Int {
        20 + 10 * index * index
    }

    static func maxLevel(_ kind: UnitKind) -> Int {
        switch kind {
        case .shaft: return 800
        case .elevator, .warehouse: return 1_000
        }
    }

    /// Co 25 poziomów wydajność się podwaja.
    static func milestoneMultiplier(_ level: Int) -> Double {
        pow(2, Double(level / 25))
    }

    /// Wydajność jednostki na sekundę przy danym poziomie.
    static func rate(_ kind: UnitKind, level: Int) -> Double {
        let l = Double(level)
        switch kind {
        case .shaft(let index):
            return 2 * pow(10, Double(index)) * l * milestoneMultiplier(level)
        case .elevator:
            return 5 * l * pow(1.08, l - 1)
        case .warehouse:
            return 5.5 * l * pow(1.08, l - 1)
        }
    }

    /// Koszt przejścia z poziomu `level` na `level + 1`.
    static func upgradeCost(_ kind: UnitKind, fromLevel level: Int) -> Double {
        let l = Double(level - 1)
        switch kind {
        case .shaft(let index):
            return 10 * pow(10, Double(index)) * pow(1.14, l)
        case .elevator:
            return 20 * pow(1.17, l)
        case .warehouse:
            return 25 * pow(1.17, l)
        }
    }

    static func managerCost(_ kind: UnitKind) -> Double {
        switch kind {
        case .shaft(let index): return index == 0 ? 50 : shaftUnlockCost(index) * 0.6
        case .elevator: return 150
        case .warehouse: return 100
        }
    }
}

// MARK: - Formatowanie liczb (1.25K, 3.4M, 7.1aa…)

enum NumberFormat {
    private static let units: [String] = {
        var result = ["", "K", "M", "B", "T"]
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        for first in letters.prefix(6) {
            for second in letters {
                result.append("\(first)\(second)")
            }
        }
        return result
    }()

    static func short(_ value: Double) -> String {
        guard value.isFinite else { return "∞" }
        var x = max(0, value)
        if x < 1000 { return String(Int(x.rounded(.down))) }
        var index = 0
        while x >= 1000 && index < units.count - 1 {
            x /= 1000
            index += 1
        }
        let format = x >= 100 ? "%.0f" : (x >= 10 ? "%.1f" : "%.2f")
        // Zaokrąglamy w dół, żeby nie pokazywać kwoty, której gracz jeszcze nie ma.
        let factor: Double = x >= 100 ? 1 : (x >= 10 ? 10 : 100)
        let floored = (x * factor).rounded(.down) / factor
        return String(format: format, floored) + units[index]
    }

    static func duration(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }
}
