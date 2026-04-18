# Wallhaven App 测试指南

## 环境要求

### 必需
- Windows 10/11 或 macOS 或 Linux
- Flutter SDK 3.x
- Dart SDK (随 Flutter 安装)
- Git

### 可选（用于特定平台）
- Android Studio (Android 开发)
- Xcode (iOS/macOS 开发)
- Visual Studio 2022 (Windows 桌面开发)

## 安装 Flutter

### 方法 1：使用 Chocolatey (推荐，需要管理员权限)
```powershell
# 以管理员身份运行 PowerShell
choco install flutter
```

### 方法 2：手动安装
1. 下载 Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. 解压到 `C:\flutter`
3. 添加环境变量：`C:\flutter\bin`
4. 运行 `flutter doctor` 检查安装

## 快速测试步骤

### 1. 配置 API 密钥

编辑 `lib/core/constants/app_constants.dart`：

```dart
class AppConstants {
  // Unsplash API Key
  // 获取地址: https://unsplash.com/developers
  static const String unsplashAccessKey = 'YOUR_UNSPLASH_API_KEY';
  
  // Pexels API Key
  // 获取地址: https://www.pexels.com/api/
  static const String pexelsApiKey = 'YOUR_PEXELS_API_KEY';
}
```

### 2. 安装依赖

```bash
cd wallpaper_app
flutter pub get
```

### 3. 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. 运行应用

#### Windows 桌面
```bash
flutter run -d windows
```

#### Android (需要连接设备或模拟器)
```bash
flutter run -d android
```

#### Web
```bash
flutter run -d chrome
# 或
flutter run -d edge
```

#### 列出可用设备
```bash
flutter devices
```

## 构建发布版本

### Windows
```bash
flutter build windows --release
```
输出：`build/windows/x64/runner/Release/wallpaper_app.exe`

### Android
```bash
flutter build apk --release
```
输出：`build/app/outputs/flutter-apk/app-release.apk`

### Web
```bash
flutter build web --release
```
输出：`build/web/`

## 使用构建脚本

直接运行 `build_app.bat`：

```bash
build_app.bat
```

脚本会自动：
1. 检查 Flutter 安装
2. 安装依赖
3. 生成代码
4. 分析代码
5. 构建或运行应用

## 常见问题

### 1. 权限不足
**问题**: `choco install flutter` 失败
**解决**: 以管理员身份运行 PowerShell 或 CMD

### 2. API 限制
**问题**: 图片加载失败
**解决**: 
- 申请 Unsplash/Pexels API Key
- 或使用测试数据

### 3. 构建失败
**问题**: `flutter build windows` 失败
**解决**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
flutter build windows
```

### 4. 缺少 Visual Studio
**问题**: Windows 构建需要 Visual Studio
**解决**: 安装 Visual Studio 2022，选择 "Desktop development with C++" 工作负载

## 功能测试清单

### 首页
- [ ] 精选壁纸显示
- [ ] 分类快速浏览
- [ ] 瀑布流加载
- [ ] 下拉刷新
- [ ] 底部导航

### 详情页
- [ ] 图片加载
- [ ] 缩放功能
- [ ] 下载功能
- [ ] 设置壁纸
- [ ] 收藏功能
- [ ] 分享功能

### 搜索页
- [ ] 搜索输入
- [ ] 搜索历史
- [ ] 热门搜索
- [ ] 分类浏览
- [ ] 结果展示

### 收藏页
- [ ] 收藏列表
- [ ] 取消收藏
- [ ] 点击进入详情

### 下载页
- [ ] 下载记录
- [ ] 设置壁纸
- [ ] 删除记录

### 设置页
- [ ] 用户信息
- [ ] 自动更换设置
- [ ] 主题切换
- [ ] 关于页面

### 登录页
- [ ] 邮箱登录
- [ ] 注册功能
- [ ] 第三方登录

## 调试技巧

### 查看日志
```bash
flutter run --verbose
```

### 热重载
按 `r` 键热重载代码

### 热重启
按 `R` 键完全重启应用

### 性能分析
```bash
flutter run --profile
```

## 模拟数据测试

如果不想配置 API，可以使用模拟数据：

编辑 `lib/data/repositories/mock_api.dart`：

```dart
class MockApi {
  static List<Wallpaper> getMockWallpapers() {
    return [
      Wallpaper(
        id: '1',
        url: 'https://via.placeholder.com/1920x1080',
        thumbnailUrl: 'https://via.placeholder.com/400x600',
        author: 'Test Author',
        width: 1920,
        height: 1080,
        source: 'Mock',
      ),
      // 更多数据...
    ];
  }
}
```

然后在 `home_page.dart` 中使用模拟数据。

## 联系支持

如有问题，请提交 Issue 到 GitHub 仓库。