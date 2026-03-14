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
                // 顶部工具栏
                HStack {
                    Spacer()
                    Button(action: { viewModel.showAddAppSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // 主搜索区域 - 居中
                Spacer()
                
                VStack(spacing: 20) {
                    // App 图标
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.blue.gradient)
                            .frame(width: 80, height: 80)
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 8)
                    
                    // App 名称
                    Text("HSearch")
                        .font(.system(size: 28, weight: .bold))
                    
                    // 大搜索栏
                    LargeSearchBar(
                        text: $viewModel.searchText,
                        isFocused: $isSearchFocused
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
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
                
                Spacer(minLength: 40)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("搜索 \"\(searchText)\" 到...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(apps.prefix(5)) { app in
                        SuggestedAppButton(app: app) { onAppTap(app) }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

struct SuggestedAppButton: View {
    let app: AppItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(app.color.opacity(0.15))
                        .frame(width: 64, height: 64)
                    Image(systemName: app.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(app.color)
                }
                Text(app.name)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
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
