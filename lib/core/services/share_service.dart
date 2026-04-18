/// 分享服务 - 简化版
class ShareService {
  ShareService._();

  /// 分享文本
  static Future<void> shareText(String text) async {
    // Web/Desktop: 复制到剪贴板
    // Mobile: 使用系统分享
    // TODO: 实现平台特定的分享功能
  }

  /// 分享壁纸链接
  static Future<void> shareWallpaperLink(String url, String author) async {
    final text = 'Check out this wallpaper by $author: $url';
    await shareText(text);
  }
}
