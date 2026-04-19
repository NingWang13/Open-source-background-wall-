import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../data/repositories/unsplash_api.dart';
import '../../data/repositories/pexels_api.dart';
import '../../core/services/search_history_service.dart';
import '../../core/services/favorites_service.dart';

/// 搜索页
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
  
  // 热门搜索词
  final List<String> _hotKeywords = [
    '自然', '城市', '森林', '海洋', '日落', 
    '星空', '动物', '汽车', '美女', '科技',
    '艺术', '简约', '暗黑', '动漫', '游戏'
  ];

  @override
  void initState() {
    super.initState();
    _initServices();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _search(widget.initialQuery!);
    }
    
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initServices() async {
    await FavoritesService.initialize();
    await SearchHistoryService.initialize();
    await _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    final history = SearchHistoryService.history;
    if (mounted) {
      setState(() => _searchHistory = history);
    }
  }

  @override
  void dispose() {
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
      // 并行请求两个 API
      final results = await Future.wait([
        UnsplashApi.searchPhotos(query, page: _currentPage),
        PexelsApi.searchPhotos(query, page: _currentPage),
      ]);
      
      final unsplashResults = results[0] as List<Wallpaper>;
      final pexelsResults = results[1] as List<Wallpaper>;
      
      final newResults = [...unsplashResults, ...pexelsResults];
      
      setState(() {
        if (loadMore) {
          _results.addAll(newResults);
        } else {
          _results = newResults;
        }
        _isLoading = false;
        _hasMore = newResults.isNotEmpty;
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

  void _onSubmit(String value) {
    if (value.trim().isNotEmpty) {
      _search(value.trim());
      _focusNode.unfocus();
    }
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
            onChanged: (_) => setState(() {}),
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
        // 搜索结果统计
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
                  setState(() {
                    _results.shuffle();
                  });
                },
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('随机排序'),
              ),
            ],
          ),
        ),
        
        // 结果列表
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
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
          // 热门搜索
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📜 搜索历史',
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
          
          // 热门关键词
          Text(
            '🔥 热门搜索',
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
          
          // 搜索提示
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
                        '💡 搜索技巧',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('• 使用英文关键词可以获得更多结果'),
                  _buildTip('• 尝试组合关键词如 "nature mountain"'),
                  _buildTip('• 双击壁纸卡片可快速收藏'),
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
        if (!FavoritesService.isFavorite(wallpaper.id)) {
          await FavoritesService.addToFavorites(wallpaper);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('已添加到收藏 💜'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
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
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
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
                        : Colors.blue.withOpacity(0.8),
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
                        Colors.black.withOpacity(0.8),
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
}
