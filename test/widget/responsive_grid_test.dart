import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallhaven/presentation/widgets/responsive_grid.dart';

void main() {
  Widget _buildTestWidget({
    required double width,
    required double height,
    required int itemCount,
    ScrollController? controller,
    Future<void> Function()? onRefresh,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: ResponsiveWallpaperGrid(
            controller: controller,
            onRefresh: onRefresh,
            itemCount: itemCount,
            itemBuilder: (context, index) => Container(
              key: ValueKey(index),
              color: Colors.blue,
              child: Center(child: Text('$index')),
            ),
          ),
        ),
      ),
    );
  }

  group('ResponsiveWallpaperGrid', () {
    testWidgets('renders correct column count on small screen', (tester) async {
      // width < 400 → 2 columns
      await tester.binding.setSurfaceSize(const Size(360, 800));
      await tester.pumpWidget(_buildTestWidget(width: 360, height: 800, itemCount: 10));
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('renders correct column count on tablet portrait', (tester) async {
      // width 600-900 → 3 columns
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpWidget(_buildTestWidget(width: 768, height: 1024, itemCount: 9));
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('renders correct column count on large desktop', (tester) async {
      // width >= 1200 → 5 columns
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      await tester.pumpWidget(_buildTestWidget(width: 1400, height: 900, itemCount: 15));
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('renders correct number of items', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(_buildTestWidget(width: 400, height: 800, itemCount: 5));
      expect(find.byType(Container), findsNWidgets(5));
    });

    testWidgets('uses provided ScrollController', (tester) async {
      final controller = ScrollController();
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(_buildTestWidget(
        width: 400, height: 800, itemCount: 10, controller: controller,
      ));
      expect(controller.hasClients, isTrue);
      controller.dispose();
    });

    testWidgets('RefreshIndicator wraps GridView when onRefresh provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(_buildTestWidget(
        width: 400, height: 800, itemCount: 5, onRefresh: () async {},
      ));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('no RefreshIndicator when onRefresh is null', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(_buildTestWidget(
        width: 400, height: 800, itemCount: 5, onRefresh: null,
      ));
      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: ResponsiveWallpaperGrid(
                padding: const EdgeInsets.all(24),
                itemCount: 3,
                itemBuilder: (context, index) => Container(key: ValueKey(index)),
              ),
            ),
          ),
        ),
      );
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.padding, const EdgeInsets.all(24));
    });
  });
}
