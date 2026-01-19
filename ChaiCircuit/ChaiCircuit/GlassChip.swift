import SwiftUI

// ======================================================
// 1️⃣ Supply List & Card
// ======================================================
import SwiftUI

// MARK: - Supply List View
struct SupplyListView: View {
    @EnvironmentObject var appData: SupplyManager
    @State private var showingAddEdit = false
    @State private var selected: SupplyEntry? = nil
    
    var totalItems: Int {
        appData.entries.count
    }
    
    var totalStockValue: Double {
        appData.entries.reduce(0) { $0 + $1.purchaseCost }
    }
    
    var lowStockItems: Int {
        appData.entries.filter { $0.currentStock < 10 }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Custom gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "fff7ed"),
                        Color(hex: "fed7aa")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Supplies")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(hex: "7c2d12"))
                                
                                Text("Track inventory in real-time")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "b45309"))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // Stats Cards - Horizontal Scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            StatsCard(
                                title: "Total Items",
                                value: "\(totalItems)",
                                icon: "box.2.fill",
                                color: Color(hex: "ea580c"),
                                bgColor: Color(hex: "fed7aa")
                            )
                            
                            StatsCard(
                                title: "Stock Value",
                                value: "Rs \(Int(totalStockValue))",
                                icon: "bag.fill",
                                color: Color(hex: "c2410c"),
                                bgColor: Color(hex: "ffedd5")
                            )
                            
                            StatsCard(
                                title: "Low Stock",
                                value: "\(lowStockItems)",
                                icon: "exclamationmark.triangle.fill",
                                color: Color(hex: "dc2626"),
                                bgColor: Color(hex: "fee2e2")
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    
                    // Supply Cards List
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 14) {
                            if appData.entries.isEmpty {
                                EmptyStateView(
                                    icon: "box.2.fill",
                                    title: "No Supplies Yet",
                                    subtitle: "Add your first supply item to get started"
                                )
                                .padding(.top, 40)
                            } else {
                                ForEach(appData.entries) { entry in
                                    NavigationLink(destination: AddEditSupplyView(entryToEdit: entry)
                                        .environmentObject(appData)) {
                                        SupplyGlassCard(entry: entry, appData: appData)
                                    }
                                }
                                .onDelete(perform: appData.deleteItem)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { selected = nil; showingAddEdit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "ea580c"), Color(hex: "c2410c")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddEdit) {
                AddEditSupplyView(entryToEdit: selected)
                    .environmentObject(appData)
            }
        }
    }
}

// MARK: - Stats Card Component
struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let bgColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(hex: "92400e"))
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .padding(14)
        .frame(minWidth: 140)
        .background(bgColor)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "ea580c").opacity(0.3))
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "7c2d12"))
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "b45309"))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}

// MARK: - Enhanced Supply Card
struct SupplyGlassCard: View {
    let entry: SupplyEntry
    let appData: SupplyManager
    @State private var isHovered = false
    
    var stockPercentage: Double {
        (entry.currentStock / max(entry.quantityIn, 1)) * 100
    }
    
    var stockStatus: String {
        entry.currentStock < 10 ? "Low Stock" : "In Stock"
    }
    
    var stockColor: Color {
        entry.currentStock < 10 ? Color(hex: "dc2626") : Color(hex: "10b981")
    }
    
    var body: some View {
        ZStack {
            // Multi-layer background
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.95),
                        Color.white.opacity(0.88)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "ea580c").opacity(0.03),
                        Color(hex: "c2410c").opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.8),
                                Color(hex: "ffedd5").opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 6)
            .shadow(color: Color(hex: "ea580c").opacity(0.08), radius: 8, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 14) {
                // Header Section
                HStack(spacing: 12) {
                    // Icon Box
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "ffedd5"),
                                        Color(hex: "fed7aa")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "ea580c"))
                    }
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.itemName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "7c2d12"))
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(entry.supplierName)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "b45309"))
                    }
                    
                    Spacer()
                    
                    // Category Badge
                    VStack(spacing: 4) {
                        Text(entry.category)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "c2410c"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: "fed7aa"))
                            .cornerRadius(8)
                        
                        Text(stockStatus)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(stockColor)
                            .cornerRadius(6)
                    }
                }
                
                // Stock Progress Bar
                VStack(spacing: 6) {
                    HStack {
                        Text("Current Stock")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "92400e"))
                        
                        Spacer()
                        
                        Text("\(Int(entry.currentStock)) \(entry.unit)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "ea580c"))
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "fed7aa"))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "ea580c"),
                                        Color(hex: "c2410c")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(CGFloat(stockPercentage) / 100 * 200, 8), height: 6)
                    }
                }
                
                // Details Row
                HStack(spacing: 10) {
                    DetailBadge(
                        icon: "calendar",
                        text: entry.purchaseDate,
                        color: Color(hex: "ea580c")
                    )
                    
                    DetailBadge(
                        icon: "snowflake",
                        text: entry.storageCondition,
                        color: Color(hex: "0891b2")
                    )
                    
                    Spacer()
                    
                    Menu {
                        Button(role: .destructive) {
                            if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                                appData.deleteItem(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "fed7aa"))
                            .padding(6)
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 180)
        .contextMenu {
            Button(role: .destructive) {
                if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                    appData.deleteItem(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Detail Badge Component
struct DetailBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "7c2d12"))
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(8)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0
        let red = Double((rgb >> 16) & 0xff) / 255
        let green = Double((rgb >> 8) & 0xff) / 255
        let blue = Double((rgb >> 0) & 0xff) / 255
        self.init(red: red, green: green, blue: blue)
    }
}


import SwiftUI

// MARK: - 2️⃣ Recipe List & Card
struct RecipeListView: View {
    @EnvironmentObject var appData: RecipeManager
    @State private var showingAddEdit = false
    @State private var selected: RecipeEntry? = nil
    
    var totalRecipes: Int {
        appData.entries.count
    }
    
    var avgSellingPrice: Double {
        appData.entries.isEmpty ? 0 : appData.entries.reduce(0) { $0 + $1.sellingPricePerCup } / Double(appData.entries.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "fef5e7"),
                        Color(hex: "ffe8cc")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recipes")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(hex: "6b4423"))
                                
                                Text("Manage custom chai blends")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "92621a"))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // Stats Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            StatsCard(
                                title: "Total Recipes",
                                value: "\(totalRecipes)",
                                icon: "leaf.fill",
                                color: Color(hex: "8b5a3c"),
                                bgColor: Color(hex: "ffe8cc")
                            )
                            
                            StatsCard(
                                title: "Avg Price",
                                value: "Rs \(Int(avgSellingPrice))",
                                icon: "cup.and.saucer.fill",
                                color: Color(hex: "6b4423"),
                                bgColor: Color(hex: "fef5e7")
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 14) {
                            if appData.entries.isEmpty {
                                EmptyStateView(
                                    icon: "leaf.fill",
                                    title: "No Recipes Yet",
                                    subtitle: "Create your first chai blend"
                                )
                                .padding(.top, 40)
                            } else {
                                ForEach(appData.entries) { entry in
                                    NavigationLink(destination: AddEditRecipeView(entryToEdit: entry)
                                        .environmentObject(appData)) {
                                        RecipeGlassCard(entry: entry, appData: appData)
                                    }
                                }
                                .onDelete(perform: appData.deleteItem)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { selected = nil; showingAddEdit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "8b5a3c"), Color(hex: "6b4423")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddEdit) {
                AddEditRecipeView(entryToEdit: selected)
                    .environmentObject(appData)
            }
        }
    }
}

struct RecipeGlassCard: View {
    let entry: RecipeEntry
    let appData: RecipeManager
    @State private var isHovered = false
    
    var profitMargin: Double {
        ((entry.sellingPricePerCup - entry.estimatedCostPerCup) / entry.sellingPricePerCup) * 100
    }
    
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.96),
                        Color.white.opacity(0.88)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "8b5a3c").opacity(0.03),
                        Color(hex: "6b4423").opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.8),
                                Color(hex: "ffe8cc").opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 6)
            .shadow(color: Color(hex: "8b5a3c").opacity(0.08), radius: 8, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "fef5e7"),
                                        Color(hex: "ffe8cc")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "8b5a3c"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.recipeName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "6b4423"))
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(entry.teaLeafType)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "92621a"))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(entry.sugarLevel)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "6b4423"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: "ffe8cc"))
                            .cornerRadius(8)
                        
                        Text(String(format: "%.0f%%", profitMargin))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "8b5a3c"))
                            .cornerRadius(6)
                    }
                }
                
                VStack(spacing: 6) {
                    HStack {
                        Text("Brew Time & Price")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "92621a"))
                        
                        Spacer()
                        
                        Text("Rs \(Int(entry.sellingPricePerCup))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "8b5a3c"))
                    }
                    
                    HStack(spacing: 10) {
                        DetailBadge(
                            icon: "timer",
                            text: "\(entry.brewingTimeMinutes) min",
                            color: Color(hex: "8b5a3c")
                        )
                        
                        DetailBadge(
                            icon: "thermometer",
                            text: "\(entry.servingTemperatureC)°C",
                            color: Color(hex: "d97706")
                        )
                        
                        DetailBadge(
                            icon: "cup.and.saucer.fill",
                            text: "\(entry.cupSizeML)ml",
                            color: Color(hex: "6b4423")
                        )
                        
                        Spacer()
                        
                        Menu {
                            Button(role: .destructive) {
                                if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                                    appData.deleteItem(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "ffe8cc"))
                                .padding(6)
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 180)
        .contextMenu {
            Button(role: .destructive) {
                if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                    appData.deleteItem(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - 3️⃣ Sales List & Card
struct SalesListView: View {
    @EnvironmentObject var appData: SalesManager
    @State private var showingAddEdit = false
    @State private var selected: SalesEntry? = nil
    
    var totalSales: Int {
        appData.entries.count
    }
    
    var totalRevenue: Double {
        appData.entries.reduce(0) { $0 + $1.totalSalesRevenue }
    }
    
    var totalWaste: Int {
        appData.entries.reduce(0) { $0 + $1.wasteCups }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "ccfbf1"),
                        Color(hex: "99f6e4")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sales")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(hex: "0d5c5c"))
                                
                                Text("Track daily sales & waste")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "0f766e"))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // Stats Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            StatsCard(
                                title: "Total Sales",
                                value: "\(totalSales)",
                                icon: "cup.and.saucer.fill",
                                color: Color(hex: "0d9488"),
                                bgColor: Color(hex: "99f6e4")
                            )
                            
                            StatsCard(
                                title: "Total Revenue",
                                value: "Rs \(Int(totalRevenue))",
                                icon: "dollarsign.circle.fill",
                                color: Color(hex: "0d5c5c"),
                                bgColor: Color(hex: "ccfbf1")
                            )
                            
                            StatsCard(
                                title: "Waste Cups",
                                value: "\(totalWaste)",
                                icon: "xmark.circle.fill",
                                color: Color(hex: "dc2626"),
                                bgColor: Color(hex: "fee2e2")
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 14) {
                            if appData.entries.isEmpty {
                                EmptyStateView(
                                    icon: "cup.and.saucer.fill",
                                    title: "No Sales Yet",
                                    subtitle: "Record your first sale"
                                )
                                .padding(.top, 40)
                            } else {
                                ForEach(appData.entries) { entry in
                                    NavigationLink(destination: AddEditSalesView(entryToEdit: entry)
                                        .environmentObject(appData)) {
                                        SalesGlassCard(entry: entry, appData: appData)
                                    }
                                }
                                .onDelete(perform: appData.deleteItem)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { selected = nil; showingAddEdit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "0d9488"), Color(hex: "0d5c5c")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddEdit) {
                AddEditSalesView(entryToEdit: selected)
                    .environmentObject(appData)
            }
        }
    }
}

struct SalesGlassCard: View {
    let entry: SalesEntry
    let appData: SalesManager
    @State private var isHovered = false
    
    var wastePercentage: Double {
        let total = Double(entry.totalCupsSold + entry.wasteCups)
        return total > 0 ? (Double(entry.wasteCups) / total) * 100 : 0
    }
    
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.96),
                        Color.white.opacity(0.88)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "0d9488").opacity(0.03),
                        Color(hex: "0d5c5c").opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.8),
                                Color(hex: "99f6e4").opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 6)
            .shadow(color: Color(hex: "0d9488").opacity(0.08), radius: 8, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "ccfbf1"),
                                        Color(hex: "99f6e4")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "0d9488"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.saleDate)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "0d5c5c"))
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(entry.staffName)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "0f766e"))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(entry.busyHours)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "0d5c5c"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: "99f6e4"))
                            .cornerRadius(8)
                        
                        Text(entry.weatherCondition)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "0d9488"))
                            .cornerRadius(6)
                    }
                }
                
                VStack(spacing: 6) {
                    HStack {
                        Text("Cups Sold & Revenue")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "0f766e"))
                        
                        Spacer()
                        
                        Text("Rs \(Int(entry.totalSalesRevenue))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "0d9488"))
                    }
                    
                    HStack(spacing: 10) {
                        DetailBadge(
                            icon: "cup.and.saucer.fill",
                            text: "\(entry.totalCupsSold) cups",
                            color: Color(hex: "0d9488")
                        )
                        
                        DetailBadge(
                            icon: "xmark.circle.fill",
                            text: "\(entry.wasteCups) waste",
                            color: Color(hex: "dc2626")
                        )
                        
                        DetailBadge(
                            icon: "cloud.fill",
                            text: entry.weatherCondition,
                            color: Color(hex: "3b82f6")
                        )
                        
                        Spacer()
                        
                        Menu {
                            Button(role: .destructive) {
                                if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                                    appData.deleteItem(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "a7f3d0"))
                                .padding(6)
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 180)
        .contextMenu {
            Button(role: .destructive) {
                if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                    appData.deleteItem(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - 4️⃣ Summary List & Card
struct SummaryListView: View {
    @EnvironmentObject var appData: SummaryManager
    @State private var showingAddEdit = false
    @State private var selected: SummaryEntry? = nil
    
    var totalSummaries: Int {
        appData.entries.count
    }
    
    var totalNetProfit: Double {
        appData.entries.reduce(0) { $0 + $1.netProfit }
    }
    
    var totalCupsSold: Int {
        appData.entries.reduce(0) { $0 + $1.cupsSold }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "f0fdfa"),
                        Color(hex: "d1fae5")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Summary")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(hex: "064e3b"))
                                
                                Text("Daily balance & profit analysis")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "047857"))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // Stats Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            StatsCard(
                                title: "Net Profit",
                                value: "Rs \(Int(totalNetProfit))",
                                icon: "chart.line.uptrend.xyaxis",
                                color: Color(hex: "059669"),
                                bgColor: Color(hex: "d1fae5")
                            )
                            
                            StatsCard(
                                title: "Total Cups",
                                value: "\(totalCupsSold)",
                                icon: "cup.and.saucer.fill",
                                color: Color(hex: "064e3b"),
                                bgColor: Color(hex: "f0fdfa")
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 14) {
                            if appData.entries.isEmpty {
                                EmptyStateView(
                                    icon: "chart.bar.fill",
                                    title: "No Summary Yet",
                                    subtitle: "Create your first daily summary"
                                )
                                .padding(.top, 40)
                            } else {
                                ForEach(appData.entries) { entry in
                                    NavigationLink(destination: AddEditSummaryView(entryToEdit: entry)
                                        .environmentObject(appData)) {
                                        SummaryGlassCard(entry: entry, appData: appData)
                                    }
                                }
                                .onDelete(perform: appData.deleteItem)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { selected = nil; showingAddEdit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "059669"), Color(hex: "064e3b")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddEdit) {
                AddEditSummaryView(entryToEdit: selected)
                    .environmentObject(appData)
            }
        }
    }
}

struct SummaryGlassCard: View {
    let entry: SummaryEntry
    let appData: SummaryManager
    @State private var isHovered = false
    
    var profitPercentage: Double {
        entry.totalSalesRevenue > 0 ? (entry.netProfit / entry.totalSalesRevenue) * 100 : 0
    }
    
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.96),
                        Color.white.opacity(0.88)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "059669").opacity(0.03),
                        Color(hex: "064e3b").opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.8),
                                Color(hex: "d1fae5").opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 6)
            .shadow(color: Color(hex: "059669").opacity(0.08), radius: 8, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "f0fdfa"),
                                        Color(hex: "d1fae5")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "059669"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.date)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "064e3b"))
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(entry.managerName)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "047857"))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("\(entry.cupsSold) cups")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "064e3b"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: "d1fae5"))
                            .cornerRadius(8)
                        
                        Text(String(format: "%.0f%% profit", profitPercentage))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "059669"))
                            .cornerRadius(6)
                    }
                }
                
                VStack(spacing: 6) {
                    HStack {
                        Text("Revenue & Profit")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "047857"))
                        
                        Spacer()
                        
                        Text("Rs \(Int(entry.netProfit))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "059669"))
                    }
                    
                    HStack(spacing: 10) {
                        DetailBadge(
                            icon: "dollarsign.circle.fill",
                            text: "Rev: Rs \(Int(entry.totalSalesRevenue))",
                            color: Color(hex: "059669")
                        )
                        
                        DetailBadge(
                            icon: "sum",
                            text: "Cost: Rs \(Int(entry.totalSuppliesUsedCost))",
                            color: Color(hex: "dc2626")
                        )
                        
                        DetailBadge(
                            icon: "trash.fill",
                            text: "Waste: Rs \(Int(entry.dailyWasteCost))",
                            color: Color(hex: "f59e0b")
                        )
                        
                        Spacer()
                        
                        Menu {
                            Button(role: .destructive) {
                                if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                                    appData.deleteItem(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "a7f3d0"))
                                .padding(6)
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 180)
        .contextMenu {
            Button(role: .destructive) {
                if let index = appData.entries.firstIndex(where: { $0.id == entry.id }) {
                    appData.deleteItem(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
