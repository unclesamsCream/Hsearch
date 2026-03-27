//
//  RefinedSkeuomorphicContentView.swift
//  HSearch
//
//  精致拟物风格设计 - 参考 iOS 6 和经典拟物设计
//

import SwiftUI

// MARK: - 精致拟物主题
struct RefinedTheme {
    // 背景 - 浅灰蓝亚麻质感（类似 iOS 6 的 linen）
    static let background = Color(red: 0.94, green: 0.94, blue: 0.96)
    static let backgroundDark = Color(red: 0.88, green: 0.88, blue: 0.92)
    
    // 卡片 - 奶油色纸张
    static let card = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let cardDark = Color(red: 0.92, green: 0.91, blue: 0.89)
    
    // 金属 - 银灰色拉丝
    static let metalLight = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let metalMid = Color(red: 0.75, green: 0.78, blue: 0.82)
    static let metalDark = Color(red: 0.55, green: 0.58, blue: 0.62)
    
    // 强调色 - 深蓝（类似 iOS 6 的蓝色）
    static let accent = Color(red: 0.20, green: 0.40, blue: 0.80)
    static let accentLight = Color(red: 0.35, green: 0.55, blue: 0.95)
    
    // 阴影 - 多层次柔和阴影
    static let shadowDark = Color.black.opacity(0.15)
    static let shadowLight = Color.white.opacity(0.8)
    
    // 文字
    static let textPrimary = Color(red: 0.20, green: 0.20, blue: 0.22)
    static let textSecondary = Color(red: 0.50, green: 0.50, blue: 0.52)
}

// MARK: - 精致拟物背景
struct RefinedBackground: View {
    var body: some View {
        ZStack {
            // 基础色
            RefinedTheme.background
            
            // 亚麻纹理效果 - 使用网格渐变模拟
            GeometryReader { geo in
                Canvas { context, size in
                    // 绘制细微的噪点纹理
                    for i in stride(from: 0, to: Int(size.width), by: 4) {
                        for j in stride(from: 0, to: Int(size.height), by: 4) {
                            let opacity = Double.random(in: 0.01...0.03)
                            let rect = CGRect(x: i, y: j, width: 2, height: 2)
                            context.fill(
                                Path(rect),
                                with: .color(Color.black.opacity(opacity))
                            )
                        }
                    }
                }
                .opacity(0.5)
                
                // 顶部光源
                VStack {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geo.size.height * 0.5)
                    
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 精致金属按钮
struct RefinedMetalButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 外框 - 凹陷效果
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                RefinedTheme.metalDark,
                                RefinedTheme.metalMid,
                                RefinedTheme.metalLight
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                // 内按钮 - 凸起效果
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                RefinedTheme.metalLight,
                                RefinedTheme.metalMid,
                                RefinedTheme.metalDark
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                // 顶部高光
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: 40, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                RefinedTheme.metalDark,
                                RefinedTheme.metalDark.opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.white.opacity(0.5), radius: 0.5, x: 0, y: 0.5)
            }
            .shadow(
                color: RefinedTheme.shadowDark,
                radius: isPressed ? 2 : 4,
                x: 0,
                y: isPressed ? 1 : 3
            )
            .shadow(
                color: RefinedTheme.shadowLight,
                radius: isPressed ? 1 : 2,
                x: 0,
                y: isPressed ? 0 : -1
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - 精致搜索框
struct RefinedSearchBar: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 搜索图标 - 玻璃质感
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                RefinedTheme.accentLight,
                                RefinedTheme.accent
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                // 玻璃高光
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .shadow(
                color: RefinedTheme.accent.opacity(0.4),
                radius: 4,
                x: 0,
                y: 2
            )
            
            // 输入框
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("搜索关键词...")
                        .font(.system(size: 16))
                        .foregroundColor(RefinedTheme.textSecondary.opacity(0.6))
                }
                
                TextField("", text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(RefinedTheme.textPrimary)
                    .focused($isFocused)
            }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    ZStack {
                        Circle()
                            .fill(RefinedTheme.metalMid)
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // 凹陷背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                RefinedTheme.backgroundDark,
                                RefinedTheme.background
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // 内阴影
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                RefinedTheme.shadowDark.opacity(0.3),
                                RefinedTheme.shadowLight
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFocused ? RefinedTheme.accent.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
        .shadow(
            color: RefinedTheme.shadowDark.opacity(0.2),
            radius: 6,
            x: 0,
            y: 3
        )
    }
}

// MARK: - 精致 App 按钮
struct RefinedAppButton: View {
    let app: AppItem
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // 拟物图标 - 玻璃/果冻质感
                ZStack {
                    // 底座阴影
                    RoundedRectangle(cornerRadius: 10)
                        .fill(app.color.opacity(0.3))
                        .frame(width: 48, height: 48)
                        .offset(x: 0, y: 2)
                        .blur(radius: 4)
                    
                    // 主图标
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    app.color.opacity(0.9),
                                    app.color
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    // 顶部高光 - 玻璃感
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 48, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // 图标
                    Image(systemName: app.iconName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
                .shadow(
                    color: app.color.opacity(0.4),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(app.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(RefinedTheme.textPrimary)
                    
                    Text("点击跳转搜索")
                        .font(.system(size: 12))
                        .foregroundColor(RefinedTheme.textSecondary)
                }
                
                Spacer()
                
                // 箭头 - 简洁的蓝色
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(RefinedTheme.accent.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    // 卡片背景
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RefinedTheme.card)
                    
                    // 顶部高光
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // 边框
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    RefinedTheme.cardDark.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: RefinedTheme.shadowDark.opacity(0.15),
                radius: isPressed ? 2 : 4,
                x: 0,
                y: isPressed ? 1 : 2
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - 精致历史标签
struct RefinedHistoryTag: View {
    let query: String
    let onSelect: () -> Void
    let onDelete: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                Text(query)
                    .font(.system(size: 14))
                    .foregroundColor(RefinedTheme.textPrimary)
                
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(RefinedTheme.textSecondary)
                        .frame(width: 16, height: 16)
                        .background(
                            Circle()
                                .fill(RefinedTheme.cardDark)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RefinedTheme.card)
                    
                    // 顶部高光
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 15)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    RefinedTheme.cardDark.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: RefinedTheme.shadowDark.opacity(0.1),
                radius: isPressed ? 1 : 2,
                x: 0,
                y: isPressed ? 0 : 1
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - 主视图
struct RefinedSkeuomorphicContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // 精致背景
            RefinedBackground()
            
            VStack(spacing: 0) {
                // 顶部工具栏
                HStack {
                    // Logo - 简洁蓝色
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            RefinedTheme.accentLight,
                                            RefinedTheme.accent
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            // 高光
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.4),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(
                            color: RefinedTheme.accent.opacity(0.4),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                        
                        Text("HSearch")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(RefinedTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    // 添加按钮 - 精致金属
                    RefinedMetalButton(icon: "plus") {
                        viewModel.showAddAppSheet = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // 主内容
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 搜索区域
                        VStack(spacing: 16) {
                            RefinedSearchBar(
                                text: $viewModel.searchText,
                                isFocused: $isSearchFocused
                            )
                            
                            if viewModel.searchText.isEmpty {
                                Text("输入关键词，智能推荐 App")
                                    .font(.system(size: 14))
                                    .foregroundColor(RefinedTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        // 搜索历史
                        if viewModel.searchText.isEmpty && !viewModel.searchHistory.isEmpty {
                            searchHistorySection
                                .padding(.horizontal, 20)
                        }
                        
                        // 搜索推荐
                        if !viewModel.searchText.isEmpty {
                            suggestedAppsSection
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            
            // 跳转反馈
            if viewModel.isOpeningApp {
                VStack {
                    Spacer()
                    
                    appOpenFeedback
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 100)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isOpeningApp)
            }
        }
        .sheet(isPresented: $viewModel.showAddAppSheet) {
            AddAppView { app in viewModel.addApp(app) }
        }
    }
    
    // MARK: - 搜索历史区域
    private var searchHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 14))
                        .foregroundColor(RefinedTheme.accent)
                    
                    Text("最近搜索")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(RefinedTheme.textPrimary)
                }
                
                Spacer()
                
                Button(action: { viewModel.clearHistory() }) {
                    Text("清除")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(RefinedTheme.accent)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(viewModel.searchHistory.enumerated()), id: \.offset) { index, query in
                        RefinedHistoryTag(
                            query: query,
                            onSelect: { viewModel.searchText = query },
                            onDelete: { viewModel.removeFromHistory(query) }
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(RefinedTheme.card)
                
                // 顶部高光
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                RefinedTheme.cardDark.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(
            color: RefinedTheme.shadowDark.opacity(0.1),
            radius: 6,
            x: 0,
            y: 3
        )
    }
    
    // MARK: - 搜索推荐区域
    private var suggestedAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.forward.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(RefinedTheme.accent)
                
                Text("点击直接跳转搜索")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(RefinedTheme.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(viewModel.suggestedApps.prefix(6)) { app in
                    RefinedAppButton(app: app) {
                        viewModel.openApp(app)
                    }
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(RefinedTheme.card)
                
                // 顶部高光
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                RefinedTheme.cardDark.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(
            color: RefinedTheme.shadowDark.opacity(0.1),
            radius: 6,
            x: 0,
            y: 3
        )
    }
    
    // MARK: - App 跳转反馈
    private var appOpenFeedback: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                RefinedTheme.accentLight,
                                RefinedTheme.accent
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("正在打开")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(RefinedTheme.textPrimary)
                
                Text(viewModel.openingAppName)
                    .font(.system(size: 13))
                    .foregroundColor(RefinedTheme.textSecondary)
            }
            
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: RefinedTheme.accent))
                .scaleEffect(0.9)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(RefinedTheme.card)
                
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        RefinedTheme.accent.opacity(0.3),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(
            color: RefinedTheme.shadowDark.opacity(0.2),
            radius: 10,
            x: 0,
            y: 5
        )
        .padding(.horizontal, 28)
    }
}

// MARK: - 按压事件辅助
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

struct RefinedSkeuomorphicContentView_Previews: PreviewProvider {
    static var previews: some View {
        RefinedSkeuomorphicContentView()
    }
}