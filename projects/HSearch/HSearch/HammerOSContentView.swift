//
//  HammerOSContentView.swift
//  HSearch
//
//  锤子 OS 拟物风格设计
//

import SwiftUI

// MARK: - 锤子 OS 主题
struct HammerOSTheme {
    // 皮革背景色
    static let leatherDark = Color(red: 0.25, green: 0.18, blue: 0.12)
    static let leatherBase = Color(red: 0.35, green: 0.25, blue: 0.18)
    static let leatherLight = Color(red: 0.45, green: 0.32, blue: 0.23)
    
    // 金属质感
    static let metalDark = Color(red: 0.25, green: 0.27, blue: 0.30)
    static let metalBase = Color(red: 0.55, green: 0.58, blue: 0.62)
    static let metalLight = Color(red: 0.85, green: 0.87, blue: 0.90)
    static let metalHighlight = Color(red: 0.95, green: 0.96, blue: 0.98)
    
    // 金色点缀
    static let gold = Color(red: 0.85, green: 0.70, blue: 0.35)
    static let goldDark = Color(red: 0.65, green: 0.52, blue: 0.25)
    
    // 深色阴影
    static let shadowDark = Color.black.opacity(0.6)
    static let shadowLight = Color.white.opacity(0.15)
    
    // 纸张/卡片色
    static let paper = Color(red: 0.96, green: 0.94, blue: 0.90)
    static let paperDark = Color(red: 0.88, green: 0.85, blue: 0.80)
}

// MARK: - 皮革纹理背景
struct LeatherBackground: View {
    var body: some View {
        ZStack {
            // 基础皮革色
            HammerOSTheme.leatherBase
            
            // 皮革纹理效果 - 使用径向渐变模拟
            GeometryReader { geo in
                ZStack {
                    // 主光源
                    RadialGradient(
                        colors: [
                            HammerOSTheme.leatherLight.opacity(0.3),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.8
                    )
                    
                    // 次光源
                    RadialGradient(
                        colors: [
                            HammerOSTheme.leatherLight.opacity(0.15),
                            Color.clear
                        ],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.6
                    )
                    
                    // 暗角效果
                    RadialGradient(
                        colors: [
                            Color.clear,
                            HammerOSTheme.leatherDark.opacity(0.5)
                        ],
                        center: .center,
                        startRadius: geo.size.width * 0.3,
                        endRadius: geo.size.width
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 主视图
struct HammerOSContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // 皮革背景
            LeatherBackground()
            
            VStack(spacing: 0) {
                // 顶部工具栏
                HStack {
                    // 品牌标识
                    HStack(spacing: 8) {
                        // 金属质感 Logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            HammerOSTheme.gold,
                                            HammerOSTheme.goldDark
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(HammerOSTheme.leatherDark)
                        }
                        .shadow(
                            color: HammerOSTheme.goldDark.opacity(0.5),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                        
                        Text("HSearch")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(HammerOSTheme.paper)
                            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    // 添加按钮 - 金属风格
                    Button(action: { viewModel.showAddAppSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(HammerOSTheme.leatherDark)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    HammerOSTheme.metalLight,
                                                    HammerOSTheme.metalBase,
                                                    HammerOSTheme.metalDark
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    HammerOSTheme.metalHighlight,
                                                    HammerOSTheme.metalLight.opacity(0.5)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                }
                            )
                            .shadow(color: HammerOSTheme.shadowDark, radius: 4, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // 主内容区域
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 搜索区域
                        VStack(spacing: 20) {
                            // 拟物搜索框
                            HStack(spacing: 12) {
                                // 金属搜索图标按钮
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    HammerOSTheme.gold,
                                                    HammerOSTheme.goldDark
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                    
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
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(HammerOSTheme.leatherDark)
                                }
                                .shadow(
                                    color: HammerOSTheme.goldDark.opacity(0.5),
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                                
                                // 输入框
                                ZStack(alignment: .leading) {
                                    if viewModel.searchText.isEmpty {
                                        Text("搜索关键词...")
                                            .font(.system(size: 16))
                                            .foregroundColor(HammerOSTheme.leatherBase.opacity(0.6))
                                    }
                                    
                                    TextField("", text: $viewModel.searchText)
                                        .font(.system(size: 16))
                                        .foregroundColor(HammerOSTheme.leatherDark)
                                        .focused($isSearchFocused)
                                }
                                
                                if !viewModel.searchText.isEmpty {
                                    Button(action: { viewModel.searchText = "" }) {
                                        ZStack {
                                            Circle()
                                                .fill(HammerOSTheme.metalBase)
                                                .frame(width: 24, height: 24)
                                            
                                            Image(systemName: "xmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    // 凹陷效果背景
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    HammerOSTheme.paperDark,
                                                    HammerOSTheme.paper
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // 内阴影
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    HammerOSTheme.shadowDark.opacity(0.3),
                                                    HammerOSTheme.shadowLight
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        isSearchFocused ? HammerOSTheme.gold : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            
                            if viewModel.searchText.isEmpty {
                                Text("输入关键词，智能推荐 App")
                                    .font(.system(size: 14))
                                    .foregroundColor(HammerOSTheme.paper.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        
                        // 搜索历史
                        if viewModel.searchText.isEmpty && !viewModel.searchHistory.isEmpty {
                            searchHistoryView
                                .padding(.horizontal, 24)
                        }
                        
                        // 搜索推荐
                        if !viewModel.searchText.isEmpty {
                            suggestedAppsView
                                .padding(.horizontal, 24)
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
    
    // MARK: - 搜索历史视图
    private var searchHistoryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 14))
                        .foregroundColor(HammerOSTheme.gold)
                    
                    Text("最近搜索")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(HammerOSTheme.paper)
                }
                
                Spacer()
                
                Button(action: { viewModel.clearHistory() }) {
                    Text("清除")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(HammerOSTheme.gold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(HammerOSTheme.leatherLight.opacity(0.3))
                        )
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(viewModel.searchHistory.enumerated()), id: \.offset) { index, query in
                        Button(action: { viewModel.searchText = query }) {
                            HStack(spacing: 6) {
                                Text(query)
                                    .font(.system(size: 14))
                                    .foregroundColor(HammerOSTheme.leatherDark)
                                
                                Button(action: { viewModel.removeFromHistory(query) }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(HammerOSTheme.leatherBase)
                                        .frame(width: 16, height: 16)
                                        .background(
                                            Circle()
                                                .fill(HammerOSTheme.paperDark)
                                        )
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(HammerOSTheme.paper)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    HammerOSTheme.shadowLight,
                                                    HammerOSTheme.shadowDark.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                            )
                            .shadow(
                                color: HammerOSTheme.shadowDark.opacity(0.15),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                HammerOSTheme.leatherLight.opacity(0.3),
                                HammerOSTheme.leatherBase.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        HammerOSTheme.gold.opacity(0.3),
                        lineWidth: 1
                    )
            }
        )
    }
    
    // MARK: - 搜索推荐视图
    private var suggestedAppsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.forward.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(HammerOSTheme.gold)
                
                Text("点击直接跳转搜索")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(HammerOSTheme.paper)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.suggestedApps.prefix(6)) { app in
                    appButton(app: app)
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                HammerOSTheme.leatherLight.opacity(0.3),
                                HammerOSTheme.leatherBase.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        HammerOSTheme.gold.opacity(0.3),
                        lineWidth: 1
                    )
            }
        )
    }
    
    // MARK: - App 按钮
    private func appButton(app: AppItem) -> some View {
        Button(action: { viewModel.openApp(app) }) {
            HStack(spacing: 16) {
                // 拟物图标
                ZStack {
                    // 图标底座 - 立体效果
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    app.color.opacity(0.8),
                                    app.color
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(
                            color: app.color.opacity(0.5),
                            radius: 4,
                            x: 0,
                            y: 3
                        )
                    
                    // 顶部高光
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 52, height: 26)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Image(systemName: app.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(HammerOSTheme.paper)
                    
                    Text("点击跳转搜索")
                        .font(.system(size: 12))
                        .foregroundColor(HammerOSTheme.paper.opacity(0.7))
                }
                
                Spacer()
                
                // 金属箭头
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    HammerOSTheme.metalLight,
                                    HammerOSTheme.metalBase
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(HammerOSTheme.leatherDark)
                }
                .shadow(
                    color: HammerOSTheme.shadowDark.opacity(0.3),
                    radius: 2,
                    x: 0,
                    y: 1
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(HammerOSTheme.paper.opacity(0.95))
                    .shadow(
                        color: HammerOSTheme.shadowDark.opacity(0.2),
                        radius: 3,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - App 跳转反馈
    private var appOpenFeedback: some View {
        HStack(spacing: 16) {
            // 金属质感图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                HammerOSTheme.gold,
                                HammerOSTheme.goldDark
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.system(size: 20))
                    .foregroundColor(HammerOSTheme.leatherDark)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("正在打开")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(HammerOSTheme.leatherDark)
                
                Text(viewModel.openingAppName)
                    .font(.system(size: 13))
                    .foregroundColor(HammerOSTheme.leatherBase)
            }
            
            Spacer()
            
            // 金属质感进度指示器
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: HammerOSTheme.gold))
                .scaleEffect(1.0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(HammerOSTheme.paper)
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        HammerOSTheme.gold.opacity(0.5),
                        lineWidth: 2
                    )
            }
        )
        .shadow(
            color: HammerOSTheme.shadowDark.opacity(0.4),
            radius: 12,
            x: 0,
            y: 6
        )
        .padding(.horizontal, 32)
    }
}

struct HammerOSContentView_Previews: PreviewProvider {
    static var previews: some View {
        HammerOSContentView()
    }
}