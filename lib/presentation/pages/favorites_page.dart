import 'package:flutter/material.dart';

/// 收藏页
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
      ),
      body: const Center(
        child: Text('暂无收藏'),
      ),
    );
  }
}
