# 🖼️ Wallhaven - 跨平台壁纸 App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/Platforms-Windows%20%7C%20macOS%20%7C%20iOS%20%7C%20Android-green.svg" alt="Platforms">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
</p>

<p align="center">
  <strong>一款支持电脑端和手机端同时运行的跨平台免费壁纸应用</strong>
</p>

---

## 📱 跨平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| 🖥️ **Windows** | ✅ 已配置 | 桌面应用，支持设置壁纸 |
| 🍎 **macOS** | ✅ 已配置 | 桌面应用，支持设置壁纸 |
| 📱 **Android** | ✅ 已配置 | 移动应用，支持设置壁纸 |
| 📱 **iOS** | ✅ 已配置 | 移动应用，保存到相册 |
| 🌐 **HarmonyOS** | ✅ 兼容 | 鸿蒙系统兼容 Android |
| 🌐 **Web** | ✅ 已配置 | 浏览器版本 |

## ✨ 核心功能

- 🔍 **在线壁纸搜索** - Unsplash + Pexels 双源
- ⬇️ **多分辨率下载** - 原画/2K/4K
- 🖼️ **一键设置壁纸** - 跨平台支持
- ⭐ **收藏管理** - 本地持久化
- 🔄 **自动更换** - 定时随机切换
- 🌙 **深色模式** - 跟随系统
- 🔐 **用户登录** - 多平台支持

## 🚀 快速开始

### 前置要求

- Flutter SDK 3.x
- Dart SDK 3.x
- Git

### 1. 克隆项目

```bash
git clone <your-repo-url>
cd wallhaven/wallpaper_app
```

### 2. 配置 API 密钥

编辑 `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // Unsplash API - https://unsplash.com/developers
  static const String unsplashAccessKey = 'YOUR_ACCESS_KEY';
  
  // Pexels API - https://www.pexels.com/api/
  static const String pexelsApiKey = 'YOUR_API_KEY';
}
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. 运行应用

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

#### Android
```bash
flutter run -d android
```

#### iOS (需要 Mac)
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

## 📁 项目结构

```
wallpaper_app/
├── android/                    # Android 原生配置
│   ├── app/
│   │   ├── build.gradle        # 构建配置
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/.../MainActivity.kt
│   ├── build.gradle
│   └── settings.gradle
│
├── ios/                        # iOS 原生配置
│   └── Runner/
│       ├── AppDelegate.swift
│       └── Info.plist
│
├── windows/                    # Windows 原生配置
│   ├── CMakeLists.txt
│   ├── runner/
│   │   └── main.cpp
│   └── flutter/
│       └── windows.cpp
│
├── macos/                      # macOS 原生配置
│   └── Runner/
│       └── Info.plist
│
├── web/                        # Web 平台配置
│   ├── index.html
│   └── manifest.json
│
└── lib/
    ├── main.dart               # 应用入口
    ├── app.dart                # App 配置
    │
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart
    │   ├── services/
    │   │   ├── wallpaper_service.dart    # 设置壁纸
    │   │   ├── download_service.dart      # 下载
    │   │   ├── auto_change_service.dart  # 自动更换
    │   │   └── ...
    │   └── utils/
    │
    ├── data/
    │   ├── models/
    │   ├── providers/
    │   └── repositories/
    │       ├── unsplash_api.dart
    │       └── pexels_api.dart
    │
    └── presentation/
        ├── pages/
        ├── widgets/
        └── theme/
```

## 🛠️ 平台特定功能

### Windows / macOS / Linux

- ✅ 直接设置桌面壁纸
- ✅ 窗口管理
- ✅ 桌面端适配布局

### Android

- ✅ 设置主屏幕/锁屏壁纸
- ✅ 开机自启
- ✅ 后台自动更换

### iOS

- ⚠️ 保存到相册（Apple 不允许第三方应用直接设置壁纸）
- ✅ 设置提醒引导用户手动设置

### Web

- ✅ 全平台访问
- ⚠️ 无法设置系统壁纸（浏览器限制）

## 📦 构建发布

### Windows
```bash
flutter build windows --release
# 输出: build/windows/x64/runner/Release/wallpaper_app.exe
```

### macOS
```bash
flutter build macos --release
# 输出: build/macos/Build/Products/Release/wallhaven.app
```

### Android
```bash
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk

# 或生成 App Bundle
flutter build appbundle --release
```

### iOS (需要 Mac)
```bash
flutter build ios --release
# 输出: build/ios/iphoneos/Runner.app
```

### Web
```bash
flutter build web --release
# 输出: build/web/
```

## 🎨 界面预览

打开 `demo/interactive_demo.html` 查看交互式演示。

| 平台 | 界面特点 |
|------|----------|
| 手机 | 底部导航栏、触摸手势、单列/双列布局 |
| 平板 | 侧边导航、分栏布局 |
| 桌面 | 侧边导航栏、鼠标悬停效果、宽屏布局 |

## 📝 常见问题

### Q: Windows 构建失败？
确保已安装 Visual Studio 2022，并选择 "Desktop development with C++" 工作负载。

### Q: iOS 构建失败？
确保在 Mac 上运行，并且 Xcode 已正确配置签名。

### Q: Android 模拟器无法运行？
确保 Android SDK 已正确配置，运行 `flutter doctor` 检查。

### Q: Web 版本无法设置壁纸？
这是浏览器的安全限制，Web 版本只能浏览和下载。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**Made with ❤️ using Flutter**