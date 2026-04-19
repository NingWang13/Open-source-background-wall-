import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../data/repositories/unsplash_api.dart';
import '../../data/repositories/pexels_api.dart';
import '../../core/services/search_history_service.dart';

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
  String _query = '';
  List<Wallpaper> _results = [];
  bool _isLoading = false;
  List<String> _searchHistory = [];
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _search(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    // 初始化服务
    await SearchHistoryService.initialize();
    final history = SearchHistoryService.history;
    if (mounted) {
      setState(() => _searchHistory = history);
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
      final unsplashResults = await UnsplashApi.searchPhotos(query, page: _currentPage);
      final pexelsResults = await PexelsApi.searchPhotos(query, page: _currentPage);
      
      final newResults = [...unsplashResults, ...pexelsResults];
      
      setState(() {
        _results.addAll(newResults);
        _isLoading = false;
        _hasMore = newResults.isNotEmpty;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
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
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: '搜索壁纸...',
            border: InputBorder.none,
          ),
          onSubmitted: (value) => _search(value),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_searchController.text),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return _buildSearchHistory();
    }
    
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('未找到 "$_query" 相关壁纸'),
          ],
        ),
      );
    }
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _results.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _results.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return _WallpaperCard(wallpaper: _results[index]);
        },
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Padding(
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
                  style: Theme.of(context).textTheme.titleMedium,
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((q) => ActionChip(
                label: Text(q),
                onPressed: () {
                  _searchController.text = q;
                  _search(q);
                },
              )).toList(),
            ),
          ] else ...[
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('输入关键词搜索壁纸'),
                ],
              ),
            ),
          ],
        ],
      ),
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
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
