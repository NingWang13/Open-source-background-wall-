import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../data/repositories/unsplash_api.dart';
import '../../data/repositories/pexels_api.dart';
import '../../data/repositories/wallpaper_classifier.dart'; // [Fix Bug 5]
import '../../core/services/favorites_service.dart';

/// 首页 - 壁纸列表
/// [Fix 3] API 串行改并行
/// [Fix 4] 移除重复 FavoritesService.initialize()
/// [Fix Bug 5] 实现真实分类过滤逻辑
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Wallpaper> _wallpapers = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  // 分类筛选 - [Fix Bug 5] 已实现真实过滤
  String _selectedCategory = '全部';

  // 排序选项
  String _sortBy = '推荐';
  final List<String> _sortOptions = ['推荐', '最新', '最热', '随机'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadWallpapers(); // [Fix 4] 不再调用 FavoritesService.initialize()
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading && _wallpapers.isNotEmpty) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    _currentPage++;
    await _loadWallpapers(append: true);
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await _loadWallpapers();
  }

  /// [Fix 3] 使用 Future.wait 并行请求两个 API
  /// [Fix Bug 5] 分类过滤在结果合并后执行
  Future<void> _loadWallpapers({bool append = false}) async {
    if (!append) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      List<Wallpaper> newWallpapers;

      switch (_sortBy) {
        case '最新':
          newWallpapers = await PexelsApi.getCuratedPhotos(page: _currentPage);
          break;
        case '最热':
          newWallpapers = await UnsplashApi.getRandomPhotos(page: _currentPage);
          break;
        case '随机':
          final results = await Future.wait([
            UnsplashApi.getRandomPhotos(page: _currentPage),
            PexelsApi.getCuratedPhotos(page: _currentPage),
          ]);
          newWallpapers = [...results[0], ...results[1]];
          newWallpapers.shuffle();
          break;
        default:
          // [Fix 3] 推荐 → Future.wait 并行
          final results = await Future.wait([
            UnsplashApi.getRandomPhotos(page: _currentPage),
            PexelsApi.getCuratedPhotos(page: _currentPage),
          ]);
          newWallpapers = [...results[0], ...results[1]];
          newWallpapers.shuffle();
      }

      // [Fix Bug 5] 分类过滤（合并结果后执行）
      if (_selectedCategory != '全部') {
        newWallpapers = WallpaperClassifier.filter(newWallpapers, _selectedCategory);
      }

      setState(() {
        if (append) {
          _wallpapers.addAll(newWallpapers);
        } else {
          _wallpapers = newWallpapers;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.map((option) {
            return ListTile(
              leading: Icon(
                option == _sortBy ? Icons.check_circle : Icons.circle_outlined,
                color: option == _sortBy ? Theme.of(context).primaryColor : null,
              ),
              title: Text(option),
              onTap: () {
                setState(() => _sortBy = option);
                Navigator.pop(ctx);
                _refresh();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallhaven'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: '排序: $_sortBy',
            onPressed: _showSortMenu,
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: '随机',
            onPressed: () {
              setState(() => _sortBy = '随机');
              _refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  /// [Fix Bug 5] 分类筛选 - 点击时触发真实过滤
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: WallpaperClassifier.categories.length,
        itemBuilder: (context, index) {
          final category = WallpaperClassifier.categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
                _refresh(); // [Fix Bug 5] 重新加载过滤结果
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _wallpapers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _wallpapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('加载失败', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
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

    if (_wallpapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('该分类暂无壁纸'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: _ResponsiveWallpaperGrid(
        controller: _scrollController,
        itemCount: _wallpapers.length + (_isLoading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= _wallpapers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _WallpaperCard(wallpaper: _wallpapers[index]);
        },
      ),
    );
  }
}

/// 响应式壁纸网格 - [Fix 7] 根据屏幕宽度动态调整列数
class _ResponsiveWallpaperGrid extends StatelessWidget {
  final ScrollController? controller;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _ResponsiveWallpaperGrid({
    this.controller,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        if (width < 400) {
          crossAxisCount = 2;
          childAspectRatio = 0.65;
        } else if (width < 600) {
          crossAxisCount = 2;
          childAspectRatio = 0.68;
        } else if (width < 900) {
          crossAxisCount = 3;
          childAspectRatio = 0.68;
        } else if (width < 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.70;
        } else {
          crossAxisCount = 5;
          childAspectRatio = 0.72;
        }

        return GridView.builder(
          controller: controller,
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class _WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;

  const _WallpaperCard({required this.wallpaper});

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
        // [Fix 15] 乐观更新：立即响应，无需等待存储
        await FavoritesService.toggleFavoriteOptimistic(
          wallpaper,
          (isFav) {}, // 乐观更新，UI 已在内存中更新
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已添加到收藏'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Hero(
        tag: 'wallpaper_${wallpaper.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // [Fix 9] 使用 color placeholder 避免灰色闪烁
              CachedNetworkImage(
                imageUrl: wallpaper.thumbnailUrl,
                fit: BoxFit.cover,
                memCacheWidth: 400, // [Fix 9] 限制内存缓存大小
                placeholder: (context, url) => Container(
                  color: _getPlaceholderColor(wallpaper.color),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),

              // 来源标签
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: wallpaper.source == 'unsplash'
                        ? Colors.black87
                        : Colors.blue.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    wallpaper.source?.toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // 收藏状态
              if (FavoritesService.isFavorite(wallpaper.id))
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                  ),
                ),

              // 底部信息
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallpaper.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.aspect_ratio, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${wallpaper.width}x${wallpaper.height}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
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

  /// [Fix 9] 使用 API 返回的 dominant color 作为占位色
  Color _getPlaceholderColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
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
