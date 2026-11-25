import SwiftUI

@main
struct MineEmpireApp: App {
    @StateObject private var engine: MineEngine
    @StateObject private var store: MineStore
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let engine = MineEngine()
        _engine = StateObject(wrappedValue: engine)
        _store = StateObject(wrappedValue: MineStore(engine: engine))
    }

    var body: some Scene {
        WindowGroup {
            MineView()
                .environmentObject(engine)
                .environmentObject(store)
                .preferredColorScheme(.light)
                .onAppear { engine.start() }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active: engine.start()
            case .background: engine.stop()
            default: break
            }
        }
    }
}
