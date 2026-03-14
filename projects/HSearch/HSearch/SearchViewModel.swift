//
//  SearchViewModel.swift
//  HSearch
//

import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var savedApps: [AppItem] = []
    @Published var suggestedApps: [AppItem] = []
    @Published var showAddAppSheet: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] text in self?.updateSuggestions(for: text) }
            .store(in: &cancellables)
        loadDefaultApps()
    }
    
    private func loadDefaultApps() {
        savedApps = [
            AppItem(id: "taobao", name: "淘宝", iconName: "bag.fill", color: .orange, urlScheme: "taobao://", searchUrlTemplate: "taobao://s.taobao.com/search?q={query}"),
            AppItem(id: "jd", name: "京东", iconName: "cart.fill", color: .red, urlScheme: "openapp.jdmobile://", searchUrlTemplate: nil),
            AppItem(id: "xiaohongshu", name: "小红书", iconName: "book.fill", color: .red, urlScheme: "xhsdiscover://", searchUrlTemplate: nil),
            AppItem(id: "douyin", name: "抖音", iconName: "play.circle.fill", color: .black, urlScheme: "snssdk1128://", searchUrlTemplate: nil),
            AppItem(id: "wechat", name: "微信", iconName: "message.fill", color: .green, urlScheme: "weixin://", searchUrlTemplate: nil),
            AppItem(id: "bilibili", name: "哔哩哔哩", iconName: "tv.fill", color: .pink, urlScheme: "bilibili://", searchUrlTemplate: "bilibili://search?keyword={query}"),
            AppItem(id: "zhihu", name: "知乎", iconName: "questionmark.circle.fill", color: .blue, urlScheme: "zhihu://", searchUrlTemplate: "zhihu://search?q={query}"),
            AppItem(id: "weibo", name: "微博", iconName: "eye.fill", color: .orange, urlScheme: "sinaweibo://", searchUrlTemplate: nil)
        ]
    }
    
    private func updateSuggestions(for text: String) {
        guard !text.isEmpty else { suggestedApps = []; return }
        suggestedApps = savedApps.sorted { relevanceScore(for: $0, query: text) > relevanceScore(for: $1, query: text) }
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
}

struct AppItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let iconName: String
    let colorName: String
    let urlScheme: String
    let searchUrlTemplate: String?
    
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
