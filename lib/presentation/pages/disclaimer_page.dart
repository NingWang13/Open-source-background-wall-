import 'package:flutter/material.dart';

/// 免责声明页
class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('免责声明'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
免责声明

1. 本应用提供的壁纸均来自互联网公开资源（Unsplash、Pexels等），版权归原作者所有。

2. 本应用仅提供壁纸浏览和下载服务，不拥有任何壁纸的版权。

3. 用户在使用本应用时，应遵守相关法律法规，不得将壁纸用于商业用途或违法活动。

4. 本应用不对因使用壁纸而产生的任何纠纷承担责任。

5. 如有侵权，请联系我们删除相关内容。

6. 本应用保留最终解释权。
''',
          style: TextStyle(height: 1.8),
        ),
      ),
    );
  }
}
