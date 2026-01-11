import Foundation

// MARK: - Deal Category

enum DealCategory: String, Codable {
    case supply
    case equipment
    case special

    var displayName: String {
        switch self {
        case .supply: return "Supply Deal"
        case .equipment: return "Equipment Deal"
        case .special: return "Special"
        }
    }
}

// MARK: - Deal Item

enum DealItem: Codable, Equatable {
    case input(item: InventoryItem, quantity: Int)
    case axe(type: AxeType, tier: AxeTier)
    case plant(type: PlantType)
    case repairDiscount(percent: Int)
    case bundle(name: String, items: [InventoryItem: Int])

    var displayName: String {
        switch self {
        case .input(let item, let quantity):
            return "\(item.displayName) x\(quantity)"
        case .axe(let type, let tier):
            return tier.tierName(for: type)
        case .plant(let type):
            return type.displayName
        case .repairDiscount(let percent):
            return "\(percent)% Off Repairs"
        case .bundle(let name, _):
            return name
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, item, quantity, axeType, axeTier, plantType, percent, bundleName, bundleItems
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "input":
            let item = try container.decode(InventoryItem.self, forKey: .item)
            let quantity = try container.decode(Int.self, forKey: .quantity)
            self = .input(item: item, quantity: quantity)
        case "axe":
            let axeType = try container.decode(AxeType.self, forKey: .axeType)
            let tier = try container.decode(AxeTier.self, forKey: .axeTier)
            self = .axe(type: axeType, tier: tier)
        case "plant":
            let plantType = try container.decode(PlantType.self, forKey: .plantType)
            self = .plant(type: plantType)
        case "repairDiscount":
            let percent = try container.decode(Int.self, forKey: .percent)
            self = .repairDiscount(percent: percent)
        case "bundle":
            let name = try container.decode(String.self, forKey: .bundleName)
            let itemsArray = try container.decode([[String: Int]].self, forKey: .bundleItems)
            var items: [InventoryItem: Int] = [:]
            for dict in itemsArray {
                for (key, value) in dict {
                    if let item = InventoryItem(rawValue: key) {
                        items[item] = value
                    }
                }
            }
            self = .bundle(name: name, items: items)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown deal type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .input(let item, let quantity):
            try container.encode("input", forKey: .type)
            try container.encode(item, forKey: .item)
            try container.encode(quantity, forKey: .quantity)
        case .axe(let type, let tier):
            try container.encode("axe", forKey: .type)
            try container.encode(type, forKey: .axeType)
            try container.encode(tier, forKey: .axeTier)
        case .plant(let type):
            try container.encode("plant", forKey: .type)
            try container.encode(type, forKey: .plantType)
        case .repairDiscount(let percent):
            try container.encode("repairDiscount", forKey: .type)
            try container.encode(percent, forKey: .percent)
        case .bundle(let name, let items):
            try container.encode("bundle", forKey: .type)
            try container.encode(name, forKey: .bundleName)
            let itemsArray = items.map { [$0.key.rawValue: $0.value] }
            try container.encode(itemsArray, forKey: .bundleItems)
        }
    }
}

// MARK: - Deal

struct Deal: Codable, Identifiable {
    let id: UUID
    let category: DealCategory
    let item: DealItem
    let originalPrice: Int
    let dealPrice: Int
    var isPurchased: Bool

    var discountPercent: Int {
        guard originalPrice > 0 else { return 0 }
        return Int((1.0 - Double(dealPrice) / Double(originalPrice)) * 100)
    }

    var savings: Int {
        originalPrice - dealPrice
    }

    init(category: DealCategory, item: DealItem, originalPrice: Int, discountPercent: Int) {
        self.id = UUID()
        self.category = category
        self.item = item
        self.originalPrice = originalPrice
        self.dealPrice = originalPrice - Int(Double(originalPrice) * Double(discountPercent) / 100.0)
        self.isPurchased = false
    }
}

// MARK: - Daily Deals

struct DailyDeals: Codable {
    var deals: [Deal]
    var generatedAt: Date

    var isExpired: Bool {
        !Calendar.current.isDateInToday(generatedAt)
    }

    static var empty: DailyDeals {
        DailyDeals(deals: [], generatedAt: Date.distantPast)
    }

    static func generate() -> DailyDeals {
        var deals: [Deal] = []

        // Supply deal
        let supplyOptions: [(DealItem, Int)] = [
            (.input(item: .rawFish, quantity: 3), 120),
            (.input(item: .rawNuts, quantity: 15), 45),
            (.input(item: .rawBerries, quantity: 15), 40),
            (.bundle(name: "Forager's Bundle", items: [.rawNuts: 15, .rawBerries: 15]), 70),
            (.input(item: .flour, quantity: 2), 40),
        ]
        if let supply = supplyOptions.randomElement() {
            deals.append(Deal(
                category: .supply,
                item: supply.0,
                originalPrice: supply.1,
                discountPercent: Int.random(in: 15...25)
            ))
        }

        // Equipment deal
        let equipmentOptions: [(DealItem, Int)] = [
            (.axe(type: .sharp, tier: .mid), 400),
            (.axe(type: .balanced, tier: .mid), 400),
            (.axe(type: .heavy, tier: .mid), 400),
            (.repairDiscount(percent: 50), 100),
        ]
        if let equipment = equipmentOptions.randomElement() {
            deals.append(Deal(
                category: .equipment,
                item: equipment.0,
                originalPrice: equipment.1,
                discountPercent: Int.random(in: 15...20)
            ))
        }

        // Special deal
        let specialOptions: [(DealItem, Int)] = [
            (.plant(type: .mapleTree), 800),
            (.plant(type: .hazelTree), 300),
            (.plant(type: .blueberryBush), 200),
            (.plant(type: .herbGarden), 400),
        ]
        if let special = specialOptions.randomElement() {
            deals.append(Deal(
                category: .special,
                item: special.0,
                originalPrice: special.1,
                discountPercent: Int.random(in: 15...25)
            ))
        }

        return DailyDeals(deals: deals, generatedAt: Date())
    }
}
