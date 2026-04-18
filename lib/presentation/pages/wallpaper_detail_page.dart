import 'package:flutter/material.dart';
import '../../data/models/wallpaper.dart';

/// 壁纸详情页
class WallpaperDetailPage extends StatelessWidget {
  final Wallpaper wallpaper;

  const WallpaperDetailPage({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wallpaper.author),
        actions: [
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
            // 图片预览
            AspectRatio(
              aspectRatio: wallpaper.aspectRatio,
              child: Image.network(
                wallpaper.url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 100),
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
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        wallpaper.author,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 分辨率
                  Row(
                    children: [
                      const Icon(Icons.aspect_ratio, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        wallpaper.resolutionText,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${wallpaper.width} x ${wallpaper.height}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('下载功能')),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('下载'),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已添加到收藏')),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('收藏'),
                  ),
                  
                  if (wallpaper.description != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '描述',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(wallpaper.description!),
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
