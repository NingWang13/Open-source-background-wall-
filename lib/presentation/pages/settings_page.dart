import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/auto_change_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/wallpaper_service.dart';

/// 设置页
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDarkMode = false;
  bool _autoChangeEnabled = false;
  int _autoChangeInterval = 30;
  bool _useFavoritesOnly = false;
  bool _includeOnline = true;
  WallpaperScreen _selectedScreen = WallpaperScreen.both;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await ThemeService.getThemeMode();
    final autoSettings = AutoChangeService.settings;
    
    if (mounted) {
      setState(() {
        _isDarkMode = themeMode == ThemeMode.dark;
        _autoChangeEnabled = autoSettings.enabled;
        _autoChangeInterval = autoSettings.intervalMinutes;
        _useFavoritesOnly = autoSettings.useFavoritesOnly;
        _includeOnline = autoSettings.includeOnline;
        _selectedScreen = autoSettings.screen;
      });
    }
  }

  Future<void> _toggleDarkMode() async {
    final newMode = !_isDarkMode;
    await ThemeService.setThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);
    setState(() => _isDarkMode = newMode);
  }

  Future<void> _toggleAutoChange() async {
    final newEnabled = !_autoChangeEnabled;
    await AutoChangeService.updateSettings(
      AutoChangeService.settings.copyWith(enabled: newEnabled),
    );
    setState(() => _autoChangeEnabled = newEnabled);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newEnabled ? '✅ 自动换壁纸已开启' : '❌ 自动换壁纸已关闭'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAutoChangeSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⚙️ 自动换壁纸设置',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _autoChangeEnabled,
                        onChanged: (value) {
                          setModalState(() => _autoChangeEnabled = value);
                          _toggleAutoChange();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 更换间隔
                  Text(
                    '更换间隔: ${_autoChangeInterval}分钟',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Slider(
                    value: _autoChangeInterval.toDouble(),
                    min: 5,
                    max: 1440, // 24小时
                    divisions: 20,
                    label: _formatInterval(_autoChangeInterval),
                    onChanged: (value) {
                      setModalState(() => _autoChangeInterval = value.toInt());
                    },
                    onChangeEnd: (value) {
                      AutoChangeService.updateSettings(
                        AutoChangeService.settings.copyWith(
                          intervalMinutes: value.toInt(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 壁纸来源
                  const Text(
                    '壁纸来源',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('收藏夹'),
                    subtitle: Text('共 ${FavoritesService.count} 张'),
                    value: _useFavoritesOnly,
                    onChanged: (value) {
                      setModalState(() {
                        _useFavoritesOnly = value ?? false;
                        if (_useFavoritesOnly) _includeOnline = false;
                      });
                      AutoChangeService.updateSettings(
                        AutoChangeService.settings.copyWith(
                          useFavoritesOnly: value ?? false,
                        ),
                      );
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('在线壁纸'),
                    subtitle: const Text('从 Unsplash/Pexels 获取'),
                    value: _includeOnline,
                    onChanged: (value) {
                      setModalState(() {
                        _includeOnline = value ?? true;
                        if (_includeOnline) _useFavoritesOnly = false;
                      });
                      AutoChangeService.updateSettings(
                        AutoChangeService.settings.copyWith(
                          includeOnline: value ?? true,
                          useFavoritesOnly: false,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 设置位置
                  const Text(
                    '设置位置',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<WallpaperScreen>(
                    segments: const [
                      ButtonSegment(
                        value: WallpaperScreen.home,
                        label: Text('桌面'),
                        icon: Icon(Icons.home),
                      ),
                      ButtonSegment(
                        value: WallpaperScreen.lock,
                        label: Text('锁屏'),
                        icon: Icon(Icons.lock),
                      ),
                      ButtonSegment(
                        value: WallpaperScreen.both,
                        label: Text('全部'),
                        icon: Icon(Icons.smartphone),
                      ),
                    ],
                    selected: {_selectedScreen},
                    onSelectionChanged: (selection) {
                      setModalState(() => _selectedScreen = selection.first);
                      AutoChangeService.updateSettings(
                        AutoChangeService.settings.copyWith(
                          screen: selection.first,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 预览下次更换时间
                  Center(
                    child: Text(
                      '📅 预计 ${_getNextChangeTime()} 更换壁纸',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes 分钟';
    if (minutes < 1440) return '${(minutes / 60).toStringAsFixed(1)} 小时';
    return '24 小时';
  }

  String _getNextChangeTime() {
    // 简单的估算下次更换时间
    if (!_autoChangeEnabled) return '已关闭';
    return _formatInterval(_autoChangeInterval);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final favoritesCount = FavoritesService.count;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ 设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 用户信息卡片
          _buildUserCard(user),
          
          const SizedBox(height: 8),
          
          // 外观设置
          _SectionHeader(title: '🎨 外观'),
          _SettingsTile(
            icon: Icons.dark_mode,
            title: '深色模式',
            subtitle: _isDarkMode ? '已开启' : '已关闭',
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (_) => _toggleDarkMode(),
            ),
          ),
          _SettingsTile(
            icon: Icons.wallpaper,
            title: '主题色',
            subtitle: '跟随系统',
            onTap: () => _showColorPicker(),
          ),
          
          const SizedBox(height: 8),
          
          // 自动换壁纸
          _SectionHeader(title: '🕐 自动换壁纸'),
          _SettingsTile(
            icon: Icons.autorenew,
            title: '自动更换壁纸',
            subtitle: _autoChangeEnabled 
                ? '每 $_autoChangeInterval 分钟' 
                : '已关闭',
            trailing: Switch(
              value: _autoChangeEnabled,
              onChanged: (_) => _toggleAutoChange(),
            ),
            onTap: _showAutoChangeSettings,
          ),
          _SettingsTile(
            icon: Icons.timer,
            title: '更换间隔',
            subtitle: _formatInterval(_autoChangeInterval),
            onTap: _showAutoChangeSettings,
          ),
          _SettingsTile(
            icon: Icons.source,
            title: '壁纸来源',
            subtitle: _useFavoritesOnly 
                ? '收藏夹 ($favoritesCount 张)' 
                : '在线壁纸',
            onTap: _showAutoChangeSettings,
          ),
          
          const SizedBox(height: 8),
          
          // 壁纸库
          _SectionHeader(title: '📚 壁纸库'),
          _SettingsTile(
            icon: Icons.favorite,
            title: '我的收藏',
            subtitle: '$favoritesCount 张壁纸',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.download,
            title: '下载管理',
            subtitle: '查看已下载的壁纸',
            onTap: () {},
          ),
          
          const SizedBox(height: 8),
          
          // 关于
          _SectionHeader(title: 'ℹ️ 关于'),
          _SettingsTile(
            icon: Icons.info,
            title: '关于我们',
            subtitle: 'Wallhaven v1.0.0',
            onTap: () => _showAbout(),
          ),
          _SettingsTile(
            icon: Icons.description,
            title: '用户协议',
            subtitle: '了解使用条款',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.policy,
            title: '隐私政策',
            subtitle: '我们如何保护您的隐私',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.article,
            title: '免责声明',
            subtitle: '版权说明',
            onTap: () {},
          ),
          
          const SizedBox(height: 16),
          
          // 版本信息
          Center(
            child: Text(
              'Wallhaven v1.0.0 • Made with ❤️',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              user != null ? Icons.person : Icons.person_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? '访客用户',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '点击登录以同步收藏',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.login, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '🎨 选择主题色',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _ColorOption(color: Colors.blue, name: '蓝色'),
                _ColorOption(color: Colors.purple, name: '紫色'),
                _ColorOption(color: Colors.red, name: '红色'),
                _ColorOption(color: Colors.orange, name: '橙色'),
                _ColorOption(color: Colors.green, name: '绿色'),
                _ColorOption(color: Colors.teal, name: '青色'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Wallhaven',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.wallpaper, color: Colors.white, size: 32),
      ),
      children: [
        const Text(
          'Wallhaven 是一款跨平台免费壁纸应用，'
          '支持 Android、iOS、Web 等多个平台。\n\n'
          '特色功能：\n'
          '• 海量高清壁纸\n'
          '• 自动换壁纸\n'
          '• 收藏夹同步\n'
          '• 离线下载',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String name;

  const _ColorOption({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('主题色已更换为 $name')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
