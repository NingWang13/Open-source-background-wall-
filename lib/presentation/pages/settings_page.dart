import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

/// 设置页
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 用户信息
          ListTile(
            leading: CircleAvatar(
              child: Icon(user != null ? Icons.person : Icons.person_outline),
            ),
            title: Text(user?.displayName ?? '未登录'),
            subtitle: Text(user?.email ?? '点击登录'),
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
          
          const Divider(),
          
          // 主题设置
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) {
                // 切换主题
              },
            ),
          ),
          
          // 自动更换壁纸
          ListTile(
            leading: const Icon(Icons.timelapse),
            title: const Text('自动更换壁纸'),
            subtitle: const Text('设置定时更换'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('自动更换功能')),
              );
            },
          ),
          
          const Divider(),
          
          // 免责声明
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('免责声明'),
            onTap: () {
              Navigator.pushNamed(context, '/disclaimer');
            },
          ),
          
          // 用户协议
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('用户协议'),
            onTap: () {
              Navigator.pushNamed(context, '/user-agreement');
            },
          ),
          
          const Divider(),
          
          // 关于
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            subtitle: const Text('版本 1.0.0'),
          ),
        ],
      ),
    );
  }
}
