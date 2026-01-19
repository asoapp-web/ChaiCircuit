import Foundation

// ======================================================
// MARK: - 1️⃣ Supply Manager
// ======================================================
class SupplyManager: ObservableObject {
    @Published var entries: [SupplyEntry] = [] {
        didSet { saveData() }
    }
    private let storageKey = "SupplyEntries"
    
    init() {
        loadData()
//        if entries.isEmpty {
//            entries = [
//                SupplyEntry(
//                    itemName: "Tea Leaves",
//                    category: "Ingredient",
//                    quantityIn: 20,
//                    quantityOut: 5,
//                    unit: "kg",
//                    supplierName: "Assam Traders",
//                    supplierContact: "+92 333 4455667",
//                    purchaseDate: "2025-10-10",
//                    expiryDate: "2026-01-15",
//                    purchaseCost: 4000.0,
//                    currentStock: 15.0,
//                    storageCondition: "Dry",
//                    remarks: "Premium Assam blend"
//                ),
//                SupplyEntry(
//                    itemName: "Milk",
//                    category: "Ingredient",
//                    quantityIn: 50,
//                    quantityOut: 20,
//                    unit: "L",
//                    supplierName: "Dairy Fresh Co.",
//                    supplierContact: "+92 321 9876543",
//                    purchaseDate: "2025-10-14",
//                    expiryDate: "2025-10-20",
//                    purchaseCost: 8000.0,
//                    currentStock: 30.0,
//                    storageCondition: "Refrigerated",
//                    remarks: "Full cream milk"
//                )
//            ]
//            saveData()
//        }
    }
    
    func addItem(_ item: SupplyEntry) { entries.append(item) }
    func updateItem(_ item: SupplyEntry) {
        if let i = entries.firstIndex(where: { $0.id == item.id }) { entries[i] = item }
    }
    func deleteItem(at offsets: IndexSet) { entries.remove(atOffsets: offsets) }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SupplyEntry].self, from: data) else { return }
        entries = decoded
    }
    private func saveData() {
        guard let encoded = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}

// ======================================================
// MARK: - 2️⃣ Recipe Manager
// ======================================================
class RecipeManager: ObservableObject {
    @Published var entries: [RecipeEntry] = [] {
        didSet { saveData() }
    }
    private let storageKey = "RecipeEntries"
    
    init() {
        loadData()
//        if entries.isEmpty {
//            entries = [
//                RecipeEntry(
//                    recipeName: "Karak Masala Chai",
//                    teaLeafType: "Assam Strong",
//                    milkRatio: "1:2",
//                    sugarLevel: "Medium",
//                    spiceMix: "Cardamom, Clove, Ginger",
//                    preparationSteps: "Boil milk, add leaves and spices, simmer 5 mins",
//                    brewingTimeMinutes: 7,
//                    servingTemperatureC: 85,
//                    estimatedCostPerCup: 40.0,
//                    sellingPricePerCup: 100.0,
//                    cupSizeML: 250,
//                    notes: "Strong flavor, best for morning"
//                ),
//                RecipeEntry(
//                    recipeName: "Kashmiri Noon Chai",
//                    teaLeafType: "Pink Himalayan",
//                    milkRatio: "1:3",
//                    sugarLevel: "Low (Salted)",
//                    spiceMix: "Cardamom, Baking Soda, Salt",
//                    preparationSteps: "Brew leaves until pink, add milk and salt",
//                    brewingTimeMinutes: 10,
//                    servingTemperatureC: 75,
//                    estimatedCostPerCup: 50.0,
//                    sellingPricePerCup: 120.0,
//                    cupSizeML: 300,
//                    notes: "Cultural chai served with bread"
//                )
//            ]
//            saveData()
//        }
    }
    
    func addItem(_ item: RecipeEntry) { entries.append(item) }
    func updateItem(_ item: RecipeEntry) {
        if let i = entries.firstIndex(where: { $0.id == item.id }) { entries[i] = item }
    }
    func deleteItem(at offsets: IndexSet) { entries.remove(atOffsets: offsets) }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([RecipeEntry].self, from: data) else { return }
        entries = decoded
    }
    private func saveData() {
        guard let encoded = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}

// ======================================================
// MARK: - 3️⃣ Sales Manager
// ======================================================
class SalesManager: ObservableObject {
    @Published var entries: [SalesEntry] = [] {
        didSet { saveData() }
    }
    private let storageKey = "SalesEntries"
    
    init() {
        loadData()
//        if entries.isEmpty {
//            entries = [
//                SalesEntry(
//                    saleDate: "2025-10-15",
//                    totalCupsSold: 250,
//                    averagePricePerCup: 100.0,
//                    totalSalesRevenue: 25000.0,
//                    wasteCups: 8,
//                    leftoverMilkL: 5.0,
//                    leftoverSugarKG: 2.0,
//                    leftoverTeaLeavesKG: 1.5,
//                    staffName: "Imran",
//                    weatherCondition: "Rainy",
//                    busyHours: "Evening",
//                    remarks: "Good rainy day sales"
//                ),
//                SalesEntry(
//                    saleDate: "2025-10-16",
//                    totalCupsSold: 180,
//                    averagePricePerCup: 90.0,
//                    totalSalesRevenue: 16200.0,
//                    wasteCups: 6,
//                    leftoverMilkL: 4.0,
//                    leftoverSugarKG: 1.8,
//                    leftoverTeaLeavesKG: 1.2,
//                    staffName: "Ali",
//                    weatherCondition: "Sunny",
//                    busyHours: "Morning",
//                    remarks: "Steady morning crowd"
//                )
//            ]
//            saveData()
//        }
    }
    
    func addItem(_ item: SalesEntry) { entries.append(item) }
    func updateItem(_ item: SalesEntry) {
        if let i = entries.firstIndex(where: { $0.id == item.id }) { entries[i] = item }
    }
    func deleteItem(at offsets: IndexSet) { entries.remove(atOffsets: offsets) }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SalesEntry].self, from: data) else { return }
        entries = decoded
    }
    private func saveData() {
        guard let encoded = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}

// ======================================================
// MARK: - 4️⃣ Summary Manager
// ======================================================
class SummaryManager: ObservableObject {
    @Published var entries: [SummaryEntry] = [] {
        didSet { saveData() }
    }
    private let storageKey = "SummaryEntries"
    
    init() {
        loadData()
//        if entries.isEmpty {
//            entries = [
//                SummaryEntry(
//                    date: "2025-10-15",
//                    totalSuppliesUsedCost: 9000.0,
//                    totalSalesRevenue: 25000.0,
//                    netProfit: 16000.0,
//                    cupsSold: 250,
//                    dailyWasteCost: 300.0,
//                    leftoverStockValue: 1200.0,
//                    teaLeafRatePerKG: 800.0,
//                    milkRatePerL: 160.0,
//                    sugarRatePerKG: 150.0,
//                    remarks: "Strong sales, minimal waste",
//                    managerName: "Bilal"
//                ),
//                SummaryEntry(
//                    date: "2025-10-16",
//                    totalSuppliesUsedCost: 7800.0,
//                    totalSalesRevenue: 16200.0,
//                    netProfit: 8400.0,
//                    cupsSold: 180,
//                    dailyWasteCost: 200.0,
//                    leftoverStockValue: 950.0,
//                    teaLeafRatePerKG: 820.0,
//                    milkRatePerL: 165.0,
//                    sugarRatePerKG: 155.0,
//                    remarks: "Moderate day, steady traffic",
//                    managerName: "Bilal"
//                )
//            ]
//            saveData()
//        }
    }
    
    func addItem(_ item: SummaryEntry) { entries.append(item) }
    func updateItem(_ item: SummaryEntry) {
        if let i = entries.firstIndex(where: { $0.id == item.id }) { entries[i] = item }
    }
    func deleteItem(at offsets: IndexSet) { entries.remove(atOffsets: offsets) }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SummaryEntry].self, from: data) else { return }
        entries = decoded
    }
    private func saveData() {
        guard let encoded = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}
