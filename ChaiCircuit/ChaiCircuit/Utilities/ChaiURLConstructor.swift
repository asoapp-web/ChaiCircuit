import Foundation

// MARK: - Chai URL Constructor
// Формирование URL с параметрами AppFlyer для Keitaro (БЕЗ geo и device)
struct ChaiURLConstructor {
    
    private static let chaiBaseURL = "https://networking-guide.com/Z3CX5tKl"
    
    /// Формирует финальный URL с параметрами для Keitaro
    static func chaiBuildURL(
        chaiAppsFlyerUID: String,
        chaiConversionData: [AnyHashable: Any] = [:]
    ) -> String {
        guard var chaiComponents = URLComponents(string: chaiBaseURL) else {
            return chaiBaseURL
        }
        
        var chaiQueryItems: [URLQueryItem] = []
        
        // === Параметры по шаблону Keitaro ===
        
        // Google Ads параметры
        let chaiGadid = chaiExtractValue(from: chaiConversionData, chaiKeys: ["gadid", "af_gadid", "adgroup_id"])
        
        chaiQueryItems.append(URLQueryItem(name: "gadid", value: chaiGadid))
        
        // AppsFlyer ID
        chaiQueryItems.append(URLQueryItem(name: "appsflyerId", value: chaiAppsFlyerUID))
        
        // Campaign параметры
        let chaiAfAdId = chaiExtractValue(from: chaiConversionData, chaiKeys: ["af_ad_id", "ad_id", "af_ad"])
        let chaiCampaignId = chaiExtractValue(from: chaiConversionData, chaiKeys: ["campaign_id", "af_campaign_id"])
        let chaiSourceAppId = chaiExtractValue(from: chaiConversionData, chaiKeys: ["source_app_id", "af_source_app_id"])
        let chaiCampaign = chaiExtractValue(from: chaiConversionData, chaiKeys: ["campaign", "c", "af_c"])
        let chaiAfAd = chaiExtractValue(from: chaiConversionData, chaiKeys: ["af_ad", "ad"])
        let chaiAfAdset = chaiExtractValue(from: chaiConversionData, chaiKeys: ["af_adset", "adset"])
        let chaiAfAdsetId = chaiExtractValue(from: chaiConversionData, chaiKeys: ["af_adset_id", "adset_id"])
        let chaiNetwork = chaiExtractValue(from: chaiConversionData, chaiKeys: ["network", "af_network", "media_source", "pid"])
        
        chaiQueryItems.append(URLQueryItem(name: "af_ad_id", value: chaiAfAdId))
        chaiQueryItems.append(URLQueryItem(name: "campaign_id", value: chaiCampaignId))
        chaiQueryItems.append(URLQueryItem(name: "source_app_id", value: chaiSourceAppId))
        chaiQueryItems.append(URLQueryItem(name: "campaign", value: chaiCampaign))
        chaiQueryItems.append(URLQueryItem(name: "af_ad", value: chaiAfAd))
        chaiQueryItems.append(URLQueryItem(name: "af_adset", value: chaiAfAdset))
        chaiQueryItems.append(URLQueryItem(name: "af_adset_id", value: chaiAfAdsetId))
        chaiQueryItems.append(URLQueryItem(name: "network", value: chaiNetwork))
        
        chaiComponents.queryItems = chaiQueryItems
        
        guard let chaiFinalURL = chaiComponents.url?.absoluteString else {
            return chaiBaseURL
        }
        
        print("🔗 [ChaiURLConstructor] Built URL with \(chaiQueryItems.count) parameters")
        return chaiFinalURL
    }
    
    // MARK: - Private Helpers
    
    /// Извлекает значение из conversion data по списку возможных ключей
    private static func chaiExtractValue(from chaiData: [AnyHashable: Any], chaiKeys: [String]) -> String {
        for chaiKey in chaiKeys {
            if let chaiValue = chaiData[chaiKey] {
                let chaiStringValue = String(describing: chaiValue)
                if !chaiStringValue.isEmpty && chaiStringValue != "null" && chaiStringValue != "<null>" {
                    return chaiStringValue
                }
            }
        }
        return ""
    }
}
