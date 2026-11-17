import UIKit

/// Skórki koszyka kupowane za monety zdobyte w grze (lub kupione w sklepie).
struct BasketSkin: Identifiable, Equatable {
    let id: String
    let name: String
    let color: UIColor
    let price: Int

    static let classic = BasketSkin(id: "classic", name: "Klasyczny", color: .systemOrange, price: 0)

    static let all: [BasketSkin] = [
        classic,
        BasketSkin(id: "ocean", name: "Ocean", color: .systemTeal, price: 250),
        BasketSkin(id: "forest", name: "Las", color: .systemGreen, price: 500),
        BasketSkin(id: "royal", name: "Królewski", color: .systemPurple, price: 1_000),
        BasketSkin(id: "ruby", name: "Rubin", color: .systemRed, price: 2_000),
        BasketSkin(id: "gold", name: "Złoty", color: UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1), price: 5_000)
    ]

    static func skin(withID id: String) -> BasketSkin {
        all.first { $0.id == id } ?? classic
    }
}
