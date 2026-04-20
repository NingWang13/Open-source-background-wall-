import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../data/repositories/unsplash_api.dart';
import '../../data/repositories/pexels_api.dart';
import '../../core/services/favorites_service.dart';

/// 热门/趋势壁纸页
/// [NEW] 独立热门壁纸页，展示最受欢迎/最热门的壁纸
class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List<Wallpaper> _trending = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'likes'; // likes | downloads | recent

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTrending();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading && _hasMore) _loadMore();
    }
  }

  Future<void> _loadTrending({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait([
        UnsplashApi.getRandomPhotos(page: _currentPage, perPage: 20),
        PexelsApi.getCuratedPhotos(page: _currentPage, perPage: 20),
      ]);

      final all = [...results[0], ...results[1]];

      // 按排序规则排序
      final sorted = _sortWallpapers(all);

      // 去重
      final seenIds = <String>{};
      final deduped = sorted.where((w) {
        if (seenIds.contains(w.id)) return false;
        seenIds.add(w.id);
        return true;
      }).toList();

      setState(() {
        if (loadMore) {
          _trending.addAll(deduped);
        } else {
          _trending = deduped;
        }
        _isLoading = false;
        _hasMore = deduped.length >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    _currentPage++;
    await _loadTrending(loadMore: true);
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await _loadTrending();
  }

  List<Wallpaper> _sortWallpapers(List<Wallpaper> wallpapers) {
    switch (_sortBy) {
      case 'likes':
        wallpapers.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'downloads':
        wallpapers.sort((a, b) => b.downloads.compareTo(a.downloads));
        break;
      case 'recent':
        wallpapers.sort((a, b) {
          final aTime = a.createdAt ?? DateTime(2000);
          final bTime = b.createdAt ?? DateTime(2000);
          return bTime.compareTo(aTime);
        });
        break;
    }
    return wallpapers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 热门'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onSelected: (value) {
              setState(() => _sortBy = value);
              _refresh();
            },
            itemBuilder: (context) => [
              _buildSortMenuItem('likes', '👍 最多点赞'),
              _buildSortMenuItem('downloads', '📥 最多下载'),
              _buildSortMenuItem('recent', '🕐 最新发布'),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            _sortBy == value ? Icons.check : null,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _trending.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _trending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('加载失败', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (width < 400) {
            crossAxisCount = 2; childAspectRatio = 0.65;
          } else if (width < 600) {
            crossAxisCount = 2; childAspectRatio = 0.68;
          } else if (width < 900) {
            crossAxisCount = 3; childAspectRatio = 0.68;
          } else if (width < 1200) {
            crossAxisCount = 4; childAspectRatio = 0.70;
          } else {
            crossAxisCount = 5; childAspectRatio = 0.72;
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _trending.length + (_isLoading && _hasMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= _trending.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _TrendingCard(wallpaper: _trending[index]);
            },
          );
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Wallpaper wallpaper;

  const _TrendingCard({required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/wallpaper/${wallpaper.id}',
          arguments: wallpaper,
        );
      },
      onDoubleTap: () async {
        await FavoritesService.toggleFavoriteOptimistic(wallpaper, (isFav) {});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已添加到收藏 💜'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Hero(
        tag: 'wallpaper_${wallpaper.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: wallpaper.thumbnailUrl,
                fit: BoxFit.cover,
                memCacheWidth: 400,
                placeholder: (context, url) => Container(
                  color: _parseColor(wallpaper.color),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),

              // 热度标签
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${wallpaper.likes}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 来源
              Positioned(
                top: 6,
                right: 6,
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

              // 收藏
              if (FavoritesService.isFavorite(wallpaper.id))
                Positioned(
                  bottom: 36,
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

              // 底部信息
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          wallpaper.author,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (wallpaper.downloads > 0) ...[
                        const Icon(Icons.download, color: Colors.white70, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${wallpaper.downloads}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    final colors = [
      Colors.red[100]!, Colors.orange[100]!,
      Colors.amber[100]!, Colors.yellow[100]!,
    ];
    return colors[wallpaper.id.hashCode.abs() % colors.length];
  }
}
