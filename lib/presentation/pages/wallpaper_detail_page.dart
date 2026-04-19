import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../core/services/download_service.dart';
import '../../core/services/favorites_service.dart';

/// 壁纸详情页
class WallpaperDetailPage extends StatefulWidget {
  final Wallpaper wallpaper;

  const WallpaperDetailPage({super.key, required this.wallpaper});

  @override
  State<WallpaperDetailPage> createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage> {
  bool _isDownloading = false;
  bool _isFavorite = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    // 初始化服务
    await FavoritesService.initialize();
    final fav = FavoritesService.isFavorite(widget.wallpaper.id);
    if (mounted) {
      setState(() => _isFavorite = fav);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoritesService.removeFromFavorites(widget.wallpaper.id);
      if (mounted) {
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消收藏')),
        );
      }
    } else {
      await FavoritesService.addToFavorites(widget.wallpaper);
      if (mounted) {
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已添加到收藏')),
        );
      }
    }
  }

  Future<void> _downloadWallpaper() async {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final path = await DownloadService.downloadFile(
        widget.wallpaper.url,
        fileName: 'wallhaven_${widget.wallpaper.id}.jpg',
        onProgress: (received, total) {
          if (total > 0) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('下载完成: $path'),
            action: SnackBarAction(
              label: '打开',
              onPressed: () {
                // 打开文件
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallpaper.author),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片预览 - 使用缓存
            Hero(
              tag: 'wallpaper_${widget.wallpaper.id}',
              child: AspectRatio(
                aspectRatio: widget.wallpaper.aspectRatio,
                child: CachedNetworkImage(
                  imageUrl: widget.wallpaper.url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作者信息
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.wallpaper.author,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (widget.wallpaper.source?.isNotEmpty ?? false)
                              Text(
                                widget.wallpaper.source!.toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 分辨率信息
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.aspect_ratio, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.wallpaper.resolutionText,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${widget.wallpaper.width} × ${widget.wallpaper.height}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (widget.wallpaper.likes > 0 || widget.wallpaper.downloads > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (widget.wallpaper.likes > 0)
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text('${widget.wallpaper.likes}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (widget.wallpaper.downloads > 0) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.download, size: 16),
                                    const SizedBox(width: 4),
                                    Text('${widget.wallpaper.downloads}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDownloading ? null : _downloadWallpaper,
                          icon: _isDownloading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.download),
                          label: Text(_isDownloading 
                              ? '${(_downloadProgress * 100).toInt()}%'
                              : '下载'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('设置壁纸功能')),
                            );
                          },
                          icon: const Icon(Icons.wallpaper),
                          label: const Text('设为壁纸'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 收藏按钮
                  OutlinedButton.icon(
                    onPressed: _toggleFavorite,
                    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                    label: Text(_isFavorite ? '取消收藏' : '收藏'),
                  ),
                  
                  if (widget.wallpaper.description != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '描述',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.wallpaper.description!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
