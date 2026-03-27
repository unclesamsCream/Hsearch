# HSearch 设计文档

## 1. 设计风格概述

HSearch 采用 **新拟物风格（Neumorphism）** 设计，这是一种融合了现代极简主义和传统拟物设计的 UI 风格。核心特点是通过柔和的阴影创造 出"凸起"和"凹陷"的视觉效果，让界面元素看起来像是从背景中雕刻出来的。

## 2. 色彩系统

### 2.1 核心配色

| 颜色名称 | HEX 值 | 使用场景 |
|---------|--------|---------|
| 背景色 | #EFEEF2 | 主背景，营造柔和基底 |
| 卡片背景 | #F2F1F4 | 卡片、输入框容器 |
| 强调色 | #4D80F2 | 品牌色、按钮、图标 |
| 辅助强调 | #8C94A0 | 次要图标、辅助元素 |
| 文字主色 | #1A1A1E | 标题、重要文字 |
| 文字次色 | #8C8C8E | 描述文字、占位符 |

### 2.2 阴影系统

**凸起效果（Elevated）**：
- 亮色阴影：`Color.white.opacity(0.85)`
- 暗色阴影：`Color.black.opacity(0.25)`
- 应用于：按钮、图标、标签

**凹陷效果（Inset）**：
- 亮色阴影：`Color.white.opacity(0.85)`
- 暗色阴影：`Color.black.opacity(0.25)`
- 应用于：输入框、搜索栏

### 2.3 渐变应用

**按钮/图标渐变**：
```swift
LinearGradient(
    colors: [accent, accent.opacity(0.7)],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

**高光效果**：
```swift
LinearGradient(
    colors: [Color.white.opacity(0.4), Color.clear],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

## 3. 组件设计规范

### 3.1 搜索栏

- **背景**：凹陷效果，使用 `neumorphicInset()` 修饰器
- **圆角**：18pt（搜索框整体）、10pt（内嵌元素）
- **内边距**：水平 14pt，垂直 12pt
- **图标**：圆角矩形，12x12pt，带渐变背景
- **激活状态**：边框变为强调色半透明

### 3.2 App 列表项

- **布局**：水平排列，图标 + 文字 + 箭头
- **图标尺寸**：44x44pt，圆角 10pt
- **间距**：图标与文字 12pt，文字与箭头 auto
- **内边距**：水平 16pt，垂直 12pt
- **卡片圆角**：20pt
- **悬停效果**：轻微缩放（0.98x）

### 3.3 历史标签

- **布局**：水平滚动
- **圆角**：12pt
- **内边距**：水平 14pt，垂直 10pt
- **删除按钮**：圆形，16x16pt

### 3.4 按钮

- **主按钮**：圆角 10pt，凸起效果
- **图标按钮**：圆形或圆角矩形
- **按压效果**：阴影减弱 + 轻微缩放

## 4. 动画规范

### 4.1 过渡动画

- **时长**：0.2-0.3 秒
- **曲线**：`.easeInOut` 或 `.spring(response: 0.3, dampingFraction: 0.7)`

### 4.2 按压反馈

```swift
// 按下时
withAnimation(.easeInOut(duration: 0.1)) {
    isPressed = true
}

// 释放时
withAnimation(.easeInOut(duration: 0.1)) {
    isPressed = false
}
```

## 5. 字体规范

- **标题**：20pt，bold
- **正文**：17pt，regular
- **副文字**：15pt，regular
- **小字**：13-14pt，regular

## 6. 间距系统

- **页面边距**：20-24pt
- **组件间距**：16-24pt
- **内边距**：12-16pt

## 7. 设计原则

1. **柔和统一**：所有元素使用一致的阴影系统和圆角
2. **克制的装饰**：避免过度拟物，保持现代感
3. **层次分明**：通过阴影深浅区分主次元素
4. **触觉反馈**：所有可交互元素都有按压状态
5. **留白舒适**：足够的间距让界面"呼吸"

## 8. 后续扩展

如果需要添加新组件，请遵循：

1. 优先使用 NeumorphicTheme 中的颜色
2. 使用 View Extension 提供 neumorphicElevated / neumorphicInset 修饰器
3. 保持圆角一致性（建议 8/10/12/18/20pt）
4. 添加按压状态的视觉反馈

---

**文档版本**：1.0  
**最后更新**：2026-03-27  
**适用**：HSearch iOS App
