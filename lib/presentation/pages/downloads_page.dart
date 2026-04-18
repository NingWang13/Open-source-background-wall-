import 'package:flutter/material.dart';

/// 下载页
class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的下载'),
      ),
      body: const Center(
        child: Text('暂无下载记录'),
      ),
    );
  }
}
