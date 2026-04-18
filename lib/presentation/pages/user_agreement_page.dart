import 'package:flutter/material.dart';

/// 用户协议页
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
用户协议

欢迎使用 Wallhaven 壁纸应用！

一、服务说明
本应用为用户提供免费壁纸浏览、搜索、下载和设置服务。

二、用户注册
1. 用户可选择注册账号或匿名使用
2. 注册用户可使用收藏、同步等功能
3. 用户应提供真实、准确的信息

三、用户行为规范
1. 不得利用本应用从事违法活动
2. 不得上传、传播违法内容
3. 不得干扰应用的正常运行

四、知识产权
1. 应用内的壁纸版权归原作者所有
2. 用户下载的壁纸仅供个人使用

五、隐私保护
我们重视用户隐私，具体请参阅隐私政策。

六、服务变更
我们保留随时修改或终止服务的权利。

七、联系我们
如有问题，请通过应用内的反馈功能联系我们。
''',
          style: TextStyle(height: 1.8),
        ),
      ),
    );
  }
}
