import SwiftUI

struct ContentView: View {
    // MARK: - Managers
    @StateObject private var supplyManager = SupplyManager()
    @StateObject private var recipeManager = RecipeManager()
    @StateObject private var salesManager = SalesManager()
    @StateObject private var summaryManager = SummaryManager()
    
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Custom background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "fef5e7").opacity(0.5),
                    Color(hex: "fff7ed").opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // 1️⃣ Supplies
                SupplyListView()
                    .environmentObject(supplyManager)
                    .tag(0)
                
                // 2️⃣ Recipes
                RecipeListView()
                    .environmentObject(recipeManager)
                    .tag(1)
                
                // 3️⃣ Sales
                SalesListView()
                    .environmentObject(salesManager)
                    .tag(2)
                
                // 4️⃣ Summary
                SummaryListView()
                    .environmentObject(summaryManager)
                    .tag(3)
            }
            
            // Custom Tab Bar
            VStack {
                Spacer()
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs = [
        ("shippingbox.fill", "Supplies", Color(hex: "ea580c")),
        ("leaf.fill", "Recipes", Color(hex: "8b5a3c")),
        ("cup.and.saucer.fill", "Sales", Color(hex: "0d9488")),
        ("chart.bar.fill", "Summary", Color(hex: "059669"))
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.black.opacity(0.1))
            
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    VStack(spacing: 6) {
                        Image(systemName: tabs[index].0)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(
                                selectedTab == index ? tabs[index].2 : Color(hex: "999999")
                            )
                        
                        Text(tabs[index].1)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(
                                selectedTab == index ? tabs[index].2 : Color(hex: "999999")
                            )
                        
                        if selectedTab == index {
                            Capsule()
                                .fill(tabs[index].2)
                                .frame(width: 28, height: 3)
                                .transition(.scale)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.95),
                        Color.white.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
        }
    }
}
