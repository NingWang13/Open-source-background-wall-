# 🖥️ 跨平台构建指南

本文档详细说明如何为不同平台构建和发布 Wallhaven App。

## 平台支持矩阵

| 平台 | 构建命令 | 输出文件 | 需要特殊环境 |
|------|----------|----------|--------------|
| Windows | `flutter build windows` | `.exe` | Visual Studio |
| macOS | `flutter build macos` | `.app` | Xcode |
| Linux | `flutter build linux` | 可执行文件 | GCC |
| Android | `flutter build apk` | `.apk` | Android SDK |
| iOS | `flutter build ios` | `.ipa/.app` | Xcode + Mac |
| Web | `flutter build web` | HTML/JS/CSS | 无 |

---

## 1. Windows 桌面应用

### 环境要求
- Windows 10/11
- Visual Studio 2022（含 "Desktop development with C++" 工作负载）
- Flutter SDK

### 构建步骤

```bash
# 1. 检查环境
flutter doctor

# 2. 启用 Windows 桌面支持
flutter config --enable-windows-desktop

# 3. 构建发布版本
flutter build windows --release

# 4. 输出位置
# build/windows/x64/runner/Release/wallpaper_app.exe
```

### 安装程序构建（可选）

使用 Inno Setup 创建安装程序：
```bash
# 下载 Inno Setup
# 创建 installer.iss 脚本
iscc installer.iss
```

---

## 2. macOS 桌面应用

### 环境要求
- macOS 10.14+
- Xcode 14+
- Flutter SDK

### 构建步骤

```bash
# 1. 检查环境
flutter doctor

# 2. 启用 macOS 桌面支持
flutter config --enable-macos-desktop

# 3. 构建发布版本
flutter build macos --release

# 4. 输出位置
# build/macos/Build/Products/Release/wallhaven.app
```

### 签名和分发

```bash
# 添加到 notarization
xcrun notarytool submit wallhaven.app
```

---

## 3. Android 应用

### 环境要求
- Android SDK (API 21+)
- Java JDK 11+
- Flutter SDK

### 构建 APK

```bash
# 1. 检查环境
flutter doctor

# 2. 构建发布 APK
flutter build apk --release

# 3. 输出位置
# build/app/outputs/flutter-apk/app-release.apk
```

### 构建 App Bundle（Google Play）

```bash
# 1. 创建 keystore（首次）
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# 2. 配置签名（编辑 android/app/build.gradle）
android {
    signingConfigs {
        release {
            keyAlias 'key'
            keyPassword 'password'
            storeFile file('key.jks')
            storePassword 'password'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}

# 3. 构建 App Bundle
flutter build appbundle --release

# 4. 输出位置
# build/app/outputs/bundle/release/app.aab
```

### 安装到设备

```bash
# 连接 Android 设备或启动模拟器
adb devices

# 安装 APK
flutter install
```

---

## 4. iOS 应用

### 环境要求
- macOS 12+
- Xcode 14+
- 有效的 Apple Developer 账号
- Flutter SDK

### 构建步骤

```bash
# 1. 检查环境
flutter doctor

# 2. 启用 iOS 支持
flutter config --enable-ios

# 3. 构建发布版本
flutter build ios --release

# 4. 输出位置
# build/ios/iphoneos/Runner.app
```

### 打包为 IPA

```bash
# 使用 xcodebuild 打包
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release archive

# 导出 IPA
xcodebuild -exportArchive -archivepath Runner.xcarchive -exportoptionsplist ExportOptions.plist -exportpath .
```

### TestFlight 分发

1. 在 Xcode 中创建 archive
2. 选择 "Distribute App"
3. 选择 "App Store Connect"
4. 上传到 TestFlight

---

## 5. Web 应用

### 环境要求
- 任意平台
- Flutter SDK

### 构建步骤

```bash
# 1. 构建发布版本
flutter build web --release

# 2. 输出位置
# build/web/
```

### 本地预览

```bash
# 使用本地服务器
cd build/web
python -m http.server 8080

# 或使用 Flutter 内置
cd build/web
flutter run -d chrome
```

### 部署到托管服务

#### GitHub Pages
```bash
# 1. 创建 gh-pages 分支
git checkout -b gh-pages

# 2. 复制构建文件
cp -r build/web/* .

# 3. 推送
git push origin gh-pages
```

#### Vercel
```bash
# 1. 安装 Vercel CLI
npm i -g vercel

# 2. 部署
vercel
```

#### Netlify
```bash
# 1. 安装 Netlify CLI
npm i -g netlify-cli

# 2. 部署
netlify deploy --prod --dir=build/web
```

---

## 6. 统一构建脚本

使用 `build_app.bat` 脚本：

```batch
@echo off
chcp 65001 >nul
title Wallhaven 构建脚本

echo ========================================
echo   Wallhaven 跨平台构建工具
echo ========================================
echo.
echo 请选择目标平台:
echo 1. Windows
echo 2. macOS
echo 3. Android APK
echo 4. Android App Bundle
echo 5. iOS (需要 Mac)
echo 6. Web
echo 0. 退出
echo.

set /p choice="请选择 (0-6): "

if "%choice%"=="1" flutter build windows --release
if "%choice%"=="2" flutter build macos --release
if "%choice%"=="3" flutter build apk --release
if "%choice%"=="4" flutter build appbundle --release
if "%choice%"=="5" flutter build ios --release
if "%choice%"=="6" flutter build web --release

echo.
echo 构建完成！
pause
```

---

## 7. CI/CD 自动构建

### GitHub Actions

创建 `.github/workflows/build.yml`:

```yaml
name: Build

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    strategy:
      matrix:
        platform: [windows, macos, linux, android, ios, web]
    
    runs-on: ${{ matrix.platform == 'ios' && 'macos-latest' || 'ubuntu-latest' }}
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          
      - run: flutter pub get
      - run: flutter build ${{ matrix.platform }} --release
      
      - uses: actions/upload-artifact@v3
        with:
          name: build-${{ matrix.platform }}
          path: build/
```

---

## 8. 常见问题

### Windows 构建失败
```bash
# 错误: Visual Studio not found
# 解决: 安装 Visual Studio 2022，选择 "Desktop development with C++"
```

### iOS 构建失败
```bash
# 错误: CocoaPods not installed
# 解决: sudo gem install cocoapods
```

### Android 构建失败
```bash
# 错误: SDK location not found
# 解决: 设置 ANDROID_HOME 环境变量
```

### Web 构建失败
```bash
# 错误: Web support not enabled
# 解决: flutter config --enable-web
```

---

## 9. 平台特定注意事项

### Windows
- 需要管理员权限才能设置壁纸
- 防火墙可能阻止网络请求

### macOS
- 需要用户授权才能保存到相册
- 沙盒模式限制文件访问

### Android
- Android 10+ 需要额外权限
- 开机自启需要用户授权

### iOS
- 无法直接设置壁纸，只能保存到相册
- App Store 审核需要隐私政策

### Web
- 无法设置系统壁纸
- CORS 限制需要代理服务器

---

## 10. 性能优化

### APK 优化
```bash
# 启用代码压缩
flutter build apk --release --split-per-abi

# 减少 APK 大小
flutter clean
flutter pub get
flutter build apk --release
```

### Web 优化
```bash
# 启用 PWA
flutter build web --pwa-init-timeout=10000

# 优化图片
flutter build web --web-renderer html
```

---

**如有问题，请查看 README.md 或提交 Issue**