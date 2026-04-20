import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/wallpaper.dart';
import '../../core/services/download_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/wallpaper_service.dart';

/// 壁纸详情页
/// [Fix 4] 移除重复的 FavoritesService.initialize()
/// [Fix 6] 渐进式图片加载：先用缩略图快速展示，再加载全分辨率
class WallpaperDetailPage extends StatefulWidget {
  final Wallpaper wallpaper;

  const WallpaperDetailPage({super.key, required this.wallpaper});

  @override
  State<WallpaperDetailPage> createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage> {
  bool _isDownloading = false;
  bool _isFavorite = false;
  bool _isSettingWallpaper = false;
  bool _isLoadingHighRes = false; // [Fix 6] 标记是否正在加载高清图
  double _downloadProgress = 0;
  String? _downloadedPath;

  @override
  void initState() {
    super.initState();
    // [Fix 4] 直接读取状态，不重复初始化（main.dart 已初始化）
    _isFavorite = FavoritesService.isFavorite(widget.wallpaper.id);
    // [Fix 6] 延迟加载全分辨率图，快速展示缩略图
    _scheduleHighResLoad();
  }

  /// [Fix 6] 300ms 后预加载全分辨率图片
  void _scheduleHighResLoad() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isLoadingHighRes = true);
      }
    });
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    // [Fix 15] 乐观更新，无需等待存储
    await FavoritesService.toggleFavoriteOptimistic(
      widget.wallpaper,
      (isFav) {
        if (mounted) setState(() => _isFavorite = isFav);
      },
    );
    if (mounted) {
      _showSnackBar(
        _isFavorite ? '已添加到收藏' : '已取消收藏',
        _isFavorite ? Icons.favorite : Icons.favorite_border,
      );
    }
  }

  Future<void> _downloadWallpaper() async {
    if (_isDownloading) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final path = await DownloadService.downloadFile(
        widget.wallpaper.url,
        fileName: 'wallhaven_${widget.wallpaper.id}.jpg',
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadedPath = path;
        });
        _showSnackBar('下载完成', Icons.check_circle, action: SnackBarAction(
          label: '打开',
          onPressed: () => _openFile(path),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        _showSnackBar('下载失败: $e', Icons.error_outline, isError: true);
      }
    }
  }

  Future<void> _setAsWallpaper() async {
    if (_isSettingWallpaper) return;

    String imagePath;
    if (_downloadedPath != null) {
      imagePath = _downloadedPath!;
    } else {
      setState(() => _isSettingWallpaper = true);
      try {
        imagePath = await DownloadService.downloadFile(
          widget.wallpaper.url,
          fileName: 'wallhaven_${widget.wallpaper.id}.jpg',
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isSettingWallpaper = false);
          _showSnackBar('下载失败，无法设置壁纸', Icons.error_outline, isError: true);
        }
        return;
      }
    }

    try {
      await WallpaperService.setWallpaper(imagePath);
      if (mounted) {
        setState(() => _isSettingWallpaper = false);
        _showSnackBar('壁纸设置成功！', Icons.check_circle);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSettingWallpaper = false);
        _showSnackBar('设置失败: $e', Icons.error_outline, isError: true);
      }
    }
  }

  void _showSetWallpaperDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '设置壁纸',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('主屏幕'),
              subtitle: const Text('仅桌面壁纸'),
              onTap: () async {
                Navigator.pop(ctx);
                await WallpaperService.setWallpaper(
                  _downloadedPath ?? widget.wallpaper.url,
                  location: 1,
                );
                _showSnackBar('主屏幕壁纸设置成功！', Icons.check_circle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('锁屏'),
              subtitle: const Text('仅锁屏壁纸'),
              onTap: () async {
                Navigator.pop(ctx);
                await WallpaperService.setWallpaper(
                  _downloadedPath ?? widget.wallpaper.url,
                  location: 2,
                );
                _showSnackBar('锁屏壁纸设置成功！', Icons.check_circle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('全部'),
              subtitle: const Text('主屏幕 + 锁屏'),
              onTap: () async {
                Navigator.pop(ctx);
                _setAsWallpaper();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _shareWallpaper() async {
    try {
      await Share.share(
        '发现一张超棒的壁纸！\n\n作者: ${widget.wallpaper.author}\n分辨率: ${widget.wallpaper.width}x${widget.wallpaper.height}\n\n图片来源: ${widget.wallpaper.source?.toUpperCase()}',
        subject: 'Wallhaven 壁纸分享',
      );
    } catch (e) {
      _showSnackBar('分享失败: $e', Icons.error_outline, isError: true);
    }
  }

  void _showSnackBar(String message, IconData icon, {SnackBarAction? action, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: isError ? Colors.red : Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        action: action,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openFile(String path) {
    _showSnackBar('文件路径: $path', Icons.folder_open);
  }

  /// [Fix 6] 根据加载阶段返回对应的图片 URL
  String get _displayImageUrl {
    // 初始显示缩略图（快速），300ms 后切换为全分辨率（高质量）
    if (_isLoadingHighRes) {
      return widget.wallpaper.url;
    }
    return widget.wallpaper.thumbnailUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareWallpaper,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _showWallpaperInfo();
                  break;
                case 'refresh':
                  _downloadWallpaper();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('壁纸信息'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('重新下载'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // [Fix 6] 渐进式图片加载：先显示缩略图，再加载全分辨率
          GestureDetector(
            onTap: _showFullScreenImage,
            child: Hero(
              tag: 'wallpaper_${widget.wallpaper.id}',
              child: CachedNetworkImage(
                imageUrl: _displayImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (context, url) => Container(
                  color: _parseColor(widget.wallpaper.color),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
          ),

          // 底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              widget.wallpaper.author.isNotEmpty
                                  ? widget.wallpaper.author[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.wallpaper.author,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${widget.wallpaper.source?.toUpperCase() ?? 'UNKNOWN'} - ${widget.wallpaper.width}x${widget.wallpaper.height}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _DownloadButton(
                              isDownloading: _isDownloading,
                              progress: _downloadProgress,
                              hasDownloaded: _downloadedPath != null,
                              onPressed: _downloadWallpaper,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _downloadedPath != null
                                  ? _showSetWallpaperDialog
                                  : _setAsWallpaper,
                              icon: _isSettingWallpaper
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.wallpaper),
                              label: Text(_isSettingWallpaper ? '设置中...' : '设为壁纸'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey[900]!;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey[900]!;
    }
  }

  void _showFullScreenImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          wallpaper: widget.wallpaper,
        ),
      ),
    );
  }

  void _showWallpaperInfo() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '壁纸信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'ID', value: widget.wallpaper.id),
              _InfoRow(label: '作者', value: widget.wallpaper.author),
              _InfoRow(label: '来源', value: widget.wallpaper.source?.toUpperCase() ?? 'Unknown'),
              _InfoRow(label: '分辨率', value: '${widget.wallpaper.width} x ${widget.wallpaper.height}'),
              _InfoRow(label: '宽高比', value: widget.wallpaper.aspectRatioText),
              if (widget.wallpaper.likes > 0)
                _InfoRow(label: '点赞数', value: '${widget.wallpaper.likes}'),
              if (widget.wallpaper.downloads > 0)
                _InfoRow(label: '下载数', value: '${widget.wallpaper.downloads}'),
              if (widget.wallpaper.description != null) ...[
                const SizedBox(height: 8),
                const Text('描述:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  widget.wallpaper.description!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final bool isDownloading;
  final double progress;
  final bool hasDownloaded;
  final VoidCallback onPressed;

  const _DownloadButton({
    required this.isDownloading,
    required this.progress,
    required this.hasDownloaded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isDownloading) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            value: progress > 0 ? progress : null,
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
        label: Text('${(progress * 100).toInt()}%'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(hasDownloaded ? Icons.check : Icons.download),
      label: Text(hasDownloaded ? '已下载' : '下载'),
      style: ElevatedButton.styleFrom(
        backgroundColor: hasDownloaded ? Colors.green : Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

/// 全屏图片查看器
class _FullScreenImageViewer extends StatelessWidget {
  final Wallpaper wallpaper;

  const _FullScreenImageViewer({required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                '发现一张超棒的壁纸！\n\n作者: ${wallpaper.author}\n分辨率: ${wallpaper.width}x${wallpaper.height}',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                await DownloadService.downloadFile(wallpaper.url);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('下载成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('下载失败: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: wallpaper.url,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image,
              size: 100,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
