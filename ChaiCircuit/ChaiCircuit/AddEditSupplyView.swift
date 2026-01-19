import SwiftUI

// ======================================================
// MARK: - 1️⃣ Add/Edit Supply Entry
// ======================================================
struct AddEditSupplyView: View {
    @EnvironmentObject var appData: SupplyManager
    @Environment(\.dismiss) private var dismiss
    
    let entryToEdit: SupplyEntry?
    
    @State private var itemName = ""
    @State private var category = ""
    @State private var quantityIn = ""
    @State private var quantityOut = ""
    @State private var unit = ""
    @State private var supplierName = ""
    @State private var supplierContact = ""
    @State private var purchaseDate = Date()
    @State private var expiryDate = Date()
    @State private var purchaseCost = ""
    @State private var currentStock = ""
    @State private var storageCondition = ""
    @State private var remarks = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Info") {
                    TextField("Item Name", text: $itemName)
                    TextField("Category", text: $category)
                    TextField("Unit (kg, L, etc.)", text: $unit)
                }
                
                Section("Stock & Supplier") {
                    TextField("Quantity In", text: $quantityIn).keyboardType(.decimalPad)
                    TextField("Quantity Out", text: $quantityOut).keyboardType(.decimalPad)
                    TextField("Current Stock", text: $currentStock).keyboardType(.decimalPad)
                    TextField("Supplier Name", text: $supplierName)
                    TextField("Supplier Contact", text: $supplierContact)
                }
                
                Section("Dates & Cost") {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                    TextField("Purchase Cost", text: $purchaseCost).keyboardType(.decimalPad)
                    TextField("Storage Condition", text: $storageCondition)
                }
                
                Section("Remarks") {
                    TextField("Remarks", text: $remarks)
                }
            }
            .navigationTitle(entryToEdit == nil ? "Add Supply" : "Edit Supply")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { saveEntry() } }
            }
            .onAppear(perform: populate)
        }
    }
    
    private func populate() {
        guard let e = entryToEdit else { return }
        itemName = e.itemName
        category = e.category
        quantityIn = String(e.quantityIn)
        quantityOut = String(e.quantityOut)
        unit = e.unit
        supplierName = e.supplierName
        supplierContact = e.supplierContact
        purchaseDate = dateFrom(e.purchaseDate)
        expiryDate = dateFrom(e.expiryDate)
        purchaseCost = String(e.purchaseCost)
        currentStock = String(e.currentStock)
        storageCondition = e.storageCondition
        remarks = e.remarks
    }
    
    private func saveEntry() {
        let new = SupplyEntry(
            itemName: itemName,
            category: category,
            quantityIn: Double(quantityIn) ?? 0,
            quantityOut: Double(quantityOut) ?? 0,
            unit: unit,
            supplierName: supplierName,
            supplierContact: supplierContact,
            purchaseDate: fmt(purchaseDate),
            expiryDate: fmt(expiryDate),
            purchaseCost: Double(purchaseCost) ?? 0,
            currentStock: Double(currentStock) ?? 0,
            storageCondition: storageCondition,
            remarks: remarks
        )
        if let e = entryToEdit {
            var updated = new; updated.id = e.id; appData.updateItem(updated)
        } else { appData.addItem(new) }
        dismiss()
    }
    
    private func fmt(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d) }
    private func dateFrom(_ s: String) -> Date { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.date(from: s) ?? Date() }
}

// ======================================================
// MARK: - 2️⃣ Add/Edit Recipe Entry
// ======================================================
struct AddEditRecipeView: View {
    @EnvironmentObject var appData: RecipeManager
    @Environment(\.dismiss) private var dismiss
    let entryToEdit: RecipeEntry?
    
    @State private var recipeName = ""
    @State private var teaLeafType = ""
    @State private var milkRatio = ""
    @State private var sugarLevel = ""
    @State private var spiceMix = ""
    @State private var preparationSteps = ""
    @State private var brewingTimeMinutes = ""
    @State private var servingTemperatureC = ""
    @State private var estimatedCostPerCup = ""
    @State private var sellingPricePerCup = ""
    @State private var cupSizeML = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Recipe Info") {
                    TextField("Recipe Name", text: $recipeName)
                    TextField("Tea Leaf Type", text: $teaLeafType)
                    TextField("Milk Ratio (1:2 etc.)", text: $milkRatio)
                    TextField("Sugar Level", text: $sugarLevel)
                    TextField("Spice Mix", text: $spiceMix)
                }
                Section("Preparation") {
                    TextField("Steps", text: $preparationSteps)
                    TextField("Brew Time (min)", text: $brewingTimeMinutes).keyboardType(.numberPad)
                    TextField("Serve Temp (°C)", text: $servingTemperatureC).keyboardType(.numberPad)
                }
                Section("Pricing") {
                    TextField("Est. Cost/Cup", text: $estimatedCostPerCup).keyboardType(.decimalPad)
                    TextField("Selling Price", text: $sellingPricePerCup).keyboardType(.decimalPad)
                    TextField("Cup Size (mL)", text: $cupSizeML).keyboardType(.numberPad)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle(entryToEdit == nil ? "Add Recipe" : "Edit Recipe")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { saveEntry() } }
            }
            .onAppear(perform: populate)
        }
    }
    
    private func populate() {
        guard let e = entryToEdit else { return }
        recipeName = e.recipeName
        teaLeafType = e.teaLeafType
        milkRatio = e.milkRatio
        sugarLevel = e.sugarLevel
        spiceMix = e.spiceMix
        preparationSteps = e.preparationSteps
        brewingTimeMinutes = String(e.brewingTimeMinutes)
        servingTemperatureC = String(e.servingTemperatureC)
        estimatedCostPerCup = String(e.estimatedCostPerCup)
        sellingPricePerCup = String(e.sellingPricePerCup)
        cupSizeML = String(e.cupSizeML)
        notes = e.notes
    }
    
    private func saveEntry() {
        let new = RecipeEntry(
            recipeName: recipeName,
            teaLeafType: teaLeafType,
            milkRatio: milkRatio,
            sugarLevel: sugarLevel,
            spiceMix: spiceMix,
            preparationSteps: preparationSteps,
            brewingTimeMinutes: Int(brewingTimeMinutes) ?? 0,
            servingTemperatureC: Int(servingTemperatureC) ?? 0,
            estimatedCostPerCup: Double(estimatedCostPerCup) ?? 0,
            sellingPricePerCup: Double(sellingPricePerCup) ?? 0,
            cupSizeML: Int(cupSizeML) ?? 0,
            notes: notes
        )
        if let e = entryToEdit { var updated = new; updated.id = e.id; appData.updateItem(updated) }
        else { appData.addItem(new) }
        dismiss()
    }
}

// ======================================================
// MARK: - 3️⃣ Add/Edit Sales Entry
// ======================================================
struct AddEditSalesView: View {
    @EnvironmentObject var appData: SalesManager
    @Environment(\.dismiss) private var dismiss
    let entryToEdit: SalesEntry?
    
    @State private var saleDate = Date()
    @State private var totalCupsSold = ""
    @State private var averagePricePerCup = ""
    @State private var totalSalesRevenue = ""
    @State private var wasteCups = ""
    @State private var leftoverMilkL = ""
    @State private var leftoverSugarKG = ""
    @State private var leftoverTeaLeavesKG = ""
    @State private var staffName = ""
    @State private var weatherCondition = ""
    @State private var busyHours = ""
    @State private var remarks = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Sales Info") {
                    DatePicker("Sale Date", selection: $saleDate, displayedComponents: .date)
                    TextField("Cups Sold", text: $totalCupsSold).keyboardType(.numberPad)
                    TextField("Avg Price per Cup", text: $averagePricePerCup).keyboardType(.decimalPad)
                    TextField("Total Revenue", text: $totalSalesRevenue).keyboardType(.decimalPad)
                }
                Section("Waste & Leftover") {
                    TextField("Waste Cups", text: $wasteCups).keyboardType(.numberPad)
                    TextField("Leftover Milk (L)", text: $leftoverMilkL).keyboardType(.decimalPad)
                    TextField("Leftover Sugar (kg)", text: $leftoverSugarKG).keyboardType(.decimalPad)
                    TextField("Leftover Tea Leaves (kg)", text: $leftoverTeaLeavesKG).keyboardType(.decimalPad)
                }
                Section("Staff & Notes") {
                    TextField("Staff Name", text: $staffName)
                    TextField("Weather", text: $weatherCondition)
                    TextField("Busy Hours", text: $busyHours)
                    TextField("Remarks", text: $remarks)
                }
            }
            .navigationTitle(entryToEdit == nil ? "Add Sales" : "Edit Sales")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { saveEntry() } }
            }
            .onAppear(perform: populate)
        }
    }
    
    private func populate() {
        guard let e = entryToEdit else { return }
        saleDate = dateFrom(e.saleDate)
        totalCupsSold = String(e.totalCupsSold)
        averagePricePerCup = String(e.averagePricePerCup)
        totalSalesRevenue = String(e.totalSalesRevenue)
        wasteCups = String(e.wasteCups)
        leftoverMilkL = String(e.leftoverMilkL)
        leftoverSugarKG = String(e.leftoverSugarKG)
        leftoverTeaLeavesKG = String(e.leftoverTeaLeavesKG)
        staffName = e.staffName
        weatherCondition = e.weatherCondition
        busyHours = e.busyHours
        remarks = e.remarks
    }
    
    private func saveEntry() {
        let new = SalesEntry(
            saleDate: fmt(saleDate),
            totalCupsSold: Int(totalCupsSold) ?? 0,
            averagePricePerCup: Double(averagePricePerCup) ?? 0,
            totalSalesRevenue: Double(totalSalesRevenue) ?? 0,
            wasteCups: Int(wasteCups) ?? 0,
            leftoverMilkL: Double(leftoverMilkL) ?? 0,
            leftoverSugarKG: Double(leftoverSugarKG) ?? 0,
            leftoverTeaLeavesKG: Double(leftoverTeaLeavesKG) ?? 0,
            staffName: staffName,
            weatherCondition: weatherCondition,
            busyHours: busyHours,
            remarks: remarks
        )
        if let e = entryToEdit { var updated = new; updated.id = e.id; appData.updateItem(updated) }
        else { appData.addItem(new) }
        dismiss()
    }
    
    private func fmt(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d) }
    private func dateFrom(_ s: String) -> Date { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.date(from: s) ?? Date() }
}

// ======================================================
// MARK: - 4️⃣ Add/Edit Summary Entry
// ======================================================
struct AddEditSummaryView: View {
    @EnvironmentObject var appData: SummaryManager
    @Environment(\.dismiss) private var dismiss
    let entryToEdit: SummaryEntry?
    
    @State private var date = Date()
    @State private var totalSuppliesUsedCost = ""
    @State private var totalSalesRevenue = ""
    @State private var netProfit = ""
    @State private var cupsSold = ""
    @State private var dailyWasteCost = ""
    @State private var leftoverStockValue = ""
    @State private var teaLeafRatePerKG = ""
    @State private var milkRatePerL = ""
    @State private var sugarRatePerKG = ""
    @State private var remarks = ""
    @State private var managerName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Summary") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Supplies Cost", text: $totalSuppliesUsedCost).keyboardType(.decimalPad)
                    TextField("Sales Revenue", text: $totalSalesRevenue).keyboardType(.decimalPad)
                    TextField("Net Profit", text: $netProfit).keyboardType(.decimalPad)
                }
                Section("Rates & Values") {
                    TextField("Cups Sold", text: $cupsSold).keyboardType(.numberPad)
                    TextField("Waste Cost", text: $dailyWasteCost).keyboardType(.decimalPad)
                    TextField("Leftover Stock Value", text: $leftoverStockValue).keyboardType(.decimalPad)
                    TextField("Tea Leaf Rate/kg", text: $teaLeafRatePerKG).keyboardType(.decimalPad)
                    TextField("Milk Rate/L", text: $milkRatePerL).keyboardType(.decimalPad)
                    TextField("Sugar Rate/kg", text: $sugarRatePerKG).keyboardType(.decimalPad)
                }
                Section("Manager & Notes") {
                    TextField("Manager Name", text: $managerName)
                    TextField("Remarks", text: $remarks)
                }
            }
            .navigationTitle(entryToEdit == nil ? "Add Summary" : "Edit Summary")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { saveEntry() } }
            }
            .onAppear(perform: populate)
        }
    }
    
    private func populate() {
        guard let e = entryToEdit else { return }
        date = dateFrom(e.date)
        totalSuppliesUsedCost = String(e.totalSuppliesUsedCost)
        totalSalesRevenue = String(e.totalSalesRevenue)
        netProfit = String(e.netProfit)
        cupsSold = String(e.cupsSold)
        dailyWasteCost = String(e.dailyWasteCost)
        leftoverStockValue = String(e.leftoverStockValue)
        teaLeafRatePerKG = String(e.teaLeafRatePerKG)
        milkRatePerL = String(e.milkRatePerL)
        sugarRatePerKG = String(e.sugarRatePerKG)
        remarks = e.remarks
        managerName = e.managerName
    }
    
    private func saveEntry() {
        let new = SummaryEntry(
            date: fmt(date),
            totalSuppliesUsedCost: Double(totalSuppliesUsedCost) ?? 0,
            totalSalesRevenue: Double(totalSalesRevenue) ?? 0,
            netProfit: Double(netProfit) ?? 0,
            cupsSold: Int(cupsSold) ?? 0,
            dailyWasteCost: Double(dailyWasteCost) ?? 0,
            leftoverStockValue: Double(leftoverStockValue) ?? 0,
            teaLeafRatePerKG: Double(teaLeafRatePerKG) ?? 0,
            milkRatePerL: Double(milkRatePerL) ?? 0,
            sugarRatePerKG: Double(sugarRatePerKG) ?? 0,
            remarks: remarks,
            managerName: managerName
        )
        if let e = entryToEdit { var updated = new; updated.id = e.id; appData.updateItem(updated) }
        else { appData.addItem(new) }
        dismiss()
    }
    
    private func fmt(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d) }
    private func dateFrom(_ s: String) -> Date { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.date(from: s) ?? Date() }
}
