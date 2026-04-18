# Wallhaven 开发文档

## 功能规格

### 核心功能

1. **壁纸浏览**
   - 瀑布流展示在线壁纸
   - 分类筛选（自然、建筑、科技、动物等）
   - 颜色筛选
   - 分辨率筛选

2. **搜索功能**
   - 本地壁纸搜索
   - 在线 API 搜索（Unsplash、Pexels）
   - 全网图片搜索（自定义实现）
   - 搜索历史记录

3. **收藏功能**
   - 点击白色空星五角星收藏
   - 收藏列表管理
   - 取消收藏

4. **下载功能**
   - 支持原画质、2K、4K 下载
   - 下载进度显示
   - 下载历史管理

5. **设置壁纸**
   - 一键设置为桌面壁纸
   - 自动更换壁纸（定时）

6. **用户系统**
   - 邮箱+密码登录
   - 第三方登录（微信、GitHub、Google）
   - 用户数据同步

7. **法律合规**
   - 免责声明页面
   - 用户协议页面
   - 首次启动强制显示

## API 设计

### Unsplash API

```dart
// 获取随机壁纸
GET /photos/random?count=30&client_id=YOUR_ACCESS_KEY

// 搜索壁纸
GET /search/photos?query=nature&per_page=30&client_id=YOUR_ACCESS_KEY

// 获取图片详情
GET /photos/:id?client_id=YOUR_ACCESS_KEY
```

### Pexels API

```dart
// 获取精选壁纸
GET /curated?per_page=30
Headers: Authorization: YOUR_API_KEY

// 搜索壁纸
GET /search?query=nature&per_page=30
Headers: Authorization: YOUR_API_KEY
```

## 数据库结构

### Hive Boxes

```dart
// 收藏
Box<Wallpaper> favoritesBox

// 下载记录
Box<DownloadRecord> downloadsBox

// 用户设置
Box<UserSettings> settingsBox

// 搜索历史
Box<List<String>> searchHistoryBox
```

### 数据模型

```dart
class Wallpaper {
  String id;
  String url;
  String thumbnailUrl;
  String author;
  String authorUrl;
  int width;
  int height;
  String? description;
  String? color;
  List<String> tags;
  int likes;
  int downloads;
  DateTime createdAt;
  String source; // 'unsplash', 'pexels', 'local'
}

class UserSettings {
  bool autoChangeEnabled;
  int autoChangeInterval;
  bool darkMode;
  bool wifiOnly;
  String downloadPath;
  String? defaultResolution;
}
```

## UI 设计规范

### 主题色

- 主色：`#6C63FF` (紫色)
- 辅色：`#00BFA6` (青绿色)
- 强调色：`#FF6584` (粉红色)
- 深色背景：`#1A1A2E`
- 深色表面：`#16213E`

### 收藏按钮

- 图标：`Icons.star_border` (白色空星)
- 选中状态：`Icons.star` (填充黄色)
- 位置：壁纸卡片右下角

### 分辨率选择

- 选项：原画质、2K、4K
- 样式：ChoiceChip
- 默认：原画质

## 待办事项

### 高优先级

- [ ] 集成 Unsplash API
- [ ] 集成 Pexels API
- [ ] 实现壁纸下载功能
- [ ] 实现设置壁纸功能（各平台）
- [ ] 实现收藏功能
- [ ] 实现搜索功能

### 中优先级

- [ ] 实现自动更换壁纸
- [ ] 集成 Firebase 认证
- [ ] 实现第三方登录
- [ ] 添加深色模式
- [ ] 优化图片加载和缓存

### 低优先级

- [ ] 添加动画效果
- [ ] 实现壁纸裁剪功能
- [ ] 添加统计功能
- [ ] 支持更多壁纸源
- [ ] 添加用户反馈功能

## 平台特定实现

### Windows

- 使用 `win32` 包设置壁纸
- 注册表操作实现自动更换

### macOS

- 使用 `osascript` 设置壁纸
- `launchd` 实现定时任务

### Linux

- 使用 `gsettings` 或 `feh` 设置壁纸
- `cron` 实现定时任务

### iOS/Android

- 使用平台通道调用原生 API
- WorkManager/Background Fetch 实现定时任务

### HarmonyOS

- 参考 Flutter 鸿蒙社区支持
- 使用鸿蒙特定 API