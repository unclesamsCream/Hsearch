//
//  AddAppView.swift
//  HSearch
//

import SwiftUI

struct AddAppView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (AppItem) -> Void
    
    @State private var name: String = ""
    @State private var urlScheme: String = ""
    @State private var searchTemplate: String = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedIcon: String = "app.fill"
    
    let availableIcons = ["app.fill", "bag.fill", "cart.fill", "book.fill", "play.circle.fill", "message.fill", "tv.fill", "questionmark.circle.fill", "eye.fill", "music.note", "camera.fill", "photo.fill", "map.fill", "bubble.left.fill"]
    let availableColors: [Color] = [.blue, .red, .green, .orange, .pink, .purple, .yellow, .cyan, .indigo]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("App 名称", text: $name)
                    TextField("URL Scheme (如: taobao://)", text: $urlScheme)
                }
                Section(header: Text("搜索链接模板 (可选)")) {
                    TextField("如: taobao://s.taobao.com/search?q={query}", text: $searchTemplate)
                    Text("使用 {query} 作为搜索词占位符").font(.caption).foregroundColor(.secondary)
                }
                Section(header: Text("图标")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon).font(.system(size: 20)).frame(width: 44, height: 44)
                                    .background(Circle().fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear))
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle().fill(color).frame(width: 36, height: 36)
                                    .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0))
                                    .shadow(radius: selectedColor == color ? 2 : 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                Section {
                    Button(action: {
                        let app = AppItem(id: UUID().uuidString, name: name, iconName: selectedIcon, color: selectedColor, urlScheme: urlScheme, searchUrlTemplate: searchTemplate.isEmpty ? nil : searchTemplate)
                        onAdd(app)
                        dismiss()
                    }) {
                        Text("添加").fontWeight(.semibold).frame(maxWidth: .infinity)
                    }
                    .disabled(name.isEmpty || urlScheme.isEmpty)
                }
            }
            .navigationTitle("添加应用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

struct AddAppView_Previews: PreviewProvider {
    static var previews: some View {
        AddAppView { _ in }
    }
}
