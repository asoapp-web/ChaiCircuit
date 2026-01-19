import SwiftUI
@preconcurrency import WebKit

// MARK: - Chai Display View (WebView Screen)
struct ChaiDisplayView: View {
    @StateObject private var chaiFlowController = ChaiFlowController.shared
    
    var body: some View {
        ZStack {
            // Black background fills entire screen including Safe Area
            Color.black
                .ignoresSafeArea()
            
            // WebView with custom safe area handling
            VStack(spacing: 0) {
                ChaiWebView(
                    chaiUrl: chaiFlowController.chaiCachedEndpoint ?? "",
                    chaiOnURLUpdate: { chaiNewURL in
                        chaiFlowController.chaiUpdateURL(chaiNewURL)
                    }
                )
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

// MARK: - Chai WebView
struct ChaiWebView: UIViewRepresentable {
    let chaiUrl: String
    let chaiOnURLUpdate: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        // Create configuration
        let chaiConfig = WKWebViewConfiguration()
        let chaiPreferences = WKWebpagePreferences()
        chaiPreferences.allowsContentJavaScript = true
        chaiConfig.defaultWebpagePreferences = chaiPreferences
        
        // Media playback settings
        chaiConfig.allowsInlineMediaPlayback = true
        chaiConfig.mediaTypesRequiringUserActionForPlayback = []
        chaiConfig.allowsAirPlayForMediaPlayback = true
        chaiConfig.allowsPictureInPictureMediaPlayback = true
        
        // Website data store for cookies
        chaiConfig.websiteDataStore = WKWebsiteDataStore.default()
        
        // Create WebView
        let chaiWebView = WKWebView(frame: .zero, configuration: chaiConfig)
        chaiWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        chaiWebView.scrollView.backgroundColor = .black
        chaiWebView.backgroundColor = .black
        chaiWebView.navigationDelegate = context.coordinator
        chaiWebView.uiDelegate = context.coordinator
        
        // Additional settings
        chaiWebView.allowsBackForwardNavigationGestures = true
        chaiWebView.scrollView.keyboardDismissMode = .interactive
        chaiWebView.allowsLinkPreview = false
        
        // Add pull-to-refresh
        let chaiRefreshControl = UIRefreshControl()
        chaiRefreshControl.tintColor = UIColor.white
        chaiRefreshControl.addTarget(
            context.coordinator,
            action: #selector(ChaiCoordinator.chaiHandleRefresh(_:)),
            for: .valueChanged
        )
        chaiWebView.scrollView.refreshControl = chaiRefreshControl
        chaiWebView.scrollView.bounces = true
        
        // Store reference in coordinator
        context.coordinator.chaiRefreshControl = chaiRefreshControl
        
        // Load saved cookies
        if let chaiCookieData = UserDefaults.standard.array(forKey: "chai_saved_cookies_v1") as? [Data] {
            for chaiCookieDataItem in chaiCookieData {
                if let chaiCookie = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(chaiCookieDataItem) as? HTTPCookie {
                    WKWebsiteDataStore.default().httpCookieStore.setCookie(chaiCookie)
                }
            }
        }
        
        // Load URL
        if !chaiUrl.isEmpty, let chaiWebURL = URL(string: chaiUrl) {
            let chaiRequest = URLRequest(url: chaiWebURL)
            chaiWebView.load(chaiRequest)
        }
        
        return chaiWebView
    }
    
    func updateUIView(_ chaiUiView: WKWebView, context: Context) {
        // Check if URL changed and reload if needed
        if !chaiUrl.isEmpty {
            let chaiCurrentURLString = chaiUiView.url?.absoluteString ?? ""
            if chaiCurrentURLString != chaiUrl {
                print("🔄 [ChaiWebView] URL changed from '\(chaiCurrentURLString)' to '\(chaiUrl)' - reloading")
                if let chaiWebURL = URL(string: chaiUrl) {
                    let chaiRequest = URLRequest(url: chaiWebURL)
                    chaiUiView.load(chaiRequest)
                }
            }
        }
    }
    
    func makeCoordinator() -> ChaiCoordinator {
        ChaiCoordinator(self)
    }
    
    // MARK: - Coordinator
    class ChaiCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let chaiParent: ChaiWebView
        private weak var chaiWebView: WKWebView?
        weak var chaiRefreshControl: UIRefreshControl?
        
        init(_ chaiParent: ChaiWebView) {
            self.chaiParent = chaiParent
            super.init()
        }
        
        @objc func chaiHandleRefresh(_ chaiRefreshControl: UIRefreshControl) {
            chaiWebView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                chaiRefreshControl.endRefreshing()
            }
        }
        
        // MARK: - Navigation Delegate
        func webView(_ chaiWebView: WKWebView, didStartProvisionalNavigation chaiNavigation: WKNavigation!) {
            self.chaiWebView = chaiWebView
        }
        
        func webView(_ chaiWebView: WKWebView, didFinish chaiNavigation: WKNavigation!) {
            // Stop refresh control
            chaiRefreshControl?.endRefreshing()
            
            // Update URL if changed
            if let chaiCurrentURL = chaiWebView.url?.absoluteString {
                chaiParent.chaiOnURLUpdate(chaiCurrentURL)
            }
            
            // Save cookies
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { chaiCookies in
                let chaiCookieData = chaiCookies.compactMap {
                    try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false)
                }
                UserDefaults.standard.set(chaiCookieData, forKey: "chai_saved_cookies_v1")
            }
        }
        
        func webView(_ chaiWebView: WKWebView, didFail chaiNavigation: WKNavigation!, withError chaiError: Error) {
            // Stop refresh control
            chaiRefreshControl?.endRefreshing()
        }
        
        func webView(_ chaiWebView: WKWebView, decidePolicyFor chaiNavigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let chaiUrl = chaiNavigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let chaiScheme = chaiUrl.scheme?.lowercased() ?? ""
            
            // Handle non-web schemes (tel:, mailto:, etc.)
            if chaiScheme != "http" && chaiScheme != "https" {
                print("🔗 [ChaiWebView] Opening external URL: \(chaiUrl)")
                UIApplication.shared.open(chaiUrl)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        // MARK: - UI Delegate
        func webView(_ chaiWebView: WKWebView, createWebViewWith chaiConfiguration: WKWebViewConfiguration, for chaiNavigationAction: WKNavigationAction, windowFeatures chaiWindowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows - load in same webview
            if let chaiUrl = chaiNavigationAction.request.url {
                chaiWebView.load(URLRequest(url: chaiUrl))
            }
            return nil
        }
        
        func webView(_ chaiWebView: WKWebView, runJavaScriptAlertPanelWithMessage chaiMessage: String, initiatedByFrame chaiFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let chaiAlert = UIAlertController(title: nil, message: chaiMessage, preferredStyle: .alert)
            chaiAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let chaiWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let chaiWindow = chaiWindowScene.windows.first {
                chaiWindow.rootViewController?.present(chaiAlert, animated: true)
            }
        }
        
        func webView(_ chaiWebView: WKWebView, runJavaScriptConfirmPanelWithMessage chaiMessage: String, initiatedByFrame chaiFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let chaiAlert = UIAlertController(title: nil, message: chaiMessage, preferredStyle: .alert)
            chaiAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            chaiAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            
            if let chaiWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let chaiWindow = chaiWindowScene.windows.first {
                chaiWindow.rootViewController?.present(chaiAlert, animated: true)
            }
        }
    }
}
