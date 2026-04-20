import 'package:flutter/material.dart';

/// 响应式壁纸网格视图
/// 根据屏幕宽度自动调整列数和宽高比
/// [Fix 7] 适配手机、平板、桌面等多种屏幕尺寸
class ResponsiveWallpaperGrid extends StatelessWidget {
  /// 壁纸总数
  final int itemCount;
  /// 构建每个网格项
  final Widget Function(BuildContext, int) itemBuilder;
  /// 滚动控制器（可选）
  final ScrollController? controller;
  /// 下拉刷新回调（可选）
  final Future<void> Function()? onRefresh;
  /// 内边距
  final EdgeInsetsGeometry padding;

  const ResponsiveWallpaperGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.onRefresh,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        // [Fix 7] 根据可用宽度动态计算列数和宽高比
        if (width < 400) {
          // 小屏手机（< 400pt）
          crossAxisCount = 2;
          childAspectRatio = 0.65;
        } else if (width < 600) {
          // 普通/大屏手机
          crossAxisCount = 2;
          childAspectRatio = 0.68;
        } else if (width < 900) {
          // 平板竖屏
          crossAxisCount = 3;
          childAspectRatio = 0.68;
        } else if (width < 1200) {
          // 平板横屏 / 小桌面
          crossAxisCount = 4;
          childAspectRatio = 0.70;
        } else {
          // 大桌面 / 带鱼屏
          crossAxisCount = 5;
          childAspectRatio = 0.72;
        }

        final grid = GridView.builder(
          controller: controller,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );

        // 包装 RefreshIndicator 实现下拉刷新
        if (onRefresh != null) {
          return RefreshIndicator(
            onRefresh: onRefresh!,
            child: grid,
          );
        }
        return grid;
      },
    );
  }
}
