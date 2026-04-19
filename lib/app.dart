import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/router.dart';
import 'core/services/theme_service.dart';
import 'presentation/theme/app_theme.dart';

/// Main App Widget - 跨平台壁纸应用
class WallhavenApp extends ConsumerStatefulWidget {
  const WallhavenApp({super.key});

  @override
  ConsumerState<WallhavenApp> createState() => _WallhavenAppState();
}

class _WallhavenAppState extends ConsumerState<WallhavenApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await ThemeService.getThemeMode();
    if (mounted) {
      setState(() => _themeMode = mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wallhaven',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
