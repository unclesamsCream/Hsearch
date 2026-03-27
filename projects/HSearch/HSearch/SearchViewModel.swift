//
//  SearchViewModel.swift
//  HSearch
//

import SwiftUI
import Combine
import UIKit

// MARK: - AppIconService (从 App Store 获取图标)
class AppIconService {
    static let shared = AppIconService()
    private var iconCache: [String: UIImage] = [:]
    private let cacheKey = "appIconCache"
    
    private init() { loadCache() }
    
    func fetchAppIcon(appName: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = iconCache[appName] {
            completion(cachedImage)
            return
        }
        
        let term = appName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? appName
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(term)&entity=software&limit=1") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let result = try? JSONDecoder().decode(AppStoreSearchResult.self, from: data),
                  let firstApp = result.results.first,
                  let artworkUrl = firstApp.artworkUrl100 else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            if let imageUrl = URL(string: artworkUrl.replacingOccurrences(of: "100x100", with: "512x512")) {
                URLSession.shared.dataTask(with: imageUrl) { imageData, _, _ in
                    if let imageData = imageData, let image = UIImage(data: imageData) {
                        self?.iconCache[appName] = image
                        self?.saveCache()
                        DispatchQueue.main.async { completion(image) }
                    } else {
                        DispatchQueue.main.async { completion(nil) }
                    }
                }.resume()
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
    
    func getCachedIcon(for appName: String) -> UIImage? {
        return iconCache[appName]
    }
    
    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let imageDataDict = try? JSONDecoder().decode([String: Data].self, from: data) {
            for (key, imageData) in imageDataDict {
                if let image = UIImage(data: imageData) {
                    iconCache[key] = image
                }
            }
        }
    }
    
    private func saveCache() {
        var imageDataDict: [String: Data] = [:]
        for (key, image) in iconCache {
            if let data = image.pngData() {
                imageDataDict[key] = data
            }
        }
        if let data = try? JSONEncoder().encode(imageDataDict) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    func preloadCommonIcons() {
        let commonApps = ["淘宝", "京东", "小红书", "抖音", "微信", "哔哩哔哩", "高德地图", "百度地图", "知乎", "拼多多"]
        for appName in commonApps {
            fetchAppIcon(appName: appName) { _ in }
        }
    }
}

struct AppStoreSearchResult: Codable {
    let resultCount: Int
    let results: [AppStoreApp]
}

struct AppStoreApp: Codable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let artworkUrl100: String?
}

// MARK: - SearchViewModel
class SearchViewModel: ObservableObject {
    
    // App 图标服务
    private let iconService = AppIconService.shared
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var savedApps: [AppItem] = []
    @Published var suggestedApps: [AppItem] = []
    @Published var showAddAppSheet: Bool = false
    @Published var searchHistory: [String] = []
    
    // 跳转反馈状态
    @Published var isOpeningApp: Bool = false
    @Published var openingAppName: String = ""
    
    // App 图标缓存
    @Published var appIcons: [String: UIImage] = [:]
    
    // 实体分类结果
    @Published var currentClassification: ClassificationResult?
    
    private var cancellables = Set<AnyCancellable>()
    private let historyKey = "searchHistory"
    private let maxHistoryCount = 10
    private let classifier = EntityClassifier.shared
    
    // MARK: - 使用频率相关
    private let usageCountKey = "appUsageCount"  // UserDefaults key for usage frequency
    private var usageCount: [String: Int] = [:]  // App ID -> 使用次数
    
    // 推荐权重配置
    private let classificationWeight: Double = 0.5   // 分类权重 50%
    private let usageWeight: Double = 0.4           // 使用频率权重 40%
    private let keywordWeight: Double = 0.1        // 关键词匹配权重 10%
    
    init() {
        loadSearchHistory()
        loadUsageCount()  // 加载使用频率
        
        #if DEBUG
        // 模拟一些使用频率数据（调试用）
        setupMockUsageData()
        #endif
        
        $searchText
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] text in self?.updateSuggestions(for: text) }
            .store(in: &cancellables)
        loadDefaultApps()
        
        // 预加载常用 App 图标
        iconService.preloadCommonIcons()
        
        // 启动时加载缓存的图标
        loadCachedIcons()
        
        // DEBUG: 预设搜索词用于演示分类器效果
        #if DEBUG
        // 预设搜索历史，方便查看效果
        self.searchHistory = ["手机", "数码", "电脑", "耳机", "相机"]
        #endif
    }
    
    /// 加载缓存的图标
    private func loadCachedIcons() {
        let commonApps = ["淘宝", "京东", "小红书", "抖音", "微信", "哔哩哔哩", "高德地图", "百度地图", "知乎", "拼多多", "微博"]
        for appName in commonApps {
            if let cachedIcon = iconService.getCachedIcon(for: appName) {
                appIcons[appName] = cachedIcon
            }
        }
    }
    
    /// 获取 App 图标
    func getAppIcon(for appName: String, completion: @escaping (UIImage?) -> Void) {
        // 先检查 ViewModel 本地缓存
        if let cachedIcon = appIcons[appName] {
            completion(cachedIcon)
            return
        }
        
        // 检查 Service 缓存
        if let serviceCachedIcon = iconService.getCachedIcon(for: appName) {
            appIcons[appName] = serviceCachedIcon
            completion(serviceCachedIcon)
            return
        }
        
        // 从 App Store 获取
        iconService.fetchAppIcon(appName: appName) { [weak self] image in
            if let image = image {
                self?.appIcons[appName] = image
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 设置模拟使用数据（调试用）
    private func setupMockUsageData() {
        // 模拟用户最常用淘宝，其次是小红书
        let mockData: [String: Int] = [
            "taobao": 50,        // 最常用淘宝
            "xiaohongshu": 30,  // 常用小红书
            "douyin": 20,        // 常用抖音
            "amap": 15,         // 偶尔用高德
            "bilibili": 10,     // 偶尔用B站
            "jd": 5,            // 很少用京东
            "wechat": 3,
            "zhihu": 2,
            "baidumap": 1,
            "weibo": 0
        ]
        
        // 如果没有历史数据，使用模拟数据
        if usageCount.isEmpty {
            usageCount = mockData
            saveUsageCount()
            print("📊 已设置模拟使用频率数据: \(usageCount)")
        }
    }
    
    // MARK: - 使用频率管理
    
    /// 加载使用频率数据
    private func loadUsageCount() {
        if let data = UserDefaults.standard.dictionary(forKey: usageCountKey) as? [String: Int] {
            usageCount = data
            print("📊 已加载使用频率数据: \(usageCount)")
        }
    }
    
    /// 保存使用频率数据
    private func saveUsageCount() {
        UserDefaults.standard.set(usageCount, forKey: usageCountKey)
    }
    
    /// 增加 App 使用次数
    func recordAppUsage(appId: String) {
        usageCount[appId, default: 0] += 1
        saveUsageCount()
        print("📊 App \(appId) 使用次数: \(usageCount[appId] ?? 0)")
    }
    
    /// 获取 App 使用次数
    func getUsageCount(for appId: String) -> Int {
        return usageCount[appId] ?? 0
    }
    
    /// 重置使用频率（用于调试）
    func resetUsageCount() {
        usageCount.removeAll()
        saveUsageCount()
    }
    
    // MARK: - App 管理
    
    private func loadDefaultApps() {
        savedApps = [
            // 地图导航 - 使用更精准的图标
            AppItem(id: "amap", name: "高德地图", iconName: "map.fill", color: .blue, urlScheme: "iosamap://", searchUrlTemplate: "iosamap://path?sourceApplication=HSearch&dlat=&dlon=&dname={query}&dev=0&t=0"),
            AppItem(id: "baidumap", name: "百度地图", iconName: "map.geометрия.fill", color: .green, urlScheme: "baidumap://", searchUrlTemplate: "baidumap://map/search?query={query}"),
            AppItem(id: "applemap", name: "地图", iconName: "map", color: .orange, urlScheme: "http://maps.apple.com/", searchUrlTemplate: "http://maps.apple.com/?q={query}"),
            
            // 购物 - 使用更精准的图标
            AppItem(id: "taobao", name: "淘宝", iconName: "bag", color: .orange, urlScheme: "taobao://", searchUrlTemplate: "taobao://s.taobao.com/search?q={query}"),
            AppItem(id: "jd", name: "京东", iconName: "cart", color: .red, urlScheme: "openapp.jdmobile://", searchUrlTemplate: "openapp.jdmobile://virtual?params={\"des\":\"productList\",\"keyWord\":\"{query}\"}"),
            AppItem(id: "pdd", name: "拼多多", iconName: "bag.badge.plus", color: .red, urlScheme: "pinduoduo://", searchUrlTemplate: nil),
            
            // 社交/内容 - 使用更精准的图标
            AppItem(id: "xiaohongshu", name: "小红书", iconName: "book", color: .red, urlScheme: "xhsdiscover://", searchUrlTemplate: "xhsdiscover://search/result?keyword={query}"),
            AppItem(id: "douyin", name: "抖音", iconName: "play.rectangle.fill", color: .black, urlScheme: "snssdk1128://", searchUrlTemplate: "snssdk1128://search?q={query}"),
            AppItem(id: "wechat", name: "微信", iconName: "message", color: .green, urlScheme: "weixin://", searchUrlTemplate: "weixin://dl/officialaccounts?search={query}"),
            AppItem(id: "bilibili", name: "哔哩哔哩", iconName: "play.tv", color: .pink, urlScheme: "bilibili://", searchUrlTemplate: "bilibili://search?keyword={query}"),
            AppItem(id: "zhihu", name: "知乎", iconName: "questionmark.bubble", color: .blue, urlScheme: "zhihu://", searchUrlTemplate: "zhihu://search?q={query}"),
            AppItem(id: "weibo", name: "微博", iconName: "eye", color: .orange, urlScheme: "sinaweibo://", searchUrlTemplate: "sinaweibo://search?q={query}"),
        ]
    }
    
    // MARK: - App 检测配置
    
    /// 是否显示未安装的 App
    /// DEBUG = true: 显示所有 App（测试用）
    /// RELEASE = false: 只显示已安装的 App
    #if DEBUG
    private let showUninstalledApps = true
    #else
    private let showUninstalledApps = false
    #endif
    
    // MARK: - 智能推荐算法（优化版：分类 + 使用频率 + 关键词）
    
    private func updateSuggestions(for text: String) {
        guard !text.isEmpty else { 
            suggestedApps = []
            currentClassification = nil
            return
        }
        
        // 1. 进行实体分类
        let classification = classifier.classify(text)
        currentClassification = classification
        
        // 2. 获取分类推荐的 App
        var classifiedApps = classifier.getSuggestedApps(for: classification, from: savedApps)
        
        // 3. 如果没有分类结果，使用关键词匹配
        if classification.type == .unknown {
            classifiedApps = savedApps.sorted { relevanceScore(for: $0, query: text) > relevanceScore(for: $1, query: text) }
        }
        
        // 4. 过滤未安装的 App（Release 模式）
        if !showUninstalledApps {
            classifiedApps = classifiedApps.filter { $0.isInstalled }
        }
        
        // 5. 综合排序：分类 + 使用频率 + 关键词
        suggestedApps = rankedApps(apps: classifiedApps, query: text, classification: classification)
    }
    
    /// 综合排序算法
    /// 权重: 分类匹配 50% + 使用频率 40% + 关键词匹配 10%
    private func rankedApps(apps: [AppItem], query: String, classification: ClassificationResult) -> [AppItem] {
        // 找出最高使用次数作为基准
        let maxUsage = max(usageCount.values.max() ?? 1, 1)
        
        return apps.sorted { app1, app2 in
            // 分类匹配分数 (0-1)
            let classificationScore1 = classificationMatchScore(for: app1, classification: classification)
            let classificationScore2 = classificationMatchScore(for: app2, classification: classification)
            
            // 使用频率分数 (0-1)
            let usageCount1 = usageCount[app1.id] ?? 0
            let usageCount2 = usageCount[app2.id] ?? 0
            let usageScore1 = Double(usageCount1) / Double(maxUsage)
            let usageScore2 = Double(usageCount2) / Double(maxUsage)
            
            // 关键词匹配分数 (0-1)
            let keywordScore1 = keywordMatchScore(for: app1, query: query)
            let keywordScore2 = keywordMatchScore(for: app2, query: query)
            
            // 综合分数
            let totalScore1 = classificationScore1 * classificationWeight + 
                              usageScore1 * usageWeight + 
                              keywordScore1 * keywordWeight
            let totalScore2 = classificationScore2 * classificationWeight + 
                              usageScore2 * classificationWeight + 
                              keywordScore2 * keywordWeight
            
            #if DEBUG
            print("📊 \(app1.name): 分类=\(classificationScore1) 使用=\(usageScore1) 关键词=\(keywordScore1) 总分=\(totalScore1)")
            print("📊 \(app2.name): 分类=\(classificationScore2) 使用=\(usageScore2) 关键词=\(keywordScore2) 总分=\(totalScore2)")
            #endif
            
            return totalScore1 > totalScore2
        }
    }
    
    /// 分类匹配分数
    private func classificationMatchScore(for app: AppItem, classification: ClassificationResult) -> Double {
        guard let category = classification.type.suggestedAppCategory else {
            return 0.3 // 未知类型给基础分
        }
        
        // 检查 App 是否属于推荐的分类
        if category.preferredAppIds.contains(app.id) {
            return 1.0 * classification.confidence
        }
        return 0.3
    }
    
    /// 关键词匹配分数
    private func keywordMatchScore(for app: AppItem, query: String) -> Double {
        let lowerQuery = query.lowercased()
        let appName = app.name.lowercased()
        
        // App 名称直接包含查询词
        if appName.contains(lowerQuery) {
            return 1.0
        }
        
        // 关键词匹配
        var score = 0.0
        switch lowerQuery {
        case let q where q.contains("买") || q.contains("商品") || q.contains("价格") || q.contains("购物"):
            if ["淘宝", "京东", "拼多多"].contains(app.name) { score += 0.8 }
        case let q where q.contains("视频") || q.contains("看") || q.contains("刷") || q.contains("短视频"):
            if ["抖音", "哔哩哔哩"].contains(app.name) { score += 0.8 }
        case let q where q.contains("知识") || q.contains("问题") || q.contains("怎么") || q.contains("攻略"):
            if ["知乎", "小红书"].contains(app.name) { score += 0.8 }
        case let q where q.contains("社交") || q.contains("聊天") || q.contains("微信"):
            if ["微信", "微博"].contains(app.name) { score += 0.8 }
        case let q where q.contains("地图") || q.contains("导航") || q.contains("路线"):
            if ["高德地图", "百度地图", "地图"].contains(app.name) { score += 0.8 }
        case let q where q.contains("点外卖") || q.contains("吃饭") || q.contains("餐厅"):
            if ["美团", "饿了么"].contains(app.name) { score += 0.8 }
        default:
            // 检查 App 名称是否包含查询词的任何部分
            for word in lowerQuery.split(separator: " ") {
                if appName.contains(String(word)) {
                    score += 0.5
                }
            }
        }
        
        return min(score, 1.0)
    }
    
    private func relevanceScore(for app: AppItem, query: String) -> Double {
        var score = 0.0
        let lowerQuery = query.lowercased()
        switch lowerQuery {
        case let q where q.contains("买") || q.contains("商品") || q.contains("价格"):
            if ["淘宝", "京东"].contains(app.name) { score += 10 }
        case let q where q.contains("视频") || q.contains("看") || q.contains("刷"):
            if ["抖音", "哔哩哔哩"].contains(app.name) { score += 10 }
        case let q where q.contains("知识") || q.contains("问题") || q.contains("怎么"):
            if ["知乎", "小红书"].contains(app.name) { score += 10 }
        case let q where q.contains("社交") || q.contains("聊天"):
            if ["微信", "微博"].contains(app.name) { score += 10 }
        default: break
        }
        score += Double.random(in: 0...5)
        return score
    }
    
    func openApp(_ app: AppItem) {
        // 显示跳转反馈
        isOpeningApp = true
        openingAppName = app.name
        
        // 记录使用频率
        recordAppUsage(appId: app.id)
        
        // 保存搜索历史
        if !searchText.isEmpty {
            addToHistory(searchText)
        }
        
        // 延迟隐藏反馈，给用户一个视觉反馈
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isOpeningApp = false
        }
        
        guard let url = app.searchURL(for: searchText) else {
            if let appURL = URL(string: app.urlScheme), UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL)
            }
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func addApp(_ app: AppItem) { savedApps.append(app) }
    func deleteApps(at offsets: IndexSet) { savedApps.remove(atOffsets: offsets) }
    
    // MARK: - Search History
    
    func addToHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 移除重复项
        searchHistory.removeAll { $0 == trimmed }
        // 添加到开头
        searchHistory.insert(trimmed, at: 0)
        // 限制数量
        if searchHistory.count > maxHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxHistoryCount))
        }
        // 保存
        saveSearchHistory()
    }
    
    func removeFromHistory(_ query: String) {
        searchHistory.removeAll { $0 == query }
        saveSearchHistory()
    }
    
    func clearHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }
    
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: historyKey)
    }
    
    private func loadSearchHistory() {
        if let history = UserDefaults.standard.stringArray(forKey: historyKey) {
            searchHistory = history
        }
    }
}

struct AppItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let iconName: String
    let colorName: String
    let urlScheme: String
    let searchUrlTemplate: String?
    
    /// 检测 App 是否已安装
    var isInstalled: Bool {
        guard let url = URL(string: urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    var color: Color {
        switch colorName {
        case "orange": return .orange
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "pink": return .pink
        case "purple": return .purple
        case "yellow": return .yellow
        case "black": return .primary
        default: return .blue
        }
    }
    
    init(id: String, name: String, iconName: String, color: Color, urlScheme: String, searchUrlTemplate: String?) {
        self.id = id; self.name = name; self.iconName = iconName; self.urlScheme = urlScheme; self.searchUrlTemplate = searchUrlTemplate
        switch color {
        case .orange: self.colorName = "orange"
        case .red: self.colorName = "red"
        case .green: self.colorName = "green"
        case .blue: self.colorName = "blue"
        case .pink: self.colorName = "pink"
        case .purple: self.colorName = "purple"
        case .yellow: self.colorName = "yellow"
        default: self.colorName = "blue"
        }
    }
    
    func searchURL(for query: String) -> URL? {
        guard !query.isEmpty else { return URL(string: urlScheme) }
        guard let template = searchUrlTemplate else { return URL(string: urlScheme) }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: template.replacingOccurrences(of: "{query}", with: encodedQuery))
    }
}
