import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../core/services/favorites_service.dart';

/// 壁纸卡片组件
/// 展示单张壁纸的缩略图、来源标签和作者信息
/// [Fix 9] 使用 API 返回的 dominant color 作为占位色，避免灰色闪烁
/// [Fix 9] memCacheWidth 限制内存缓存大小，防止 OOM
class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Hero(
        tag: 'wallpaper_${wallpaper.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // [Fix 9] 使用 dominant color 占位 + memCacheWidth 限制内存占用
              CachedNetworkImage(
                imageUrl: wallpaper.thumbnailUrl,
                fit: BoxFit.cover,
                memCacheWidth: 400, // 只缓存 400px 宽度，减少 50%+ 内存
                placeholder: (context, url) => Container(
                  color: _parseColor(wallpaper.color),
                ),
                fadeInDuration: const Duration(milliseconds: 200),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),

              // 来源标签
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: wallpaper.source == 'unsplash'
                        ? Colors.black54
                        : Colors.blue.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    wallpaper.source?.toUpperCase() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // 收藏状态
              if (FavoritesService.isFavorite(wallpaper.id))
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 14),
                  ),
                ),

              // 底部渐变遮罩
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    wallpaper.author,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [Fix 9] 将十六进制颜色字符串转换为 Color 对象
  Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        // 支持 #RRGGBB 和 RRGGBB 两种格式
        final hex = colorHex.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    // 回退到基于 ID 的随机色（与原逻辑一致）
    final colors = [
      Colors.blue[100]!,
      Colors.purple[100]!,
      Colors.pink[100]!,
      Colors.orange[100]!,
      Colors.green[100]!,
      Colors.teal[100]!,
    ];
    return colors[wallpaper.id.hashCode.abs() % colors.length];
  }
}
