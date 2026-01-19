import UIKit
import AppsFlyerLib
import AppTrackingTransparency

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure AppsFlyer
        chaiConfigureAppsFlyer()
        
        // Start AppsFlyer when app becomes active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(chaiStartAppsFlyer),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        return true
    }
    
    private func chaiConfigureAppsFlyer() {
        // Set AppsFlyer Dev Key
        AppsFlyerLib.shared().appsFlyerDevKey = "CaXxNJqgn8whbW2zwEZXrL"
        
        // Set Apple App ID
        AppsFlyerLib.shared().appleAppID = "6756029932"
        
        // Set delegate
        AppsFlyerLib.shared().delegate = self
        
        // ВАЖНО: Ждём ATT перед стартом для получения полного AppsFlyer ID
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        print("📱 [AppDelegate] AppsFlyer configured")
    }
    
    private static var chaiWasStarted = false
    
    @objc private func chaiStartAppsFlyer() {
        // Запрашиваем ATT ПЕРЕД стартом AppsFlyer
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] chaiStatus in
                print("📱 [AppDelegate] Tracking authorization: \(chaiStatus.rawValue)")
                self?.chaiLaunchAppsFlyer()
            }
        } else {
            chaiLaunchAppsFlyer()
        }
    }
    
    private func chaiLaunchAppsFlyer() {
        guard !Self.chaiWasStarted else { return }
        Self.chaiWasStarted = true
        
        AppsFlyerLib.shared().start()
        
        let chaiUid = AppsFlyerLib.shared().getAppsFlyerUID()
        print("📱 [AppDelegate] AppsFlyer started, UID: \(chaiUid)")
    }
}

// MARK: - AppsFlyer Delegate
extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("✅ [AppDelegate] AppsFlyer conversion data received")
        
        // Get AppsFlyer UID
        let chaiAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔑 [AppDelegate] AppsFlyer UID: \(chaiAppsFlyerUID), length: \(chaiAppsFlyerUID.count)")
        
        // Update ChaiFlowController with AppsFlyer data
        ChaiFlowController.shared.chaiUpdateAppsFlyerData(
            chaiUid: chaiAppsFlyerUID,
            chaiConversionData: conversionInfo
        )
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ [AppDelegate] AppsFlyer conversion data failed: \(error.localizedDescription)")
        
        // Use default UID if available
        let chaiAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔑 [AppDelegate] AppsFlyer UID (fallback): \(chaiAppsFlyerUID), length: \(chaiAppsFlyerUID.count)")
        
        if !chaiAppsFlyerUID.isEmpty {
            ChaiFlowController.shared.chaiUpdateAppsFlyerData(chaiUid: chaiAppsFlyerUID, chaiConversionData: [:])
        }
    }
}
