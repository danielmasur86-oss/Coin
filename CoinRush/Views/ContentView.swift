import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var data: GameData
    @EnvironmentObject private var store: StoreManager
    @State private var isPlaying = false

    var body: some View {
        MenuView(onPlay: { isPlaying = true })
            .fullScreenCover(isPresented: $isPlaying) {
                GameView(onExit: { isPlaying = false })
                    .environmentObject(data)
                    .environmentObject(store)
            }
    }
}
