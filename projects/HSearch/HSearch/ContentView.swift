//
//  ContentView.swift
//  HSearch
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText, isSearching: $viewModel.isSearching)
                    .focused($isSearchFocused)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if !viewModel.searchText.isEmpty {
                    SuggestedAppsView(apps: viewModel.suggestedApps, searchText: viewModel.searchText, onAppTap: { app in
                        viewModel.openApp(app)
                    })
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                SavedAppsView(apps: viewModel.savedApps, onDelete: { indexSet in
                    viewModel.deleteApps(at: indexSet)
                }, onAppTap: { app in
                    viewModel.openApp(app)
                })
                
                Spacer()
            }
            .navigationTitle("HSearch")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showAddAppSheet = true }) {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddAppSheet) {
                AddAppView { app in viewModel.addApp(app) }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary).font(.system(size: 17, weight: .semibold))
            TextField("搜索...", text: $text).font(.system(size: 17))
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.systemGray6)))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(.systemGray4), lineWidth: 1))
    }
}

struct SuggestedAppsView: View {
    let apps: [AppItem]
    let searchText: String
    let onAppTap: (AppItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("搜索 \"\(searchText)\" 到...").font(.subheadline).foregroundColor(.secondary).padding(.horizontal).padding(.top, 8)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(apps) { app in
                        SuggestedAppButton(app: app) { onAppTap(app) }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SuggestedAppButton: View {
    let app: AppItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(app.color.opacity(0.15)).frame(width: 56, height: 56)
                    Image(systemName: app.iconName).font(.system(size: 24)).foregroundColor(app.color)
                }
                Text(app.name).font(.caption).foregroundColor(.primary).lineLimit(1)
            }
            .frame(width: 72)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SavedAppsView: View {
    let apps: [AppItem]
    let onDelete: (IndexSet) -> Void
    let onAppTap: (AppItem) -> Void
    
    var body: some View {
        List {
            Section(header: Text("我的应用")) {
                ForEach(apps) { app in
                    AppRow(app: app) { onAppTap(app) }
                }
                .onDelete(perform: onDelete)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct AppRow: View {
    let app: AppItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(app.color.opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: app.iconName).font(.system(size: 20)).foregroundColor(app.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name).font(.system(size: 16, weight: .medium)).foregroundColor(.primary)
                    Text(app.urlScheme).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
