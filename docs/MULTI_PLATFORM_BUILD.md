# Wallhaven 多平台构建指南

## 📱 支持的平台

| 平台 | 状态 | 构建命令 | 说明 |
|------|------|----------|------|
| Android | ⚠️ 需要配置 | `flutter build apk` | 鸿蒙系统可运行 Android APK |
| iOS | ⚠️ 需要 Mac | `flutter build ios` | 必须使用 macOS + Xcode |
| Web | ✅ 已就绪 | `flutter build web` | 可部署到任意 Web 服务器 |
| Windows | ⚠️ 需要配置 | `flutter build windows` | 需要 Visual Studio |
| macOS | ⚠️ 需要 Mac | `flutter build macos` | 必须使用 macOS |

---

## 🔧 环境配置

### 1. Android SDK 安装（Windows）

#### 方法一：手动下载（推荐）

1. **下载 Android Command Line Tools**
   ```
   https://developer.android.com/studio#command-line-tools-only
   ```

2. **解压到目录**（如 `C:\android-sdk`）

3. **安装 SDK 组件**
   ```cmd
   cd C:\android-sdk\cmdline-tools\latest\bin
   sdkmanager.bat --sdk_root=C:\android-sdk "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

4. **配置 Flutter**
   ```cmd
   flutter config --android-sdk C:\android-sdk
   ```

#### 方法二：Android Studio

1. 下载 Android Studio: https://developer.android.com/studio
2. 安装时选择 "Custom" 并勾选:
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools

#### 方法三：使用国内镜像

```cmd
# 设置镜像源
set ANDROID_SDK_ROOT=C:\android-sdk
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 使用腾讯云镜像
set PUB_HOSTED_URL=https://mirrors.cloud.tencent.com/dart-pub
set FLUTTER_STORAGE_BASE_URL=https://mirrors.cloud.tencent.com/flutter
```

---

### 2. iOS 构建（必须使用 Mac）

#### 本地构建（需要 Mac）
```bash
# 在 Mac 上运行
flutter pub get
flutter build ios --release

# 导出 IPA
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release archive
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportOptionsPlist ios/ExportOptions.plist -exportPath build/ipa
```

#### 云端构建（CI/CD）- 不需要 Mac

**Codemagic（推荐）:**
1. 注册 https://codemagic.io
2. 连接 GitHub 仓库
3. 自动构建 iOS/Android

**GitHub Actions:**
```yaml
# .github/workflows/build.yml
name: Build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build apk --release
      - run: flutter build web --release
```

**Flutter CI:**
```yaml
# .github/workflows/flutter.yml
name: Flutter CI
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

---

### 3. HarmonyOS（鸿蒙）支持

**好消息：鸿蒙系统可以运行 Android APK！**

- HarmonyOS 2.0 及以上内置 Android 运行时 (ART)
- 直接构建 Android APK 即可在鸿蒙设备上安装运行
- 部分功能（如设置系统壁纸）需要额外适配

**如需原生鸿蒙支持：**
- 华为提供 `flutter_inappbrowser` 等插件支持鸿蒙
- 可考虑使用华为应用市场 SDK

---

### 4. Web 构建

#### 本地预览
```cmd
flutter run -d edge
# 或
cd build/web
python -m http.server 8080
```

#### 部署选项

**Vercel:**
```bash
npm i -g vercel
vercel --prod
```

**Netlify:**
```bash
npm i -g netlify-cli
netlify deploy --prod --dir=build/web
```

**GitHub Pages:**
1. 构建: `flutter build web`
2. 推送 `build/web` 到 `gh-pages` 分支

---

## 📋 构建前检查清单

### Android APK
- [ ] Android SDK 已安装
- [ ] `flutter doctor` 显示 Android toolchain 正常
- [ ] 添加应用图标到 `android/app/src/main/res/`
- [ ] 配置签名密钥（发布时需要）

### iOS
- [ ] 拥有 Apple Developer 账号 ($99/年)
- [ ] Mac + Xcode
- [ ] 创建 App Store Connect 应用
- [ ] 配置 Bundle ID 和签名证书

### Web
- [ ] 更新 `web/index.html` 中的应用名称
- [ ] 配置 PWA（如需要离线功能）
- [ ] 添加 Google Analytics（如需要）

---

## 🚀 快速构建命令

```cmd
# 开发调试
flutter run

# Android
flutter build apk --debug
flutter build apk --release

# iOS (Mac only)
flutter build ios --release --no-codesign

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## 📁 构建输出位置

| 平台 | 输出路径 |
|------|----------|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| iOS IPA | `build/ios/iphoneos/Runner.app` |
| Web | `build/web/` |
| Windows | `build/windows/runner/Release/` |

---

## 🆘 常见问题

### Q: Android SDK 找不到
```cmd
flutter config --android-sdk C:\path\to\sdk
flutter doctor --android-licenses
```

### Q: iOS 只能在 Mac 上构建吗？
A: 是的，苹果要求必须使用 Xcode 进行 iOS 构建。可以使用 Codemagic 等云服务绕过此限制。

### Q: 如何在鸿蒙手机上测试？
A: 开启手机的"开发者模式"和"USB 调试"，用数据线连接电脑，直接运行 `flutter run` 即可安装 APK。

### Q: Web 版本能实现设置壁纸功能吗？
A: 浏览器安全限制不允许网页设置系统壁纸，但可以提供"下载壁纸"功能让用户手动设置。

---

## 📞 获取帮助

- Flutter 官方文档: https://docs.flutter.dev
- Flutter 中文社区: https://flutter.cn
- 问题反馈: https://github.com/flutter/flutter/issues
