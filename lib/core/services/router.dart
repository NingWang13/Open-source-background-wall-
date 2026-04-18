import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/wallpaper_detail_page.dart';
import '../../presentation/pages/search_page.dart';
import '../../presentation/pages/favorites_page.dart';
import '../../presentation/pages/downloads_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/disclaimer_page.dart';
import '../../presentation/pages/user_agreement_page.dart';
import '../../data/models/wallpaper.dart';

/// App Router Configuration - 跨平台路由配置
/// 支持移动端和桌面端
final router = GoRouter(
  initialLocation: '/',
  routes: [
    // 首页
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    
    // 壁纸详情
    GoRoute(
      path: '/wallpaper/:id',
      name: 'wallpaper-detail',
      builder: (context, state) {
        final wallpaper = state.extra as Wallpaper?;
        if (wallpaper == null) {
          // 如果没有传递 wallpaper，返回首页
          return const HomePage();
        }
        return WallpaperDetailPage(wallpaper: wallpaper);
      },
    ),
    
    // 搜索
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return SearchPage(initialQuery: query);
      },
    ),
    
    // 收藏
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    
    // 下载
    GoRoute(
      path: '/downloads',
      name: 'downloads',
      builder: (context, state) => const DownloadsPage(),
    ),
    
    // 设置
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    
    // 登录
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

/// Shell Route for scaffold with navigation
/// 提供统一的导航脚手架，支持移动端和桌面端
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/favorites');
              break;
            case 3:
              context.go('/downloads');
              break;
            case 4:
              context.go('/settings');
              break;
          }
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

/// Responsive layout helper
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 1200;
  
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && desktopBody != null) {
          return desktopBody!;
        }
        if (constraints.maxWidth >= 600 && tabletBody != null) {
          return tabletBody!;
        }
        return mobileBody;
      },
    );
  }
}