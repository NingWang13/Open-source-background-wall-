import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/wallpaper.dart';
import '../../data/repositories/unsplash_api.dart';
import '../../data/repositories/pexels_api.dart';
import '../../core/services/favorites_service.dart';

/// 首页 - 壁纸列表
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
  
  // 分类筛选
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '自然', '城市', '动物', '艺术', '科技', '美女', '汽车'];
  
  // 排序选项
  String _sortBy = '推荐';
  final List<String> _sortOptions = ['推荐', '最新', '最热', '随机'];

  @override
  void initState() {
    super.initState();
    _initServices();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initServices() async {
    await FavoritesService.initialize();
    _loadWallpapers();
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

  Future<void> _loadWallpapers({bool append = false}) async {
    if (!append) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      List<Wallpaper> newWallpapers;
      
      // 根据排序选择
      switch (_sortBy) {
        case '最新':
          newWallpapers = await PexelsApi.getCuratedPhotos(page: _currentPage);
          break;
        case '最热':
          newWallpapers = await UnsplashApi.getRandomPhotos(page: _currentPage);
          break;
        case '随机':
          final unsplash = await UnsplashApi.getRandomPhotos(page: _currentPage);
          final pexels = await PexelsApi.getCuratedPhotos(page: _currentPage);
          newWallpapers = [...unsplash, ...pexels];
          newWallpapers.shuffle();
          break;
        default: // 推荐
          final unsplash = await UnsplashApi.getRandomPhotos(page: _currentPage);
          final pexels = await PexelsApi.getCuratedPhotos(page: _currentPage);
          newWallpapers = [...unsplash, ...pexels];
          newWallpapers.shuffle();
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
        title: const Text('🎨 Wallhaven'),
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
          // 分类筛选
          _buildCategoryFilter(),
          
          // 壁纸列表
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
                _refresh();
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无壁纸'),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
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
        // 双击快速收藏
        if (!FavoritesService.isFavorite(wallpaper.id)) {
          await FavoritesService.addToFavorites(wallpaper);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('已添加到收藏 💜'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      },
      child: Hero(
        tag: 'wallpaper_${wallpaper.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 缓存图片
              CachedNetworkImage(
                imageUrl: wallpaper.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: _getPlaceholderColor(wallpaper.id),
                  child: const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
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
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: wallpaper.source == 'unsplash' 
                        ? Colors.black87 
                        : Colors.blue.withOpacity(0.8),
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
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.4),
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
                            '${wallpaper.width}×${wallpaper.height}',
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

  Color _getPlaceholderColor(String id) {
    final colors = [
      Colors.blue[100]!,
      Colors.purple[100]!,
      Colors.pink[100]!,
      Colors.orange[100]!,
      Colors.green[100]!,
      Colors.teal[100]!,
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}
