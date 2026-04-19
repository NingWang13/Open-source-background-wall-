import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/search_page.dart';
import '../../presentation/pages/favorites_page.dart';
import '../../presentation/pages/downloads_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/wallpaper_detail_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/disclaimer_page.dart';
import '../../presentation/pages/user_agreement_page.dart';
import '../../data/models/wallpaper.dart';

/// App Router Configuration using go_router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 主页面（底部导航）
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 首页
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // 搜索
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          // 收藏
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),
          // 下载
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/downloads',
                name: 'downloads',
                builder: (context, state) => const DownloadsPage(),
              ),
            ],
          ),
          // 设置
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      
      // 壁纸详情页
      GoRoute(
        path: '/wallpaper/:id',
        name: 'wallpaper-detail',
        builder: (context, state) {
          final wallpaper = state.extra as Wallpaper;
          return WallpaperDetailPage(wallpaper: wallpaper);
        },
      ),
      
      // 登录页
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // 免责声明
      GoRoute(
        path: '/disclaimer',
        name: 'disclaimer',
        builder: (context, state) => const DisclaimerPage(),
      ),
      
      // 用户协议
      GoRoute(
        path: '/user-agreement',
        name: 'user-agreement',
        builder: (context, state) => const UserAgreementPage(),
      ),
    ],
  );
}

/// Main Scaffold with Bottom Navigation
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: '下载',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
