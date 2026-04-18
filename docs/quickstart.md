# Wallhaven 快速开始指南

## 1. 获取 API 密钥

### Unsplash API Key
1. 访问 https://unsplash.com/developers
2. 注册/登录账号
3. 创建新应用
4. 复制 Access Key

### Pexels API Key
1. 访问 https://www.pexels.com/api/
2. 注册/登录账号
3. 申请 API 密钥
4. 复制 API Key

## 2. 配置 API 密钥

编辑文件：`lib/core/constants/app_constants.dart`

```dart
// 替换为你的 API 密钥
static const String unsplashAccessKey = 'YOUR_UNSPLASH_ACCESS_KEY_HERE';
static const String pexelsApiKey = 'YOUR_PEXELS_API_KEY_HERE';
```

## 3. 安装依赖

```bash
cd wallpaper_app
flutter pub get
```

## 4. 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 5. 运行应用

```bash
# 开发模式
flutter run

# 或指定设备
flutter run -d windows
flutter run -d android
flutter run -d ios
```

## 6. 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## 常见问题

### Q: API 请求失败？
A: 检查 API 密钥是否正确配置，网络连接是否正常。

### Q: 无法下载壁纸？
A: 确保已授予存储权限（Android）。

### Q: 无法设置壁纸？
A: 
- Android: 检查权限
- iOS: 只能保存到相册，需手动设置
- Windows/macOS: 确保平台通道正常工作

### Q: 图片加载慢？
A: 使用 cached_network_image 包，已配置在依赖中。

## 项目结构

```
wallpaper_app/
├── android/          # Android 原生代码
├── ios/              # iOS 原生代码
├── windows/          # Windows 原生代码
├── lib/              # Dart 代码
│   ├── core/         # 核心服务
│   ├── data/         # 数据层
│   ├── domain/       # 领域层
│   └── presentation/ # UI 层
├── assets/           # 资源文件
└── docs/             # 文档
```

## 功能清单

- ✅ 在线壁纸浏览（Unsplash + Pexels）
- ✅ 壁纸搜索
- ✅ 多分辨率下载
- ✅ 设置壁纸
- ✅ 收藏管理
- ✅ 下载管理
- ✅ 深色主题
- ✅ 跨平台支持

## 联系方式

- GitHub: https://github.com/yourusername/wallhaven
- Email: support@wallhaven.app

---

Enjoy your wallpapers! 🎉