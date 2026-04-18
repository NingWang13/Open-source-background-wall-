import 'package:flutter/material.dart';
import '../../data/models/wallpaper.dart';
import '../../data/repositories/unsplash_api.dart';
import '../../data/repositories/pexels_api.dart';

/// 首页 - 壁纸列表
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Wallpaper> _wallpapers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }

  Future<void> _loadWallpapers() async {
    setState(() => _isLoading = true);
    
    try {
      // 加载 Unsplash 和 Pexels 壁纸
      final unsplashPhotos = await UnsplashApi.getRandomPhotos();
      final pexelsPhotos = await PexelsApi.getCuratedPhotos();
      
      setState(() {
        _wallpapers = [...unsplashPhotos, ...pexelsPhotos];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallhaven'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wallpapers.isEmpty
              ? const Center(child: Text('暂无壁纸'))
              : RefreshIndicator(
                  onRefresh: _loadWallpapers,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _wallpapers.length,
                    itemBuilder: (context, index) {
                      final wallpaper = _wallpapers[index];
                      return _WallpaperCard(wallpaper: wallpaper);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadWallpapers,
        child: const Icon(Icons.refresh),
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
            Image.network(
              wallpaper.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50),
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
