//
//  NewSkeuomorphicContentView.swift
//  HSearch
//
//  精致拟物风格设计 - 参考 iOS 6 / iOS 7 经典设计
//

import SwiftUI

// MARK: - 精致主题
struct NewSkeuomorphicTheme {
    // 背景 - 浅灰亚麻质感
    static let background = Color(red: 0.94, green: 0.94, blue: 0.95)
    static let backgroundDark = Color(red: 0.88, green: 0.88, blue: 0.90)
    
    // 卡片 - 奶油白
    static let card = Color.white
    static let cardDark = Color(red: 0.93, green: 0.93, blue: 0.95)
    
    // 金属
    static let metalLight = Color(red: 0.92, green: 0.93, blue: 0.95)
    static let metalMid = Color(red: 0.70, green: 0.72, blue: 0.75)
    static let metalDark = Color(red: 0.45, green: 0.48, blue: 0.52)
    
    // 强调色 - iOS 蓝色
    static let accent = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let accentLight = Color(red: 0.07, green: 0.57, blue: 1.0)
    
    // 阴影
    static let shadowDark = Color.black.opacity(0.12)
    static let shadowLight = Color.white.opacity(0.7)
    
    // 文字
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.17)
    static let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.58)
}

// MARK: - 精致搜索框
struct NewSearchBar: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            // 蓝色搜索图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [NewSkeuomorphicTheme.accentLight, NewSkeuomorphicTheme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 30)
                
                // 高光
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 30)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: NewSkeuomorphicTheme.accent.opacity(0.35), radius: 3, x: 0, y: 2)
            
            // 输入框
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("搜索...")
                        .font(.system(size: 16))
                        .foregroundColor(NewSkeuomorphicTheme.textSecondary.opacity(0.6))
                }
                TextField("", text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(NewSkeuomorphicTheme.textPrimary)
                    .focused($isFocused)
            }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(NewSkeuomorphicTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [NewSkeuomorphicTheme.backgroundDark, NewSkeuomorphicTheme.background],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isFocused ? NewSkeuomorphicTheme.accent.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
        .shadow(color: NewSkeuomorphicTheme.shadowDark.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

// MARK: - App 按钮
struct NewAppButton: View {
    let app: AppItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 渐变图标
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(app.color.gradient)
                        .frame(width: 44, height: 44)
                    
                    // 高光
                    RoundedRectangle(cornerRadius: 9)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 44, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    
                    Image(systemName: app.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                .shadow(color: app.color.opacity(0.4), radius: 3, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(NewSkeuomorphicTheme.textPrimary)
                    
                    Text("点击跳转")
                        .font(.system(size: 12))
                        .foregroundColor(NewSkeuomorphicTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(NewSkeuomorphicTheme.accent.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(NewSkeuomorphicTheme.card)
            )
            .shadow(color: NewSkeuomorphicTheme.shadowDark.opacity(0.08), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 历史标签
struct NewHistoryTag: View {
    let query: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 5) {
                Text(query)
                    .font(.system(size: 14))
                    .foregroundColor(NewSkeuomorphicTheme.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(NewSkeuomorphicTheme.card)
            )
            .shadow(color: NewSkeuomorphicTheme.shadowDark.opacity(0.06), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 主视图
struct NewSkeuomorphicContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // 背景
            NewSkeuomorphicTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部栏
                HStack {
                    // Logo
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9)
                                .fill(
                                    LinearGradient(
                                        colors: [NewSkeuomorphicTheme.accentLight, NewSkeuomorphicTheme.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            RoundedRectangle(cornerRadius: 9)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.35), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: NewSkeuomorphicTheme.accent.opacity(0.35), radius: 3, x: 0, y: 2)
                        
                        Text("HSearch")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(NewSkeuomorphicTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    // 添加按钮
                    Button(action: { viewModel.showAddAppSheet = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [NewSkeuomorphicTheme.metalLight, NewSkeuomorphicTheme.metalMid],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(NewSkeuomorphicTheme.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // 内容
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 搜索
                        VStack(spacing: 14) {
                            NewSearchBar(text: $viewModel.searchText, isFocused: $isSearchFocused)
                            
                            if viewModel.searchText.isEmpty {
                                Text("输入关键词搜索 App")
                                    .font(.system(size: 14))
                                    .foregroundColor(NewSkeuomorphicTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        
                        // 历史
                        if viewModel.searchText.isEmpty && !viewModel.searchHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 13))
                                        .foregroundColor(NewSkeuomorphicTheme.accent)
                                    Text("最近搜索")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(NewSkeuomorphicTheme.textPrimary)
                                    Spacer()
                                    Button("清除") {
                                        viewModel.clearHistory()
                                    }
                                    .font(.system(size: 13))
                                    .foregroundColor(NewSkeuomorphicTheme.accent)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(Array(viewModel.searchHistory.enumerated()), id: \.offset) { _, query in
                                            NewHistoryTag(query: query) {
                                                viewModel.searchText = query
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(NewSkeuomorphicTheme.card)
                                    .shadow(color: NewSkeuomorphicTheme.shadowDark.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // 推荐
                        if !viewModel.searchText.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "arrow.up.forward")
                                        .font(.system(size: 13))
                                        .foregroundColor(NewSkeuomorphicTheme.accent)
                                    Text("点击跳转搜索")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(NewSkeuomorphicTheme.textPrimary)
                                    Spacer()
                                }
                                
                                VStack(spacing: 6) {
                                    ForEach(viewModel.suggestedApps.prefix(6)) { app in
                                        NewAppButton(app: app) {
                                            viewModel.openApp(app)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(NewSkeuomorphicTheme.card)
                                    .shadow(color: NewSkeuomorphicTheme.shadowDark.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            
            // Toast
            if viewModel.isOpeningApp {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(NewSkeuomorphicTheme.accent)
                                .frame(width: 36, height: 36)
                            Image(systemName: "arrow.up.forward.app.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("正在打开")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(NewSkeuomorphicTheme.textPrimary)
                            Text(viewModel.openingAppName)
                                .font(.system(size: 12))
                                .foregroundColor(NewSkeuomorphicTheme.textSecondary)
                        }
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: NewSkeuomorphicTheme.accent))
                            .scaleEffect(0.8)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(NewSkeuomorphicTheme.card)
                            .shadow(color: NewSkeuomorphicTheme.shadowDark.opacity(0.2), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 28)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isOpeningApp)
            }
        }
        .sheet(isPresented: $viewModel.showAddAppSheet) {
            AddAppView { app in viewModel.addApp(app) }
        }
    }
}

struct NewSkeuomorphicContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewSkeuomorphicContentView()
    }
}