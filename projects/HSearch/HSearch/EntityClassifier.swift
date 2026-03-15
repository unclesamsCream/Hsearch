//
//  EntityClassifier.swift
//  HSearch
//
//  MVP 版本实体分类器：本地词典 + Apple NLP
//

import Foundation
import NaturalLanguage

/// 实体类型枚举
enum EntityType: String, CaseIterable, Identifiable {
    case location = "地点"
    case brand = "品牌"
    case app = "App"
    case person = "人物"
    case unknown = "未知"
    
    var id: String { rawValue }
    
    /// 对应的系统图标
    var iconName: String {
        switch self {
        case .location: return "mappin.and.ellipse"
        case .brand: return "bag.fill"
        case .app: return "app.fill"
        case .person: return "person.fill"
        case .unknown: return "questionmark.circle"
        }
    }
    
    /// 推荐打开的 App 类型
    var suggestedAppCategory: AppCategory? {
        switch self {
        case .location: return .map
        case .brand: return .shopping
        case .app: return .social
        case .person: return .social
        case .unknown: return nil
        }
    }
}

/// App 分类
enum AppCategory: String, CaseIterable {
    case map = "地图导航"
    case shopping = "购物"
    case social = "社交"
    case video = "视频"
    case search = "搜索"
    
    /// 该分类下的推荐 App ID 列表
    var preferredAppIds: [String] {
        switch self {
        case .map:
            return ["amap", "baidumap", "applemap"] // 高德、百度、苹果地图
        case .shopping:
            return ["taobao", "jd", "pdd", "xiaohongshu"]
        case .social:
            return ["wechat", "weibo", "douyin", "xiaohongshu"]
        case .video:
            return ["douyin", "bilibili", "kuaishou"]
        case .search:
            return ["baidu", "google", "bing"]
        }
    }
}

/// 分类结果
struct ClassificationResult {
    let type: EntityType
    let confidence: Double
    let source: ClassificationSource
    let matchedWord: String?
    
    enum ClassificationSource: String {
        case localDictionary = "本地词典"
        case appleNLP = "Apple NLP"
        case unknown = "未知"
    }
}

/// 实体分类器（MVP 版本）
class EntityClassifier {
    
    // MARK: - 单例
    static let shared = EntityClassifier()
    
    // MARK: - 本地词典
    
    /// 地点词典（POI、城市、地标等）
    private let locationDictionary: Set<String> = [
        // 城市
        "北京", "上海", "广州", "深圳", "杭州", "成都", "武汉", "西安", "南京", "重庆",
        "天津", "苏州", "长沙", "郑州", "东莞", "青岛", "昆明", "宁波", "合肥", "佛山",
        "无锡", "大连", "厦门", "福州", "哈尔滨", "济南", "温州", "南宁", "长春", "泉州",
        "石家庄", "贵阳", "南昌", "金华", "常州", "珠海", "惠州", "嘉兴", "南通", "中山",
        "太原", "徐州", "绍兴", "烟台", "兰州", "台州", "海口", "乌鲁木齐", "呼和浩特", "银川",
        "西宁", "拉萨", "桂林", "三亚", "丽江", "大理", "香格里拉", "张家界", "九寨沟",
        
        // 地标/景点
        "故宫", "天安门", "长城", "颐和园", "天坛", "鸟巢", "水立方", "圆明园", "北海公园",
        "外滩", "东方明珠", "陆家嘴", "南京路", "豫园", "城隍庙", "迪士尼", "欢乐谷",
        "西湖", "灵隐寺", "千岛湖", "乌镇", "西塘", "普陀山", "雁荡山",
        "春熙路", "宽窄巷子", "锦里", "武侯祠", "都江堰", "青城山", "峨眉山", "乐山大佛",
        "黄鹤楼", "东湖", "武汉大学", "户部巷", "昙华林",
        "兵马俑", "大雁塔", "钟楼", "回民街", "华清池", "华山",
        "夫子庙", "中山陵", "明孝陵", "秦淮河", "玄武湖",
        "洪崖洞", "解放碑", "磁器口", "长江索道", "武隆",
        "鼓浪屿", "南普陀寺", "厦门大学", "环岛路", "曾厝垵",
        "五四广场", "栈桥", "崂山", "八大关",
        "岳麓山", "橘子洲", "湖南省博物馆", "太平街",
        "二七广场", "少林寺", "龙门石窟", "云台山",
        
        // 商圈/街道
        "三里屯", "王府井", "西单", "国贸", "望京", "中关村", "五道口", "后海", "南锣鼓巷",
        "新天地", "淮海路", "静安寺", "徐家汇", "五角场", "张江",
        "天河城", "北京路", "上下九", "华强北", "东门",
        "解放碑", "观音桥", "春熙路", "太古里", "IFS",
        
        // 交通枢纽
        "首都机场", "大兴机场", "浦东机场", "虹桥机场", "白云机场", "宝安机场",
        "北京南站", "上海虹桥", "广州南站", "深圳北站", "杭州东站",
        
        // 通用地点词
        "机场", "火车站", "地铁站", "公交站", "酒店", "餐厅", "咖啡馆", "商场", "超市",
        "医院", "学校", "大学", "公园", "图书馆", "博物馆", "电影院", "健身房", "银行",
        "附近", "周边", "这里", "那里", "目的地"
    ]
    
    /// 品牌词典
    private let brandDictionary: Set<String> = [
        // 科技/电子
        "苹果", "Apple", "iPhone", "iPad", "MacBook", "AirPods", "Apple Watch",
        "华为", "HUAWEI", "Mate", "P系列", "nova", "荣耀", "Honor",
        "小米", "Xiaomi", "红米", "Redmi", "米家",
        "三星", "Samsung", "Galaxy",
        "OPPO", "vivo", "一加", "OnePlus", "realme", "iQOO",
        "魅族", "MEIZU", "努比亚", "Nubia", "中兴", "ZTE",
        "联想", "Lenovo", "ThinkPad", "戴尔", "Dell", "惠普", "HP",
        "索尼", "Sony", "PlayStation", "PS5",
        "微软", "Microsoft", "Surface", "Xbox",
        "任天堂", "Nintendo", "Switch",
        "大疆", "DJI", "GoPro",
        
        // 服装/鞋帽
        "耐克", "Nike", "阿迪达斯", "Adidas", "三叶草",
        "优衣库", "UNIQLO", "ZARA", "H&M", "GAP", "MUJI", "无印良品",
        "李宁", "安踏", "特步", "361度", "匹克", "鸿星尔克", "回力", "飞跃",
        "匡威", "Converse", "万斯", "Vans", "新百伦", "New Balance", "彪马", "Puma",
        "北面", "North Face", "哥伦比亚", "Columbia", "始祖鸟", "Arc'teryx",
        "香奈儿", "Chanel", "迪奥", "Dior", "路易威登", "LV", "古驰", "Gucci",
        "普拉达", "Prada", "爱马仕", "Hermès", "巴宝莉", "Burberry",
        
        // 餐饮/食品
        "星巴克", "Starbucks", "瑞幸", "Luckin", "喜茶", "奈雪", "茶颜悦色",
        "麦当劳", "McDonald's", "肯德基", "KFC", "汉堡王", "Burger King",
        "必胜客", "Pizza Hut", "达美乐", "Domino's",
        "海底捞", "西贝", "外婆家", "绿茶", "呷哺呷哺", "凑凑",
        "可口可乐", "Coca-Cola", "百事", "Pepsi", "雪碧", "芬达",
        "农夫山泉", "怡宝", "百岁山", "娃哈哈", "康师傅", "统一",
        "伊利", "蒙牛", "光明", "三元",
        "茅台", "五粮液", "洋河", "泸州老窖", "汾酒", "剑南春",
        
        // 零售/商超
        "沃尔玛", "Walmart", "家乐福", "Carrefour", "麦德龙", "Metro",
        "永辉", "大润发", "华润万家", "物美", "京客隆",
        "盒马", "盒马鲜生", "山姆", "山姆会员店", "Costco", "开市客",
        "7-11", "全家", "FamilyMart", "罗森", "LAWSON", "便利蜂",
        "名创优品", "MINISO", "无印良品", "MUJI",
        
        // 美妆/护肤
        "欧莱雅", "L'Oréal", "雅诗兰黛", "Estée Lauder", "兰蔻", "Lancôme",
        "SK-II", "资生堂", "Shiseido", "倩碧", "Clinique", "科颜氏", "Kiehl's",
        "完美日记", "花西子", "colorkey", "珂拉琪", "橘朵", "Judydoll",
        "丝芙兰", "Sephora", "屈臣氏", "Watsons",
        
        // 汽车
        "特斯拉", "Tesla", "比亚迪", "BYD", "蔚来", "NIO", "小鹏", "XPeng", "理想", "Li Auto",
        "宝马", "BMW", "奔驰", "Benz", "奥迪", "Audi", "保时捷", "Porsche",
        "大众", "Volkswagen", "丰田", "Toyota", "本田", "Honda", "日产", "Nissan",
        "福特", "Ford", "通用", "雪佛兰", "Chevrolet", "别克", "Buick",
        
        // 其他
        "宜家", "IKEA", "无印良品", "MUJI", "迪卡侬", "Decathlon",
        "乐高", "LEGO", "泡泡玛特", "POP MART",
        "顺丰", "京东", "淘宝", "天猫", "拼多多", "美团", "饿了么",
        "滴滴", "高德", "百度", "腾讯", "阿里", "字节", "抖音", "快手"
    ]
    
    /// App 词典
    private let appDictionary: Set<String> = [
        // 社交
        "微信", "WeChat", "QQ", "微博", "Weibo", "小红书", "抖音", "TikTok", "快手",
        "知乎", "豆瓣", "贴吧", "陌陌", "探探", "Soul", "即刻",
        "钉钉", "飞书", "企业微信", "腾讯会议", "Zoom", "Teams",
        
        // 购物
        "淘宝", "天猫", "京东", "拼多多", "唯品会", "苏宁易购", "闲鱼", "转转",
        "美团", "饿了么", "大众点评", "口碑", "携程", "去哪儿", "飞猪",
        "得物", "毒", "nice", "什么值得买",
        
        // 视频/娱乐
        "哔哩哔哩", "B站", "Bilibili", "优酷", "Youku", "爱奇艺", "腾讯视频", "芒果TV",
        "西瓜视频", "火山小视频", "微视",
        "网易云音乐", "QQ音乐", "酷狗", "酷我", "虾米", "Spotify", "Apple Music",
        
        // 出行
        "高德地图", "百度地图", "腾讯地图", "谷歌地图", "Google Maps",
        "滴滴", "滴滴出行", "花小猪", "T3", "曹操出行", "首汽约车",
        "哈啰", "哈啰单车", "青桔", "美团单车", "摩拜",
        "铁路12306", "携程", "飞猪", "去哪儿", "航旅纵横",
        
        // 工具
        "支付宝", "云闪付", "招商银行", "工商银行", "建设银行", "中国银行",
        "WPS", "Office", "石墨文档", "腾讯文档", "飞书文档", "Notion",
        "百度网盘", "阿里云盘", "腾讯微云", "iCloud",
        "迅雷", "百度", "谷歌", "Google", "必应", "Bing", "搜狗",
        
        // 新闻/阅读
        "今日头条", "腾讯新闻", "网易新闻", "新浪新闻", "澎湃新闻", "界面",
        "微信读书", "Kindle", "掌阅", "QQ阅读", "起点", "晋江",
        
        // 游戏
        "王者荣耀", "和平精英", "原神", "崩坏", "明日方舟", "阴阳师",
        "Steam", "App Store", "PlayStation", "Xbox", "Switch"
    ]
    
    /// 歧义词映射（用于消歧）
    private let ambiguousWords: [String: EntityType] = [
        "苹果": .brand,      // 默认理解为品牌
        "小米": .brand,
        "荣耀": .brand,
        "美的": .brand,
        "海信": .brand,
    ]
    
    // MARK: - 初始化
    
    private init() {}
    
    // MARK: - 公共方法
    
    /// 分类输入文本
    func classify(_ input: String) -> ClassificationResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ClassificationResult(type: .unknown, confidence: 0, source: .unknown, matchedWord: nil)
        }
        
        // 1. 先检查歧义词映射
        if let type = ambiguousWords[trimmed] {
            return ClassificationResult(type: type, confidence: 1.0, source: .localDictionary, matchedWord: trimmed)
        }
        
        // 2. 本地词典匹配（完全匹配）
        let normalized = trimmed.lowercased()
        if locationDictionary.contains(trimmed) || locationDictionary.contains(normalized) {
            return ClassificationResult(type: .location, confidence: 1.0, source: .localDictionary, matchedWord: trimmed)
        }
        if brandDictionary.contains(trimmed) || brandDictionary.contains(normalized) {
            return ClassificationResult(type: .brand, confidence: 1.0, source: .localDictionary, matchedWord: trimmed)
        }
        if appDictionary.contains(trimmed) || appDictionary.contains(normalized) {
            return ClassificationResult(type: .app, confidence: 1.0, source: .localDictionary, matchedWord: trimmed)
        }
        
        // 3. 包含匹配（输入包含词典中的词）
        for word in locationDictionary {
            if trimmed.contains(word) || word.contains(trimmed) {
                return ClassificationResult(type: .location, confidence: 0.8, source: .localDictionary, matchedWord: word)
            }
        }
        for word in brandDictionary {
            if trimmed.contains(word) || word.contains(trimmed) {
                return ClassificationResult(type: .brand, confidence: 0.8, source: .localDictionary, matchedWord: word)
            }
        }
        for word in appDictionary {
            if trimmed.contains(word) || word.contains(trimmed) {
                return ClassificationResult(type: .app, confidence: 0.8, source: .localDictionary, matchedWord: word)
            }
        }
        
        // 4. Apple NLP 识别
        if let nlpResult = classifyWithNLP(trimmed) {
            return nlpResult
        }
        
        // 5. 未知
        return ClassificationResult(type: .unknown, confidence: 0, source: .unknown, matchedWord: nil)
    }
    
    /// 批量分类（用于推荐排序）
    func classifyBatch(_ inputs: [String]) -> [ClassificationResult] {
        return inputs.map { classify($0) }
    }
    
    /// 根据分类结果获取推荐的 App 列表
    func getSuggestedApps(for result: ClassificationResult, from availableApps: [AppItem]) -> [AppItem] {
        guard let category = result.type.suggestedAppCategory else {
            return availableApps // 返回全部，按默认排序
        }
        
        // 按分类优先级排序
        let preferredIds = category.preferredAppIds
        return availableApps.sorted { app1, app2 in
            let index1 = preferredIds.firstIndex(of: app1.id) ?? Int.max
            let index2 = preferredIds.firstIndex(of: app2.id) ?? Int.max
            return index1 < index2
        }
    }
    
    // MARK: - 私有方法
    
    /// 使用 Apple Natural Language 框架识别
    private func classifyWithNLP(_ text: String) -> ClassificationResult? {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        // 设置中文语言
        tagger.setLanguage(.simplifiedChinese, range: text.startIndex..<text.endIndex)
        
        let range = text.startIndex..<text.endIndex
        var detectedType: EntityType?
        var confidence: Double = 0.6
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType) { tag, tagRange in
            guard let tag = tag else { return true }
            
            switch tag {
            case .placeName:
                detectedType = .location
                confidence = 0.7
                return false // 找到即停止
            case .organizationName:
                detectedType = .brand
                confidence = 0.6
                return false
            case .personalName:
                detectedType = .person
                confidence = 0.7
                return false
            default:
                return true
            }
        }
        
        guard let type = detectedType else { return nil }
        return ClassificationResult(type: type, confidence: confidence, source: .appleNLP, matchedWord: text)
    }
}

// MARK: - 使用示例

/*
// 基础使用
let classifier = EntityClassifier.shared

let result1 = classifier.classify("三里屯")      // location, 本地词典
let result2 = classifier.classify("耐克")         // brand, 本地词典
let result3 = classifier.classify("抖音")         // app, 本地词典
let result4 = classifier.classify("苹果")         // brand, 歧义词映射

// 获取推荐 App
let suggestedApps = classifier.getSuggestedApps(for: result1, from: savedApps)
// 结果会优先返回地图类 App
*/

// MARK: - 测试数据
extension EntityClassifier {
    /// 获取测试用例
    static var testCases: [(input: String, expected: EntityType)] {
        [
            ("三里屯", .location),
            ("故宫", .location),
            ("上海", .location),
            ("耐克", .brand),
            ("苹果", .brand),
            ("星巴克", .brand),
            ("淘宝", .app),
            ("微信", .app),
            ("抖音", .app),
        ]
    }
}
