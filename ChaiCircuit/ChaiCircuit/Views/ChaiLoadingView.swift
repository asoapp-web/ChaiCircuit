import SwiftUI

// MARK: - Chai Loading View
struct ChaiLoadingView: View {
    var body: some View {
        ZStack {
            // CircuitLoadingBG image as background
            Image("CircuitLoadingBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}
