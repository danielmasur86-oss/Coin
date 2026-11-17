import SpriteKit

/// Łączy scenę SpriteKit z SwiftUI i nalicza nagrody.
final class GameSession: ObservableObject, GameSceneDelegate {
    static let reviveCost = 100

    @Published private(set) var score = 0
    @Published private(set) var lives = GameScene.startingLives
    @Published private(set) var coinsEarned = 0
    @Published private(set) var isGameOver = false
    @Published private(set) var lastRoundCoins = 0
    @Published private(set) var hasRevived = false
    @Published private(set) var isNewRecord = false

    let scene: GameScene
    private weak var data: GameData?

    init() {
        scene = GameScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .resizeFill
        scene.gameDelegate = self
    }

    func configure(with data: GameData) {
        self.data = data
        scene.coinMultiplier = data.coinMultiplier
        scene.basketColor = data.selectedSkin.color
    }

    func start() {
        hasRevived = false
        isGameOver = false
        isNewRecord = false
        scene.reset()
    }

    /// Kontynuacja za monety – jedno użycie na rundę.
    func revive() -> Bool {
        guard !hasRevived, let data, data.spendCoins(Self.reviveCost) else { return false }
        hasRevived = true
        isGameOver = false
        scene.revive()
        return true
    }

    /// Wyjście w trakcie gry – zebrane monety nie przepadają.
    func quit() {
        guard !isGameOver else { return }
        let score = scene.score
        let coins = scene.coinsEarned
        scene.stop()
        award(score: score, coins: coins)
    }

    private func award(score: Int, coins: Int) {
        guard let data else { return }
        isNewRecord = score > data.bestScore && score > 0
        data.addCoins(coins)
        data.submitScore(score)
    }

    // MARK: - GameSceneDelegate

    func gameSceneDidUpdate(score: Int, lives: Int, coinsEarned: Int) {
        if self.score != score { self.score = score }
        if self.lives != lives { self.lives = lives }
        if self.coinsEarned != coinsEarned { self.coinsEarned = coinsEarned }
    }

    func gameSceneDidEnd(score: Int, coinsEarned: Int) {
        lastRoundCoins = coinsEarned
        award(score: score, coins: coinsEarned)
        isGameOver = true
    }
}
