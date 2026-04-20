import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/favorites_service.dart';
import 'core/services/downloads_service.dart';
import 'core/services/collections_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化所有服务（并行）
  await Future.wait([
    FavoritesService.initialize(),
    DownloadsService.initialize(),
    CollectionsService.initialize(),
  ]);

  runApp(const ProviderScope(child: WallhavenApp()));
}
