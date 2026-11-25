import SwiftUI
import UIKit

extension Color {
    static let panelBlue = Color(red: 0.13, green: 0.42, blue: 0.86)
    static let panelBlueDark = Color(red: 0.07, green: 0.25, blue: 0.60)
    static let skyTop = Color(red: 0.36, green: 0.65, blue: 0.95)
    static let skyBottom = Color(red: 0.70, green: 0.87, blue: 0.98)
    static let grass = Color(red: 0.42, green: 0.76, blue: 0.30)
    static let dirt = Color(red: 0.80, green: 0.58, blue: 0.40)
    static let dirtDark = Color(red: 0.55, green: 0.36, blue: 0.24)
    static let tunnel = Color(red: 0.20, green: 0.15, blue: 0.14)
    static let gold = Color(red: 1.0, green: 0.80, blue: 0.18)
    static let cashGreen = Color(red: 0.25, green: 0.78, blue: 0.35)
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}

/// Licznik w górnym pasku.
struct StatPill: View {
    let icon: String
    let title: String
    let value: String
    var showsPlus = false

    var body: some View {
        HStack(spacing: 6) {
            Text(icon).font(.title3)
            VStack(alignment: .leading, spacing: 0) {
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color.gold)
                Text(value)
                    .font(.system(size: 15, weight: .heavy).monospacedDigit())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer(minLength: 0)
            if showsPlus {
                Image(systemName: "plus")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Color.cashGreen, in: RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(Color.panelBlueDark, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }
}

/// Niebieski przycisk poziomu ze strzałką – świeci, gdy stać nas na ulepszenie.
struct LevelButton: View {
    @EnvironmentObject private var engine: MineEngine
    let kind: UnitKind
    let action: () -> Void

    var body: some View {
        let affordable = engine.canAffordUpgrade(kind)
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(affordable ? Color.gold : .white.opacity(0.5))
                Text("Poziom")
                    .font(.system(size: 10, weight: .bold))
                Text("\(engine.level(kind))")
                    .font(.system(size: 16, weight: .heavy).monospacedDigit())
            }
            .foregroundStyle(.white)
            .frame(width: 62, height: 58)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [.panelBlue, .panelBlueDark], startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(affordable ? Color.gold : .white.opacity(0.4), lineWidth: affordable ? 3 : 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(kind.title), poziom \(engine.level(kind)). Ulepsz")
    }
}

/// Pracownik do dotknięcia. Bez kierownika pracuje przez krótki cykl.
struct WorkerButton: View {
    @EnvironmentObject private var engine: MineEngine
    let kind: UnitKind

    var body: some View {
        let working = engine.isWorking(kind)
        let managed = engine.isManaged(kind)
        let remaining = engine.cycleRemaining(kind)
        let swing = working && (engine.frame / 3) % 2 == 0

        Button {
            Haptics.tap()
            engine.tap(kind)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.25))
                if let remaining {
                    Circle()
                        .trim(from: 0, to: remaining)
                        .stroke(Color.gold, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                Text(kind.emoji)
                    .font(.system(size: 30))
                    .rotationEffect(.degrees(swing ? -18 : 12))
                    .offset(y: swing ? -2 : 0)
                if !working {
                    Text("DOTKNIJ")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.gold, in: Capsule())
                        .offset(y: 28)
                } else if managed {
                    Text("AUTO")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.cashGreen, in: Capsule())
                        .offset(y: 28)
                }
            }
            .frame(width: 60, height: 60)
            .animation(.easeInOut(duration: 0.15), value: swing)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(working ? "\(kind.title) pracuje" : "Uruchom: \(kind.title)")
    }
}

/// Zatrudnienie kierownika = automatyczna praca (także offline).
struct ManagerButton: View {
    @EnvironmentObject private var engine: MineEngine
    let kind: UnitKind

    var body: some View {
        if engine.isManaged(kind) {
            Label("Kierownik", systemImage: "person.crop.circle.badge.checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.cashGreen.opacity(0.85), in: Capsule())
        } else {
            let cost = Economy.managerCost(kind)
            let affordable = engine.state.cash >= cost
            Button {
                if engine.hireManager(kind) { Haptics.success() } else { Haptics.error() }
            } label: {
                VStack(spacing: 0) {
                    Text("🧑‍💼 Zatrudnij")
                        .font(.system(size: 11, weight: .heavy))
                    Text("💰 \(NumberFormat.short(cost))")
                        .font(.system(size: 11, weight: .bold).monospacedDigit())
                }
                .foregroundStyle(affordable ? .black : .white.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(affordable ? Color.gold : Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(!affordable)
            .accessibilityLabel("Zatrudnij kierownika za \(NumberFormat.short(cost))")
        }
    }
}

struct BigButtonStyle: ButtonStyle {
    var color: Color = .gold
    var textColor: Color = .black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.heavy))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(color, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Prosty kształt gór w tle.
struct Mountains: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.width * 0.22, y: rect.height * 0.35))
        p.addLine(to: CGPoint(x: rect.width * 0.40, y: rect.height * 0.70))
        p.addLine(to: CGPoint(x: rect.width * 0.62, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0.55))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.40))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
