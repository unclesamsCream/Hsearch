# MEMORY.md - 长期记忆

## 用户偏好设置

### 搜索工具偏好
- **首选搜索工具**: `tavily_search` (Tavily Search)
- **原因**: `web_search` 内置工具配置的 Kimi provider API key 已失效
- **生效时间**: 2026-03-14
- **备注**: Tavily 插件已安装且 API key 有效

### 搜索工具使用规则
1. 默认使用 `tavily_search` 进行所有网络搜索
2. 不再使用 `web_search` 工具（除非用户明确要求）
3. `tavily_search` 参数：
   - `query`: 搜索查询字符串（必需）
   - `count`: 返回结果数量（1-20，默认 5）
   - `search_depth`: 搜索深度（"basic", "advanced", "fast", "ultra-fast"，默认 "advanced"）

## 项目记录

### HSearch (iOS 搜索聚合 App)
- **状态**: 开发中
- **GitHub**: https://github.com/unclesamsCream/Hsearch
- **开始时间**: 2026-03-11
- **核心功能**: 智能推荐 App 并一键跳转搜索
- **GitHub Token**: 已配置（classic PAT，用于 push 代码）

## 系统配置备注

### OpenClaw 配置
- `web_search` 内置工具不支持 Tavily 作为 provider
- 支持的 provider: brave, perplexity, grok, gemini, kimi
- Tavily 通过插件 `openclaw-tavily` 提供 `tavily_search` 工具
