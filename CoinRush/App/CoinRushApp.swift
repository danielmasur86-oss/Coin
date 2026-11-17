import SwiftUI

@main
struct CoinRushApp: App {
    @StateObject private var data = GameData.shared
    @StateObject private var store = StoreManager(gameData: GameData.shared)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(data)
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
