import SwiftUI

@main
struct ChaiCircuitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ChaiAppContentView()
        }
    }
}

// MARK: - Chai App Content View
struct ChaiAppContentView: View {
    @ObservedObject private var chaiFlowController = ChaiFlowController.shared
    
    var body: some View {
        ZStack {
            // Основной контент всегда рендерится под загрузкой
            // Это предотвращает "пустой экран" при переключении
            chaiContentView
                .opacity(chaiFlowController.chaiIsLoading ? 0 : 1)
            
            // Экран загрузки поверх контента
            if chaiFlowController.chaiIsLoading {
                ChaiLoadingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: chaiFlowController.chaiIsLoading)
    }
    
    @ViewBuilder
    private var chaiContentView: some View {
        switch chaiFlowController.chaiDisplayMode {
        case .preparing:
            // Показываем ContentView как дефолт
            ContentView()
        case .original:
            // Показываем оригинальное приложение
            ContentView()
        case .webContent:
            // Показываем WebView
            ChaiDisplayView()
        }
    }
}
