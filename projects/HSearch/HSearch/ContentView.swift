//
//  ContentView.swift
//  HSearch
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 主搜索区域 - 居中
                Spacer()
                
                VStack(spacing: 24) {
                    // 大搜索栏
                    LargeSearchBar(
                        text: $viewModel.searchText,
                        isFocused: $isSearchFocused
                    )
                    .padding(.horizontal, 24)
                    
                    // 搜索提示文字
                    if viewModel.searchText.isEmpty {
                        Text("输入关键词，智能推荐 App")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .transition(.opacity)
                    }
                }
                
                Spacer()
                
                // 底部：搜索推荐（有输入时显示）
                if !viewModel.searchText.isEmpty {
                    SuggestedAppsView(
                        apps: viewModel.suggestedApps,
                        searchText: viewModel.searchText,
                        onAppTap: { app in
                            viewModel.openApp(app)
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // 底部：快捷应用网格
                QuickAppsGrid(
                    apps: viewModel.savedApps,
                    onAppTap: { app in
                        viewModel.openApp(app)
                    },
                    onAddTap: {
                        viewModel.showAddAppSheet = true
                    }
                )
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $viewModel.showAddAppSheet) {
            AddAppView { app in viewModel.addApp(app) }
        }
    }
}

// MARK: - 大搜索栏
struct LargeSearchBar: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 22, weight: .semibold))
            
            TextField("搜索...", text: $text)
                .font(.system(size: 20))
                .focused($isFocused)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 22))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? Color.blue.opacity(0.5) : Color(.systemGray4), lineWidth: isFocused ? 2 : 1)
        )
        .shadow(color: isFocused ? Color.blue.opacity(0.1) : Color.clear, radius: 8, x: 0, y: 4)
    }
}

// MARK: - 搜索推荐视图
struct SuggestedAppsView: View {
    let apps: [AppItem]
    let searchText: String
    let onAppTap: (AppItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("搜索 \"\(searchText)\" 到...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(apps.prefix(5)) { app in
                        SuggestedAppButton(app: app) { onAppTap(app) }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }
}

struct SuggestedAppButton: View {
    let app: AppItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(app.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: app.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(app.color)
                }
                Text(app.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 72)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 快捷应用网格
struct QuickAppsGrid: View {
    let apps: [AppItem]
    let onAppTap: (AppItem) -> Void
    let onAddTap: () -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷应用")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(apps.prefix(7)) { app in
                    QuickAppButton(app: app) { onAppTap(app) }
                }
                
                // 添加按钮
                Button(action: onAddTap) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 56, height: 56)
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        Text("添加")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 72)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct QuickAppButton: View {
    let app: AppItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(app.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: app.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(app.color)
                }
                Text(app.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 72)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
