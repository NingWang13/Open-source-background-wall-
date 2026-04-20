import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallhaven/data/models/wallpaper.dart';
import 'package:wallhaven/presentation/widgets/wallpaper_card.dart';

void main() {
  Wallpaper _makeWallpaper({
    String id = 'test_1',
    String source = 'unsplash',
    String author = 'Test Author',
    String color = '#1a2b3c',
  }) =>
      Wallpaper(
        id: id,
        url: 'https://example.com/$id.jpg',
        thumbnailUrl: 'https://example.com/$id.thumb.jpg',
        author: author,
        authorUrl: 'https://example.com',
        width: 1920,
        height: 1080,
        source: source,
        color: color,
      );

  Widget _buildTestWidget({
    required Wallpaper wallpaper,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 300,
          child: WallpaperCard(
            wallpaper: wallpaper,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
          ),
        ),
      ),
    );
  }

  group('WallpaperCard Widget', () {
    testWidgets('displays author name', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(wallpaper: _makeWallpaper(author: 'Jane Doe')),
      );

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('displays source label for unsplash', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(wallpaper: _makeWallpaper(source: 'unsplash')),
      );

      expect(find.text('UNSPLASH'), findsOneWidget);
    });

    testWidgets('displays source label for pexels', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(wallpaper: _makeWallpaper(source: 'pexels')),
      );

      expect(find.text('PEXELS'), findsOneWidget);
    });

    testWidgets('onTap callback is called when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _buildTestWidget(
          wallpaper: _makeWallpaper(),
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(WallpaperCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onDoubleTap callback is called', (tester) async {
      bool doubleTapped = false;

      await tester.pumpWidget(
        _buildTestWidget(
          wallpaper: _makeWallpaper(),
          onDoubleTap: () => doubleTapped = true,
        ),
      );

      // Perform double tap (two quick taps)
      await tester.tap(find.byType(WallpaperCard));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(WallpaperCard));
      // [Fix] 等待双击计时器完成，避免 pending timer 错误
      await tester.pumpAndSettle();

      expect(doubleTapped, isTrue);
    });

    testWidgets('renders with Hero widget', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(wallpaper: _makeWallpaper(id: 'hero_test')),
      );

      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('Hero tag contains wallpaper id', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(wallpaper: _makeWallpaper(id: 'unique_123')),
      );

      final heroFinder = find.byType(Hero);
      expect(heroFinder, findsOneWidget);

      final hero = tester.widget<Hero>(heroFinder);
      expect(hero.tag, 'wallpaper_unique_123');
    });

    testWidgets('renders without crashing when color is null', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          wallpaper: _makeWallpaper(color: ''),
        ),
      );

      expect(find.byType(WallpaperCard), findsOneWidget);
    });

    testWidgets('renders without crashing when color is invalid', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          wallpaper: _makeWallpaper(color: 'not_a_color'),
        ),
      );

      expect(find.byType(WallpaperCard), findsOneWidget);
    });
  });
}
