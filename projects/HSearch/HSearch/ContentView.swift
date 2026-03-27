//
//  ContentView.swift
//  HSearch
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        SearchContentView()
            .environmentObject(viewModel)
    }
}

// MARK: - 拟物化主题色（增强版）
struct NeumorphicTheme {
    // 更柔和的浅灰背景
    static let background = Color(red: 0.93, green: 0.93, blue: 0.95)
    static let cardBackground = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    // 更强的阴影对比 - 关键！
    static let shadowDark = Color.black.opacity(0.25)
    static let shadowLight = Color.white.opacity(0.85)
    
    // 品牌色 - 柔和的蓝
    static let accent = Color(red: 0.3, green: 0.5, blue: 0.95)
    
    // 辅助色
    static let secondaryAccent = Color(red: 0.55, green: 0.58, blue: 0.62)
}

// MARK: - 拟物化凸起效果（按钮、图标）
struct NeumorphicElevated: ViewModifier {
    var isPressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .shadow(color: NeumorphicTheme.shadowDark, radius: isPressed ? 2 : 6, x: 0, y: isPressed ? 1 : 4)
            .shadow(color: NeumorphicTheme.shadowLight, radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : -2)
    }
}

// MARK: - 拟物化凹陷效果（输入框、容器）
struct NeumorphicInset: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: NeumorphicTheme.shadowDark, radius: 4, x: 0, y: 2)
            .shadow(color: NeumorphicTheme.shadowLight, radius: 4, x: 0, y: -2)
    }
}

extension View {
    func neumorphicElevated(_ isPressed: Bool = false) -> some View {
        modifier(NeumorphicElevated(isPressed: isPressed))
    }
    
    func neumorphicInset() -> some View {
        modifier(NeumorphicInset())
    }
}

struct SearchContentView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // 拟物化浅灰背景
            NeumorphicTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部工具栏 - 无 logo，更简洁
                HStack {
                    Spacer()
                    
                    Button(action: { viewModel.showAddAppSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(NeumorphicTheme.secondaryAccent)
                            .shadow(color: NeumorphicTheme.shadowDark.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // 主搜索区域 - 下移
                Spacer()
                
                VStack(spacing: 20) {
                    // 搜索栏 - 带拟物化效果，下移更多
                    NeumorphicSearchBar(
                        text: $viewModel.searchText,
                        isFocused: $isSearchFocused
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 40)  // 增加顶部间距
                    
                    // 搜索提示文字
                    if viewModel.searchText.isEmpty {
                        Text("输入关键词，智能推荐 App")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .transition(.opacity)
                    }
                }
                .padding(.top, 60)  // 整体下移
                
                Spacer()
                
                // 搜索历史（仅在搜索栏为空且有历史记录时显示）
                if viewModel.searchText.isEmpty && !viewModel.searchHistory.isEmpty {
                    SearchHistoryView(
                        history: viewModel.searchHistory,
                        onSelect: { query in
                            viewModel.searchText = query
                        },
                        onDelete: { query in
                            viewModel.removeFromHistory(query)
                        },
                        onClear: {
                            viewModel.clearHistory()
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // 搜索推荐（有输入时显示）
                if !viewModel.searchText.isEmpty {
                    VStack(spacing: 0) {
                        Spacer(minLength: 30)  // 增加顶部间距
                        SuggestedAppsView(
                            apps: viewModel.suggestedApps,
                            searchText: viewModel.searchText,
                            onAppTap: { app in
                                viewModel.openApp(app)
                            }
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: 40)
            }
            
            // 跳转反馈 Toast
            if viewModel.isOpeningApp {
                VStack {
                    Spacer()
                    
                    AppOpenFeedback(appName: viewModel.openingAppName)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 120)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isOpeningApp)
            }
        }
        .sheet(isPresented: $viewModel.showAddAppSheet) {
            AddAppView { app in viewModel.addApp(app) }
        }
    }
}

// MARK: - 拟物化搜索栏（增强凹陷效果）
struct NeumorphicSearchBar: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 10) {
            // Logo 按钮 - 更小更精致，凸起效果
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [NeumorphicTheme.accent, NeumorphicTheme.accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: NeumorphicTheme.accent.opacity(0.6), radius: 6, x: 0, y: 3)
            .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: -1)
            
            TextField("搜索关键词...", text: $text)
                .font(.system(size: 17))
                .focused($isFocused)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(NeumorphicTheme.secondaryAccent)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                // 更强的凹陷效果
                .fill(NeumorphicTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .mask(RoundedRectangle(cornerRadius: 18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isFocused ? NeumorphicTheme.accent.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .shadow(color: Color.white.opacity(0.9), radius: 6, x: 0, y: -3)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - 内阴影辅助视图
struct InnerShadowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(color)
                    .blur(radius: radius)
                    .offset(x: x, y: y)
                    .mask(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.black))
            )
    }
}

extension View {
    func innerShadow(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        modifier(InnerShadowModifier(color: color, radius: radius, x: x, y: y))
    }
}

// MARK: - 搜索历史视图
struct SearchHistoryView: View {
    let history: [String]
    let onSelect: (String) -> Void
    let onDelete: (String) -> Void
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近搜索")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onClear) {
                    Text("清除")
                        .font(.caption)
                        .foregroundColor(NeumorphicTheme.accent)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(history, id: \.self) { query in
                        HistoryTag(query: query, onSelect: {
                            onSelect(query)
                        }, onDelete: {
                            onDelete(query)
                        })
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        // 拟物化卡片背景
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(NeumorphicTheme.cardBackground)
                .shadow(color: NeumorphicTheme.shadowDark, radius: 8, x: 0, y: -2)
        )
    }
}

struct HistoryTag: View {
    let query: String
    let onSelect: () -> Void
    let onDelete: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 12))
                    .foregroundColor(NeumorphicTheme.secondaryAccent)
                
                Text(query)
                    .font(.system(size: 15))
                    .lineLimit(1)
                
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(NeumorphicTheme.secondaryAccent)
                        .frame(width: 16, height: 16)
                        .background(NeumorphicTheme.background)
                        .clipShape(Circle())
                        .shadow(color: NeumorphicTheme.shadowDark.opacity(0.2), radius: 1, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            // 凹陷效果标签
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(NeumorphicTheme.background)
                    .shadow(color: NeumorphicTheme.shadowDark.opacity(0.15), radius: 2, x: 0, y: 2)
                    .shadow(color: NeumorphicTheme.shadowLight, radius: 2, x: 0, y: -1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 搜索推荐视图
struct SuggestedAppsView: View {
    let apps: [AppItem]
    let searchText: String
    let onAppTap: (AppItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 头部提示
            HStack {
                Image(systemName: "arrow.up.forward.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(NeumorphicTheme.accent)
                Text("点击直接跳转搜索")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // App 列表 - 拟物化卡片
            VStack(spacing: 0) {
                ForEach(apps.prefix(6)) { app in
                    AppListRow(app: app) {
                        onAppTap(app)
                    }
                    
                    if app.id != apps.prefix(6).last?.id {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(NeumorphicTheme.cardBackground)
                    .shadow(color: NeumorphicTheme.shadowDark, radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 16)
            
            Spacer(minLength: 20)
        }
        .background(NeumorphicTheme.background)
    }
}

// MARK: - App 列表行
struct AppListRow: View {
    let app: AppItem
    let action: () -> Void
    @State private var appIcon: UIImage?
    @EnvironmentObject var viewModel: SearchViewModel
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // App 图标 - 优先使用真实图标
                Group {
                    if let icon = appIcon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(app.color.gradient)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: app.iconName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                // App 名称
                HStack(spacing: 8) {
                    Text(app.name)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    // 未安装标签（仅 DEBUG 模式显示）
                    #if DEBUG
                    if !app.isInstalled {
                        Text("未安装")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                    #endif
                }
                
                Spacer()
                
                // 跳转箭头
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadAppIcon()
        }
    }
    
    private func loadAppIcon() {
        // 先检查 ViewModel 缓存
        if let cachedIcon = viewModel.appIcons[app.name] {
            appIcon = cachedIcon
            return
        }
        
        // 从 App Store 获取
        viewModel.getAppIcon(for: app.name) { image in
            if let image = image {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.appIcon = image
                }
            }
        }
    }
}

struct SuggestedAppButton: View {
    let app: AppItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // App 图标 - 使用渐变背景使其更醒目
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(app.color.gradient)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: app.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                .shadow(color: app.color.opacity(0.4), radius: 6, x: 0, y: 3)
                
                Text(app.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - App 跳转反馈
struct AppOpenFeedback: View {
    let appName: String
    
    var body: some View {
        HStack(spacing: 12) {
            // 成功图标
            ZStack {
                Circle()
                    .fill(NeumorphicTheme.accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.system(size: 18))
                    .foregroundColor(NeumorphicTheme.accent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("正在打开")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(appName)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 加载指示器
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: NeumorphicTheme.accent))
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(NeumorphicTheme.cardBackground)
                .shadow(color: NeumorphicTheme.shadowDark, radius: 16, x: 0, y: 8)
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - 分类徽章
struct ClassificationBadge: View {
    let classification: ClassificationResult
    
    var body: some View {
        HStack(spacing: 8) {
            // 类型图标和名称
            HStack(spacing: 4) {
                Image(systemName: classification.type.iconName)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(classification.type.rawValue)
                    .font(.system(size: 13, weight: .semibold))
            }
            
            // 置信度
            if classification.confidence < 1.0 {
                Text("\(Int(classification.confidence * 100))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 来源标签
            Text(classification.source.rawValue)
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(badgeColor.opacity(0.12))
        )
        .foregroundColor(badgeColor)
    }
    
    private var badgeColor: Color {
        switch classification.type {
        case .location: return .blue
        case .brand: return .orange
        case .app: return .green
        case .person: return .purple
        case .unknown: return .gray
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
