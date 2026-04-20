import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../data/repositories/unsplash_api.dart';
import '../../data/repositories/pexels_api.dart';
import '../../core/services/search_history_service.dart';
import '../../core/services/favorites_service.dart';

/// 搜索页
/// [Fix 13] 搜索结果按 ID 去重
/// [Fix 14] 300ms 搜索防抖
class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  String _query = '';
  List<Wallpaper> _results = [];
  bool _isLoading = false;
  List<String> _searchHistory = [];
  int _currentPage = 1;
  bool _hasMore = true;

  // [Fix 14] 防抖计时器
  Timer? _debounceTimer;

  // 热门搜索词
  final List<String> _hotKeywords = [
    '自然', '城市', '森林', '海洋', '日落',
    '星空', '动物', '汽车', '美女', '科技',
    '艺术', '简约', '暗黑', '动漫', '游戏'
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _search(widget.initialQuery!);
    }

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadHistory() async {
    await SearchHistoryService.initialize();
    if (mounted) {
      setState(() => _searchHistory = SearchHistoryService.history);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  /// [Fix 14] 带防抖的搜索方法
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (value.trim().isNotEmpty) {
        _search(value.trim());
        _focusNode.unfocus();
      }
    });
  }

  void _onSubmit(String value) {
    _debounceTimer?.cancel();
    if (value.trim().isNotEmpty) {
      _search(value.trim());
      _focusNode.unfocus();
    }
  }

  /// [Fix 13] 搜索结果按 ID 去重
  Future<void> _search(String query, {bool loadMore = false}) async {
    if (query.isEmpty) return;

    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _query = query;
        _results = [];
        _currentPage = 1;
        _hasMore = true;
      });
      await SearchHistoryService.addToHistory(query);
      _loadHistory();
    } else {
      setState(() => _isLoading = true);
    }

    try {
      // [Fix 13] Future.wait 并行请求
      final rawResults = await Future.wait([
        UnsplashApi.searchPhotos(query, page: _currentPage),
        PexelsApi.searchPhotos(query, page: _currentPage),
      ]);

      final unsplashResults = rawResults[0];
      final pexelsResults = rawResults[1];

      final combined = [...unsplashResults, ...pexelsResults];

      // [Fix 13] 按 ID 去重
      final seenIds = <String>{};
      final dedupedResults = combined.where((w) {
        if (seenIds.contains(w.id)) return false;
        seenIds.add(w.id);
        return true;
      }).toList();

      setState(() {
        if (loadMore) {
          _results.addAll(dedupedResults);
        } else {
          _results = dedupedResults;
        }
        _isLoading = false;
        _hasMore = dedupedResults.isNotEmpty;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted && !loadMore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('搜索失败: $e'),
            action: SnackBarAction(
              label: '重试',
              onPressed: () => _search(query),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    _currentPage++;
    await _search(_query, loadMore: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: '搜索壁纸...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _onSubmit,
            textInputAction: TextInputAction.search,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return _buildSearchHome();
    }

    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('未找到 "$_query" 相关壁纸', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() => _query = '');
              },
              child: const Text('返回搜索首页'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '找到 ${_results.length} 张壁纸',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() => _results.shuffle());
                },
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('随机排序'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _ResponsiveSearchGrid(
            controller: _scrollController,
            itemCount: _results.length + (_isLoading || _hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _results.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _WallpaperCard(wallpaper: _results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索历史',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await SearchHistoryService.clearHistory();
                    _loadHistory();
                  },
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((q) => ActionChip(
                avatar: const Icon(Icons.history, size: 16),
                label: Text(q),
                onPressed: () {
                  _searchController.text = q;
                  _search(q);
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            '热门搜索',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hotKeywords.map((keyword) => ActionChip(
              label: Text(keyword),
              onPressed: () {
                _searchController.text = keyword;
                _search(keyword);
              },
            )).toList(),
          ),

          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '搜索技巧',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('使用英文关键词可以获得更多结果'),
                  _buildTip('尝试组合关键词如 "nature mountain"'),
                  _buildTip('双击壁纸卡片可快速收藏'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: TextStyle(color: Colors.grey[600])),
    );
  }
}

/// 响应式搜索结果网格
class _ResponsiveSearchGrid extends StatelessWidget {
  final ScrollController? controller;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _ResponsiveSearchGrid({
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
        await FavoritesService.toggleFavoriteOptimistic(wallpaper, (isFav) {});
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
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: wallpaper.thumbnailUrl,
                fit: BoxFit.cover,
                memCacheWidth: 400,
                placeholder: (context, url) => Container(
                  color: _getPlaceholderColor(wallpaper.color),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),

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
                    style: const TextStyle(color: Colors.white, fontSize: 11),
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

  Color _getPlaceholderColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return Colors.grey[200]!;
  }
}
