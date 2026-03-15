# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

### iOS Simulator 截图流程

**设备信息：**
- 设备: iPhone 17 Pro
- UDID: 53AC532B-2234-408D-AA14-5A2EF8C96633
- Bundle ID: com.haoyu.HSearch

**截图步骤：**
1. 确保模拟器已启动: `xcrun simctl boot 53AC532B-2234-408D-AA14-5A2EF8C96633`
2. 安装 App: `xcrun simctl install booted <path_to_app>`
3. 启动 App: `xcrun simctl launch booted com.haoyu.HSearch`
4. 等待 3 秒让 App 完全加载
5. 截图: `xcrun simctl io booted screenshot <path>`
6. 截图保存位置: `/Users/robot/.openclaw/workspace/projects/HSearch/screenshot_*.png`

**快速截图脚本：**
```bash
cd /Users/robot/.openclaw/workspace/projects/HSearch
xcrun simctl launch booted com.haoyu.HSearch 2>/dev/null || true
sleep 3
xcrun simctl io booted screenshot screenshot_$(date +%H%M%S).png
```

**注意事项：**
- 使用 `booted` 别名代替具体 UDID 更灵活
- App 路径: `~/Library/Developer/Xcode/DerivedData/HSearch-*/Build/Products/Debug-iphonesimulator/HSearch.app`
- 截图前确保 App 已启动并完全加载（sleep 3秒）

---

Add whatever helps you do your job. This is your cheat sheet.
