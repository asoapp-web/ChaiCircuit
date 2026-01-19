import Foundation

// MARK: - 1️⃣ Supplies Entry (Stock In/Out)
struct SupplyEntry: Identifiable, Codable {
    var id = UUID()
    var itemName: String                // Tea Leaves, Milk, Sugar, Masala
    var category: String                // Ingredient, Packaging, Equipment
    var quantityIn: Double              // Received stock
    var quantityOut: Double             // Used/sold/expired
    var unit: String                    // kg, L, packets
    var supplierName: String            // Vendor name
    var supplierContact: String         // Phone or WhatsApp
    var purchaseDate: String            // "YYYY-MM-DD"
    var expiryDate: String              // Optional for milk/sugar
    var purchaseCost: Double            // Cost per batch
    var currentStock: Double            // Auto-calculated remaining
    var storageCondition: String        // Cool, Dry, Refrigerated
    var remarks: String                 // Notes for spoilage, restock
}

// MARK: - 2️⃣ Recipe Entry (Custom Chai Mixes)
struct RecipeEntry: Identifiable, Codable {
    var id = UUID()
    var recipeName: String              // e.g. “Karak Masala Chai”
    var teaLeafType: String             // Assam, Darjeeling, Local Blend
    var milkRatio: String               // e.g. “1:2 with water”
    var sugarLevel: String              // Low, Medium, High
    var spiceMix: String                // Cardamom, Clove, Ginger
    var preparationSteps: String        // Brewing method
    var brewingTimeMinutes: Int         // 5–10
    var servingTemperatureC: Int        // 70–90
    var estimatedCostPerCup: Double
    var sellingPricePerCup: Double
    var cupSizeML: Int
    var notes: String                   // Optional taste or feedback
}

// MARK: - 3️⃣ Sales Entry (Cups Sold & Waste Tracking)
struct SalesEntry: Identifiable, Codable {
    var id = UUID()
    var saleDate: String                // "YYYY-MM-DD"
    var totalCupsSold: Int
    var averagePricePerCup: Double
    var totalSalesRevenue: Double       // Derived field
    var wasteCups: Int                  // Burnt or spilled tea
    var leftoverMilkL: Double
    var leftoverSugarKG: Double
    var leftoverTeaLeavesKG: Double
    var staffName: String               // Cashier or chaiwala
    var weatherCondition: String        // Rainy, Hot, Cold
    var busyHours: String               // Morning, Evening
    var remarks: String
}

// MARK: - 4️⃣ Summary Entry (Daily Balance & Cost)
struct SummaryEntry: Identifiable, Codable {
    var id = UUID()
    var date: String                    // "YYYY-MM-DD"
    var totalSuppliesUsedCost: Double
    var totalSalesRevenue: Double
    var netProfit: Double
    var cupsSold: Int
    var dailyWasteCost: Double
    var leftoverStockValue: Double
    var teaLeafRatePerKG: Double
    var milkRatePerL: Double
    var sugarRatePerKG: Double
    var remarks: String
    var managerName: String
}
