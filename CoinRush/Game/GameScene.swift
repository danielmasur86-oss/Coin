import SpriteKit
import UIKit

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidUpdate(score: Int, lives: Int, coinsEarned: Int)
    func gameSceneDidEnd(score: Int, coinsEarned: Int)
}

/// Rozgrywka: przesuwaj koszyk palcem, łap monety i diamenty, unikaj bomb.
final class GameScene: SKScene {

    enum ItemKind {
        case coin, diamond, bomb, heart

        var emoji: String {
            switch self {
            case .coin: return "🪙"
            case .diamond: return "💎"
            case .bomb: return "💣"
            case .heart: return "❤️"
            }
        }
    }

    private final class FallingItem {
        let kind: ItemKind
        let node: SKLabelNode
        let speed: CGFloat

        init(kind: ItemKind, node: SKLabelNode, speed: CGFloat) {
            self.kind = kind
            self.node = node
            self.speed = speed
        }
    }

    static let startingLives = 3
    static let maxLives = 5

    weak var gameDelegate: GameSceneDelegate?
    var coinMultiplier = 1
    var basketColor: UIColor = .systemOrange {
        didSet { basket?.fillColor = basketColor }
    }

    private(set) var score = 0
    private(set) var coinsEarned = 0
    private(set) var lives = GameScene.startingLives
    private(set) var isPlaying = false

    private var basket: SKShapeNode?
    private var items: [FallingItem] = []
    private var lastUpdate: TimeInterval = 0
    private var spawnCooldown: TimeInterval = 0.5
    private var elapsed: TimeInterval = 0

    private let basketSize = CGSize(width: 96, height: 30)
    private var basketY: CGFloat { max(90, size.height * 0.12) }

    // MARK: - Cykl życia

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.20, alpha: 1)
        if basket == nil { createBasket() }
        addStarfield()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard let basket else { return }
        basket.position = CGPoint(x: clampX(basket.position.x), y: basketY)
    }

    // MARK: - Sterowanie grą

    func reset() {
        clearItems()
        score = 0
        coinsEarned = 0
        lives = Self.startingLives
        elapsed = 0
        spawnCooldown = 0.6
        lastUpdate = 0
        basket?.position = CGPoint(x: size.width / 2, y: basketY)
        isPlaying = true
        notify()
    }

    /// Kontynuacja po przegranej (za monety). Wynik zostaje, monety liczone od nowa.
    func revive() {
        clearItems()
        lives = 1
        coinsEarned = 0
        spawnCooldown = 1.0
        lastUpdate = 0
        isPlaying = true
        notify()
    }

    func stop() {
        isPlaying = false
        clearItems()
    }

    // MARK: - Pętla gry

    override func update(_ currentTime: TimeInterval) {
        defer { lastUpdate = currentTime }
        guard isPlaying, lastUpdate > 0, let basket else { return }

        let dt = min(currentTime - lastUpdate, 1.0 / 20.0)
        elapsed += dt
        let difficulty = 1 + elapsed / 25

        spawnCooldown -= dt
        if spawnCooldown <= 0 {
            spawnItem(difficulty: difficulty)
            spawnCooldown = max(0.28, 0.85 / difficulty) * Double.random(in: 0.7...1.3)
        }

        var remaining: [FallingItem] = []
        remaining.reserveCapacity(items.count)

        for item in items {
            item.node.position.y -= item.speed * CGFloat(dt)
            let dx = abs(item.node.position.x - basket.position.x)
            let dy = item.node.position.y - basket.position.y

            if dx < basketSize.width / 2 + 14, dy < basketSize.height / 2 + 18, dy > -basketSize.height / 2 {
                collect(item)
            } else if item.node.position.y < -50 {
                item.node.removeFromParent()
            } else {
                remaining.append(item)
            }
        }
        items = remaining

        if lives <= 0 {
            endGame()
        }
    }

    // MARK: - Dotyk

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveBasket(with: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveBasket(with: touches)
    }

    private func moveBasket(with touches: Set<UITouch>) {
        guard isPlaying, let touch = touches.first, let basket else { return }
        basket.position.x = clampX(touch.location(in: self).x)
    }

    private func clampX(_ x: CGFloat) -> CGFloat {
        let half = basketSize.width / 2
        guard size.width > basketSize.width else { return size.width / 2 }
        return min(max(x, half), size.width - half)
    }

    // MARK: - Obiekty

    private func createBasket() {
        let node = SKShapeNode(rectOf: basketSize, cornerRadius: 12)
        node.fillColor = basketColor
        node.strokeColor = .white
        node.lineWidth = 3
        node.position = CGPoint(x: size.width / 2, y: basketY)
        node.zPosition = 10
        addChild(node)
        basket = node
    }

    private func addStarfield() {
        guard childNode(withName: "stars") == nil, size.width > 0, size.height > 0 else { return }
        let stars = SKNode()
        stars.name = "stars"
        stars.zPosition = -10
        for _ in 0..<60 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.6...1.8))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.2...0.8)
            star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                    y: CGFloat.random(in: 0...size.height))
            stars.addChild(star)
        }
        addChild(stars)
    }

    private func spawnItem(difficulty: Double) {
        guard size.width > 60 else { return }

        let roll = Double.random(in: 0..<1)
        let bombChance = min(0.12 + elapsed / 300, 0.35)
        let kind: ItemKind
        if roll < bombChance {
            kind = .bomb
        } else if roll < bombChance + 0.06 {
            kind = .diamond
        } else if roll < bombChance + 0.08, lives < Self.maxLives {
            kind = .heart
        } else {
            kind = .coin
        }

        let node = SKLabelNode(text: kind.emoji)
        node.fontSize = kind == .diamond ? 36 : 40
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.position = CGPoint(x: CGFloat.random(in: 30...(size.width - 30)), y: size.height + 30)
        node.zPosition = 5

        if kind == .coin {
            let flip = SKAction.sequence([
                .scaleX(to: 0.3, duration: 0.25),
                .scaleX(to: 1.0, duration: 0.25)
            ])
            node.run(.repeatForever(flip))
        }

        addChild(node)
        let speed = min(CGFloat.random(in: 180...260) * CGFloat(difficulty), 720)
        items.append(FallingItem(kind: kind, node: node, speed: speed))
    }

    private func collect(_ item: FallingItem) {
        let position = item.node.position
        item.node.removeFromParent()

        switch item.kind {
        case .coin:
            score += 1
            coinsEarned += 1 * coinMultiplier
            showFloatingText("+\(coinMultiplier)", at: position, color: .systemYellow)
        case .diamond:
            score += 5
            coinsEarned += 5 * coinMultiplier
            showFloatingText("+\(5 * coinMultiplier)", at: position, color: .cyan)
        case .heart:
            lives = min(lives + 1, Self.maxLives)
            showFloatingText("+1 ❤️", at: position, color: .systemPink)
        case .bomb:
            lives -= 1
            flashScreen()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        notify()
    }

    private func clearItems() {
        items.forEach { $0.node.removeFromParent() }
        items.removeAll()
    }

    private func endGame() {
        guard isPlaying else { return }
        isPlaying = false
        clearItems()
        gameDelegate?.gameSceneDidEnd(score: score, coinsEarned: coinsEarned)
    }

    private func notify() {
        gameDelegate?.gameSceneDidUpdate(score: score, lives: lives, coinsEarned: coinsEarned)
    }

    // MARK: - Efekty

    private func showFloatingText(_ text: String, at position: CGPoint, color: UIColor) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = 24
        label.fontColor = color
        label.position = position
        label.zPosition = 20
        addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: 60, duration: 0.6), .fadeOut(withDuration: 0.6)]),
            .removeFromParent()
        ]))
    }

    private func flashScreen() {
        let flash = SKSpriteNode(color: .systemRed, size: size)
        flash.anchorPoint = .zero
        flash.alpha = 0.4
        flash.zPosition = 50
        addChild(flash)
        flash.run(.sequence([.fadeOut(withDuration: 0.3), .removeFromParent()]))

        basket?.run(.sequence([
            .moveBy(x: -8, y: 0, duration: 0.05),
            .moveBy(x: 16, y: 0, duration: 0.05),
            .moveBy(x: -8, y: 0, duration: 0.05)
        ]))
    }
}
