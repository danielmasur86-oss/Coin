import SwiftUI

// MARK: - Postacie rysowane kodem (bez plików graficznych)

enum CharacterRole {
    case miner, lift, hauler, seller, boss

    var shirt: Color {
        switch self {
        case .miner: return Color(red: 0.95, green: 0.60, blue: 0.12)
        case .lift: return Color(red: 0.88, green: 0.27, blue: 0.23)
        case .hauler: return Color(red: 0.18, green: 0.60, blue: 0.84)
        case .seller: return Color(red: 0.48, green: 0.31, blue: 0.84)
        case .boss: return Color(red: 0.17, green: 0.24, blue: 0.40)
        }
    }

    var pants: Color {
        switch self {
        case .miner: return Color(red: 0.24, green: 0.35, blue: 0.62)
        case .boss: return Color(red: 0.13, green: 0.17, blue: 0.27)
        default: return Color(red: 0.17, green: 0.23, blue: 0.33)
        }
    }

    var cap: Color {
        switch self {
        case .lift: return Color(red: 0.78, green: 0.18, blue: 0.18)
        case .hauler: return Color(red: 0.24, green: 0.64, blue: 0.29)
        default: return Color.gold
        }
    }
}

private extension Color {
    static let skin = Color(red: 0.96, green: 0.78, blue: 0.61)
    static let shoe = Color(red: 0.23, green: 0.16, blue: 0.13)
    static let ore = Color(red: 0.42, green: 0.32, blue: 0.27)
}

/// Postać w układzie współrzędnych 40×56 (stopy na dole), skalowana do ramki.
struct CharacterFigure: View {
    let role: CharacterRole
    var legSwing: Double = 0
    var armAngle: Double = 0
    var showSack = false
    var bob: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let s = min(size.width / 40, size.height / 56)
            var ctx = context
            ctx.translateBy(x: (size.width - 40 * s) / 2, y: size.height - 56 * s + bob * s)
            ctx.scaleBy(x: s, y: s)
            draw(in: ctx)
        }
    }

    private func draw(in ctx: GraphicsContext) {
        func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> Path {
            Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: r)
        }
        func oval(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
            Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        }

        if role == .miner && showSack {
            ctx.fill(oval(9, 30, 6, 7), with: .color(Color(red: 0.65, green: 0.47, blue: 0.29)))
        }

        // Nogi
        for (x, sign) in [(CGFloat(13), 1.0), (CGFloat(21), -1.0)] {
            let leg = ctx.rotated(by: legSwing * sign, around: CGPoint(x: x + 3, y: 39))
            leg.fill(rect(x, 38, 6, 14, 2), with: .color(role.pants))
            leg.fill(oval(x + 3, 53, 4.6, 2.6), with: .color(.shoe))
        }

        // Tylna ręka, tułów
        ctx.fill(rect(8, 26, 5, 11, 2.5), with: .color(role.shirt))
        ctx.fill(oval(10.5, 37.5, 2.5, 2.5), with: .color(.skin))
        ctx.fill(rect(10, 23, 20, 18, 6), with: .color(role.shirt))
        switch role {
        case .miner:
            ctx.fill(rect(10, 32, 20, 2.6, 0), with: .color(.white.opacity(0.85)))
        case .boss:
            var collar = Path()
            collar.move(to: CGPoint(x: 17, y: 24)); collar.addLine(to: CGPoint(x: 20, y: 31)); collar.addLine(to: CGPoint(x: 23, y: 24))
            ctx.fill(collar, with: .color(.white))
            var tie = Path()
            tie.move(to: CGPoint(x: 19.2, y: 26)); tie.addLine(to: CGPoint(x: 20, y: 34)); tie.addLine(to: CGPoint(x: 20.8, y: 26))
            ctx.fill(tie, with: .color(.red))
        default:
            ctx.fill(rect(15, 28, 10, 8, 2), with: .color(.black.opacity(0.15)))
        }

        // Głowa
        ctx.fill(oval(20, 15, 10, 10), with: .color(.skin))
        ctx.fill(oval(16.8, 15.5, 1.5, 1.5), with: .color(.black))
        ctx.fill(oval(23.2, 15.5, 1.5, 1.5), with: .color(.black))
        ctx.fill(oval(15, 19, 1.6, 1.6), with: .color(.pink.opacity(0.5)))
        ctx.fill(oval(25, 19, 1.6, 1.6), with: .color(.pink.opacity(0.5)))
        var smile = Path()
        smile.move(to: CGPoint(x: 17, y: 19.5))
        smile.addQuadCurve(to: CGPoint(x: 23, y: 19.5), control: CGPoint(x: 20, y: 22.5))
        ctx.stroke(smile, with: .color(.brown), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))

        // Nakrycie głowy
        switch role {
        case .miner:
            var helmet = Path()
            helmet.move(to: CGPoint(x: 9, y: 14))
            helmet.addQuadCurve(to: CGPoint(x: 31, y: 14), control: CGPoint(x: 20, y: 0))
            helmet.closeSubpath()
            ctx.fill(helmet, with: .color(Color(red: 1, green: 0.78, blue: 0.1)))
            ctx.fill(rect(7.5, 12.5, 25, 3.2, 1.6), with: .color(Color(red: 0.91, green: 0.66, blue: 0)))
            ctx.fill(oval(20, 8, 2.7, 2.7), with: .color(Color(red: 1, green: 0.97, blue: 0.69)))
        case .boss:
            var hair = Path()
            hair.move(to: CGPoint(x: 10, y: 13))
            hair.addQuadCurve(to: CGPoint(x: 30, y: 13), control: CGPoint(x: 20, y: 0))
            hair.addQuadCurve(to: CGPoint(x: 10, y: 13), control: CGPoint(x: 20, y: 7))
            ctx.fill(hair, with: .color(Color(red: 0.23, green: 0.16, blue: 0.13)))
        default:
            var cap = Path()
            cap.move(to: CGPoint(x: 10, y: 13))
            cap.addQuadCurve(to: CGPoint(x: 30, y: 13), control: CGPoint(x: 20, y: 2))
            cap.closeSubpath()
            ctx.fill(cap, with: .color(role.cap))
            ctx.fill(rect(18, 11, 15, 3, 1.5), with: .color(role.cap))
        }

        // Przednia ręka z narzędziem
        let arm = ctx.rotated(by: armAngle, around: CGPoint(x: 28, y: 27))
        arm.fill(rect(26, 26, 5, 11, 2.5), with: .color(role.shirt))
        if role == .miner {
            var handle = Path()
            handle.move(to: CGPoint(x: 28.5, y: 40)); handle.addLine(to: CGPoint(x: 35, y: 22))
            arm.stroke(handle, with: .color(.brown), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
            var pick = Path()
            pick.move(to: CGPoint(x: 29, y: 20))
            pick.addQuadCurve(to: CGPoint(x: 42, y: 24), control: CGPoint(x: 36, y: 16))
            arm.stroke(pick, with: .color(Color(white: 0.68)), style: StrokeStyle(lineWidth: 3.2, lineCap: .round))
        } else if role == .boss {
            arm.fill(rect(27, 33, 9, 11, 1.5), with: .color(Color(white: 0.95)))
        }
        arm.fill(oval(28.5, 38, 2.6, 2.6), with: .color(.skin))
    }
}

private extension GraphicsContext {
    func rotated(by degrees: Double, around point: CGPoint) -> GraphicsContext {
        var copy = self
        copy.translateBy(x: point.x, y: point.y)
        copy.rotate(by: .degrees(degrees))
        copy.translateBy(x: -point.x, y: -point.y)
        return copy
    }
}

// MARK: - Rekwizyty

struct MineCart: View {
    var loaded: Bool

    var body: some View {
        Canvas { context, size in
            let s = min(size.width / 38, size.height / 56)
            var ctx = context
            ctx.translateBy(x: 0, y: size.height - 56 * s)
            ctx.scaleBy(x: s, y: s)
            if loaded {
                for (x, y, r) in [(11.0, 31.0, 5.0), (19.0, 29.0, 6.0), (27.0, 31.0, 5.0)] {
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(.ore))
                }
                ctx.fill(Path(ellipseIn: CGRect(x: 17, y: 23, width: 4, height: 4)), with: .color(.gold))
            }
            var body = Path()
            body.move(to: CGPoint(x: 2, y: 32)); body.addLine(to: CGPoint(x: 36, y: 32))
            body.addLine(to: CGPoint(x: 32, y: 48)); body.addLine(to: CGPoint(x: 6, y: 48)); body.closeSubpath()
            ctx.fill(body, with: .color(Color(white: 0.5)))
            for x in [11.0, 27.0] {
                ctx.fill(Path(ellipseIn: CGRect(x: x - 4.5, y: 45.5, width: 9, height: 9)), with: .color(Color(white: 0.2)))
            }
        }
    }
}

struct OreCrate: View {
    var body: some View {
        Canvas { context, size in
            let s = size.width / 44
            var ctx = context
            ctx.scaleBy(x: s, y: s)
            let wood = Color(red: 0.66, green: 0.44, blue: 0.24)
            let dark = Color(red: 0.43, green: 0.27, blue: 0.13)
            for (x, y, r) in [(12.0, 6.0, 5.0), (22.0, 4.0, 6.0), (32.0, 6.0, 5.0)] {
                ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(.ore))
            }
            ctx.fill(Path(ellipseIn: CGRect(x: 22, y: 0, width: 3.6, height: 3.6)), with: .color(.gold))
            let box = Path(roundedRect: CGRect(x: 1, y: 6, width: 42, height: 25), cornerRadius: 2)
            ctx.fill(box, with: .color(wood))
            ctx.stroke(box, with: .color(dark), lineWidth: 2)
            var planks = Path()
            planks.move(to: CGPoint(x: 1, y: 18)); planks.addLine(to: CGPoint(x: 43, y: 18))
            planks.move(to: CGPoint(x: 14, y: 6)); planks.addLine(to: CGPoint(x: 14, y: 31))
            planks.move(to: CGPoint(x: 30, y: 6)); planks.addLine(to: CGPoint(x: 30, y: 31))
            ctx.stroke(planks, with: .color(dark), lineWidth: 1.6)
        }
    }
}

/// Ściana skały z kolorowymi bryłkami rudy (inny kolor w każdym szybie).
struct OreWall: View {
    let seed: Int

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            var rock = Path()
            rock.move(to: CGPoint(x: w * 0.18, y: 0))
            rock.addQuadCurve(to: CGPoint(x: w * 0.12, y: h * 0.5), control: CGPoint(x: 0, y: h * 0.25))
            rock.addQuadCurve(to: CGPoint(x: w * 0.15, y: h), control: CGPoint(x: 0, y: h * 0.75))
            rock.addLine(to: CGPoint(x: w, y: h)); rock.addLine(to: CGPoint(x: w, y: 0)); rock.closeSubpath()
            ctx.fill(rock, with: .color(Color(red: 0.75, green: 0.48, blue: 0.35)))
            let gems: [Color] = [.gold, .orange, .cyan, .purple, .green]
            var r = UInt64(seed * 977 + 13)
            func rnd() -> CGFloat { r = r &* 16807 % 2147483647; return CGFloat(r) / 2147483647 }
            for j in 0..<9 {
                let radius = 3 + rnd() * 4
                let rect = CGRect(x: w * (0.15 + rnd() * 0.75) - radius, y: h * (0.1 + rnd() * 0.8) - radius,
                                  width: radius * 2, height: radius * 2)
                ctx.fill(Path(ellipseIn: rect),
                         with: .color(j % 3 == 0 ? gems[seed % gems.count] : Color(red: 0.29, green: 0.2, blue: 0.17)))
            }
        }
    }
}

// MARK: - Ruch postaci

/// Górnik: idzie do ściany (30%), kopie 4 razy (40%), wraca z workiem (30%). Cykl 4 s.
struct MinerPose {
    var progress: CGFloat = 0
    var facingRight = true
    var leg: Double = 0
    var arm: Double = 0
    var sack = false
    var spark = false

    init(time: TimeInterval?) {
        guard let time else { return }
        let p = time.truncatingRemainder(dividingBy: 4) / 4
        if p < 0.3 {
            let f = p / 0.3
            progress = CGFloat(f)
            leg = 28 * sin(f * .pi * 6)
        } else if p < 0.7 {
            progress = 1
            let q = (p - 0.3) / 0.4 * 4
            let frac = q - floor(q)
            arm = frac < 0.75 ? -115 * (frac / 0.75) : -115 + 137 * ((frac - 0.75) / 0.25)
            spark = frac > 0.92
        } else {
            let f = (p - 0.7) / 0.3
            progress = CGFloat(1 - f)
            facingRight = false
            sack = true
            leg = 28 * sin(f * .pi * 6)
        }
    }
}

struct MinerWalker: View {
    let working: Bool
    let startX: CGFloat
    let endX: CGFloat
    let floorY: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !working)) { timeline in
            let pose = MinerPose(time: working ? timeline.date.timeIntervalSinceReferenceDate : nil)
            ZStack(alignment: .topLeading) {
                CharacterFigure(role: .miner, legSwing: pose.leg, armAngle: pose.arm, showSack: pose.sack)
                    .frame(width: 34, height: 48)
                    .scaleEffect(x: pose.facingRight ? 1 : -1, y: 1)
                    .offset(x: startX + (endX - startX) * pose.progress, y: floorY - 48)
                if pose.spark {
                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.yellow)
                        .offset(x: endX + 34, y: floorY - 30)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

/// Postać, która lekko się kołysze (kierownik, obsługa stanowisk).
struct IdleCharacter: View {
    let role: CharacterRole
    var busy = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let speed = busy ? 10.0 : 2.6
            CharacterFigure(role: role,
                            armAngle: busy ? -35 + 35 * sin(t * speed) : 0,
                            bob: CGFloat(sin(t * speed)) * (busy ? 1.4 : 0.8))
        }
        .allowsHitTesting(false)
    }
}

/// Przewoźnik pcha wózek od windy do magazynu i wraca. Cykl 5 s.
struct HaulerWalker: View {
    let working: Bool

    var body: some View {
        GeometryReader { geo in
            let start = geo.size.width * 0.31
            let end = max(start, geo.size.width * 0.69 - 64)
            TimelineView(.animation(minimumInterval: 1 / 30, paused: !working)) { timeline in
                let p = working
                    ? timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 5) / 5
                    : 0
                let outbound = p < 0.5
                let walk: Double = p < 0.08 ? 0 : (p < 0.45 ? (p - 0.08) / 0.37 : (p < 0.55 ? 1 : (p < 0.92 ? 1 - (p - 0.55) / 0.37 : 0)))
                let moving = (p > 0.08 && p < 0.45) || (p > 0.55 && p < 0.92)
                HStack(alignment: .bottom, spacing: -4) {
                    CharacterFigure(role: .hauler, legSwing: moving ? 28 * sin(p * .pi * 24) : 0)
                        .frame(width: 34, height: 48)
                    MineCart(loaded: outbound && p < 0.45)
                        .frame(width: 32, height: 48)
                }
                .scaleEffect(x: outbound ? 1 : -1, y: 1)
                .offset(x: start + (end - start) * CGFloat(walk), y: geo.size.height - 62)
            }
        }
        .allowsHitTesting(false)
    }
}

/// Kabina windy jeżdżąca po wszystkich szybach.
struct ElevatorTrack: View {
    let shaftCount: Int
    let working: Bool

    var body: some View {
        GeometryReader { geo in
            let travel = max(0, geo.size.height - 52)
            let period = max(3, 1.4 * Double(shaftCount) + 1.6)
            TimelineView(.animation(minimumInterval: 1 / 30, paused: !working)) { timeline in
                let p = working
                    ? timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period) / period
                    : 0
                let y: Double = p < 0.08 ? 0 : (p < 0.46 ? Self.ease((p - 0.08) / 0.38) : (p < 0.54 ? 1 : (p < 0.92 ? 1 - Self.ease((p - 0.54) / 0.38) : 0)))
                let carrying = p > 0.51 && p < 0.92
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(Color(white: 0.8))
                        .frame(width: 2, height: 2 + travel * CGFloat(y))
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(red: 0.94, green: 0.66, blue: 0.16))
                        CharacterFigure(role: .lift)
                            .frame(width: 30, height: 42)
                            .offset(y: 12)
                        if carrying {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.ore)
                                .frame(height: 7)
                                .padding(.horizontal, 3)
                                .padding(.bottom, 2)
                        }
                    }
                    .frame(width: 38, height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color(red: 0.69, green: 0.44, blue: 0.05), lineWidth: 2))
                    .offset(y: 2 + travel * CGFloat(y))
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
        }
        .allowsHitTesting(false)
    }

    private static func ease(_ x: Double) -> Double { x * x * (3 - 2 * x) }
}
