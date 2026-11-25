import Foundation

/// Serce gry: symulacja kopalni 10 razy na sekundę, zakupy za gotówkę i diamenty, zapis stanu.
@MainActor
final class MineEngine: ObservableObject {
    static let tickInterval: TimeInterval = 0.1
    private static let storageKey = "mineEmpire.state.v1"

    @Published private(set) var state: MineState
    @Published var offlineReport: OfflineReport?
    /// Licznik klatek – używany do prostych animacji.
    @Published private(set) var frame: Int = 0

    private let defaults: UserDefaults
    private var timer: Timer?
    private var lastTick = Date()
    private var lastPersist = Date()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode(MineState.self, from: data) {
            state = saved
        } else {
            state = MineState()
        }
    }

    // MARK: - Cykl życia

    func start() {
        guard timer == nil else { return }
        collectOfflineEarnings()
        lastTick = Date()
        let timer = Timer(timeInterval: Self.tickInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.step() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        save()
    }

    func save() {
        let now = Date()
        state.lastSaved = now
        lastPersist = now
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }

    private func step() {
        let now = Date()
        let dt = min(max(now.timeIntervalSince(lastTick), 0), 1)
        lastTick = now
        simulate(dt: dt, now: now)
        frame &+= 1
        if now.timeIntervalSince(lastPersist) > 5 { save() }
    }

    private func simulate(dt: TimeInterval, now: Date) {
        var s = state

        // 1. Górnicy wydobywają urobek w szybach.
        for i in s.shafts.indices where Self.isWorking(s.shafts[i].unit, now: now) {
            s.shafts[i].deposit += Economy.rate(.shaft(i), level: s.shafts[i].unit.level) * dt
        }

        // 2. Winda zabiera urobek z szybów (od góry) na powierzchnię.
        if Self.isWorking(s.elevator, now: now) {
            var capacity = Economy.rate(.elevator, level: s.elevator.level) * dt
            for i in s.shafts.indices {
                guard capacity > 0 else { break }
                let taken = min(capacity, s.shafts[i].deposit)
                s.shafts[i].deposit -= taken
                s.surfaceStock += taken
                capacity -= taken
            }
        }

        // 3. Magazyn sprzedaje urobek za gotówkę.
        if Self.isWorking(s.warehouse, now: now) {
            let sold = min(s.surfaceStock, Economy.rate(.warehouse, level: s.warehouse.level) * dt)
            s.surfaceStock -= sold
            let earned = sold * Self.incomeMultiplier(s, now: now, includeBoost: true)
            s.cash += earned
            s.totalEarned += earned
        }

        state = s
    }

    // MARK: - Odczyty dla widoków

    func unit(_ kind: UnitKind) -> UnitState {
        switch kind {
        case .shaft(let index): return state.shafts[index].unit
        case .elevator: return state.elevator
        case .warehouse: return state.warehouse
        }
    }

    func level(_ kind: UnitKind) -> Int { unit(kind).level }
    func isManaged(_ kind: UnitKind) -> Bool { unit(kind).hasManager }
    func isWorking(_ kind: UnitKind) -> Bool { Self.isWorking(unit(kind), now: Date()) }
    func currentRate(_ kind: UnitKind) -> Double { Economy.rate(kind, level: level(kind)) }
    func isMaxLevel(_ kind: UnitKind) -> Bool { level(kind) >= Economy.maxLevel(kind) }

    /// Ile zostało z ręcznego cyklu (1 → 0), nil jeśli jednostka stoi lub ma kierownika.
    func cycleRemaining(_ kind: UnitKind) -> Double? {
        let u = unit(kind)
        guard !u.hasManager, let until = u.activeUntil else { return nil }
        let left = until.timeIntervalSinceNow
        guard left > 0 else { return nil }
        return left / Economy.manualCycle
    }

    var incomeMultiplier: Double { Self.incomeMultiplier(state, now: Date(), includeBoost: true) }

    var boostRemaining: TimeInterval {
        guard let until = state.boostUntil else { return 0 }
        return max(0, until.timeIntervalSinceNow)
    }

    var freeBoostAvailableIn: TimeInterval {
        guard let last = state.lastFreeBoost else { return 0 }
        return max(0, Economy.freeBoostCooldown - Date().timeIntervalSince(last))
    }

    /// Maksymalny dochód/s, gdyby wszystko pracowało (najwolniejsze ogniwo).
    var potentialIncomePerSecond: Double {
        throughput(onlyManaged: false) * incomeMultiplier
    }

    /// Dochód/s bez udziału gracza – tylko jednostki z kierownikami.
    var idleIncomePerSecond: Double {
        throughput(onlyManaged: true) * incomeMultiplier
    }

    private func throughput(onlyManaged: Bool) -> Double {
        func counts(_ u: UnitState) -> Bool { !onlyManaged || u.hasManager }
        var mined = 0.0
        for i in state.shafts.indices where counts(state.shafts[i].unit) {
            mined += Economy.rate(.shaft(i), level: state.shafts[i].unit.level)
        }
        let lift = counts(state.elevator) ? Economy.rate(.elevator, level: state.elevator.level) : 0
        let sell = counts(state.warehouse) ? Economy.rate(.warehouse, level: state.warehouse.level) : 0
        return min(mined, lift, sell)
    }

    // MARK: - Akcje gracza

    /// Dotknięcie pracownika – uruchamia cykl pracy, jeśli nie ma kierownika.
    func tap(_ kind: UnitKind) {
        let now = Date()
        mutateUnit(kind) { u in
            guard !u.hasManager else { return }
            if let until = u.activeUntil, until > now { return }
            u.activeUntil = now.addingTimeInterval(Economy.manualCycle)
        }
    }

    func upgradeCost(_ kind: UnitKind, count: Int) -> Double {
        let start = level(kind)
        let end = min(start + count, Economy.maxLevel(kind))
        guard end > start else { return 0 }
        var total = 0.0
        for l in start..<end { total += Economy.upgradeCost(kind, fromLevel: l) }
        return total
    }

    /// Ile poziomów stać gracza kupić (co najmniej 1, żeby pokazać koszt następnego).
    func maxAffordableLevels(_ kind: UnitKind) -> Int {
        var l = level(kind)
        var budget = state.cash
        var count = 0
        while l < Economy.maxLevel(kind) {
            let cost = Economy.upgradeCost(kind, fromLevel: l)
            guard cost <= budget else { break }
            budget -= cost
            l += 1
            count += 1
        }
        return max(count, 1)
    }

    func canAffordUpgrade(_ kind: UnitKind) -> Bool {
        !isMaxLevel(kind) && state.cash >= Economy.upgradeCost(kind, fromLevel: level(kind))
    }

    @discardableResult
    func upgrade(_ kind: UnitKind, count: Int) -> Bool {
        let levels = min(count, Economy.maxLevel(kind) - level(kind))
        guard levels > 0 else { return false }
        let cost = upgradeCost(kind, count: levels)
        guard state.cash >= cost else { return false }
        state.cash -= cost
        mutateUnit(kind) { $0.level += levels }
        return true
    }

    @discardableResult
    func hireManager(_ kind: UnitKind) -> Bool {
        let cost = Economy.managerCost(kind)
        guard !isManaged(kind), state.cash >= cost else { return false }
        state.cash -= cost
        mutateUnit(kind) { $0.hasManager = true; $0.activeUntil = nil }
        return true
    }

    var canUnlockShaft: Bool { state.shafts.count < Economy.maxShafts }
    var nextShaftCashCost: Double { Economy.shaftUnlockCost(state.shafts.count) }
    var nextShaftDiamondCost: Int { Economy.shaftUnlockDiamondCost(state.shafts.count) }

    @discardableResult
    func unlockShaftWithCash() -> Bool {
        let cost = nextShaftCashCost
        guard canUnlockShaft, state.cash >= cost else { return false }
        state.cash -= cost
        state.shafts.append(ShaftState())
        save()
        return true
    }

    @discardableResult
    func unlockShaftWithDiamonds() -> Bool {
        let cost = nextShaftDiamondCost
        guard canUnlockShaft, state.diamonds >= cost else { return false }
        state.diamonds -= cost
        state.shafts.append(ShaftState())
        save()
        return true
    }

    // MARK: - Diamenty (waluta premium)

    @discardableResult
    func buyBoost() -> Bool {
        guard state.diamonds >= Economy.boostDiamondCost else { return false }
        state.diamonds -= Economy.boostDiamondCost
        extendBoost(by: Economy.boostDuration)
        save()
        return true
    }

    @discardableResult
    func claimFreeBoost() -> Bool {
        guard freeBoostAvailableIn == 0 else { return false }
        state.lastFreeBoost = Date()
        extendBoost(by: Economy.freeBoostDuration)
        save()
        return true
    }

    var instantCashAmount: Double {
        let perSecond = throughput(onlyManaged: false) * Self.incomeMultiplier(state, now: Date(), includeBoost: false)
        return max(1_000, perSecond * Economy.instantCashHours * 3600)
    }

    @discardableResult
    func buyInstantCash() -> Bool {
        guard state.diamonds >= Economy.instantCashDiamondCost else { return false }
        let amount = instantCashAmount
        state.diamonds -= Economy.instantCashDiamondCost
        state.cash += amount
        state.totalEarned += amount
        save()
        return true
    }

    private func extendBoost(by duration: TimeInterval) {
        let base = max(Date(), state.boostUntil ?? Date())
        state.boostUntil = base.addingTimeInterval(duration)
    }

    // MARK: - Dochód offline

    var offlineCapHours: Double {
        state.hasOfflineVault ? Economy.offlineCapHoursWithVault : Economy.offlineCapHours
    }

    func collectOfflineEarnings(now: Date = Date()) {
        let elapsed = now.timeIntervalSince(state.lastSaved)
        defer {
            state.lastSaved = now
            lastTick = now
        }
        guard elapsed > 60 else { return }
        let seconds = min(elapsed, offlineCapHours * 3600)
        let perSecond = throughput(onlyManaged: true) * Self.incomeMultiplier(state, now: now, includeBoost: false)
        let amount = perSecond * seconds
        guard amount >= 1 else { return }
        offlineReport = OfflineReport(seconds: seconds, amount: amount)
    }

    func claimOffline(_ report: OfflineReport, doubled: Bool) {
        var amount = report.amount
        if doubled {
            guard state.diamonds >= Economy.doubleOfflineDiamondCost else { return }
            state.diamonds -= Economy.doubleOfflineDiamondCost
            amount *= 2
        }
        state.cash += amount
        state.totalEarned += amount
        offlineReport = nil
        save()
    }

    // MARK: - Mikropłatności (wywoływane przez MineStore)

    /// Nalicza diamenty tylko raz na transakcję.
    @discardableResult
    func creditDiamonds(_ amount: Int, transactionID: UInt64) -> Bool {
        let id = String(transactionID)
        guard amount > 0, !state.processedTransactions.contains(id) else { return false }
        state.processedTransactions.append(id)
        state.diamonds += amount
        save()
        return true
    }

    func setEntitlements(doubleIncome: Bool, offlineVault: Bool) {
        guard state.hasDoubleIncome != doubleIncome || state.hasOfflineVault != offlineVault else { return }
        state.hasDoubleIncome = doubleIncome
        state.hasOfflineVault = offlineVault
        save()
    }

    // MARK: - Pomocnicze

    private func mutateUnit(_ kind: UnitKind, _ body: (inout UnitState) -> Void) {
        switch kind {
        case .shaft(let index): body(&state.shafts[index].unit)
        case .elevator: body(&state.elevator)
        case .warehouse: body(&state.warehouse)
        }
    }

    private static func isWorking(_ unit: UnitState, now: Date) -> Bool {
        if unit.hasManager { return true }
        guard let until = unit.activeUntil else { return false }
        return until > now
    }

    private static func incomeMultiplier(_ s: MineState, now: Date, includeBoost: Bool) -> Double {
        var multiplier = 1.0
        if s.hasDoubleIncome { multiplier *= 2 }
        if includeBoost, let until = s.boostUntil, until > now { multiplier *= 2 }
        return multiplier
    }
}
