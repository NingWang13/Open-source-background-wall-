import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// 搜索历史服务
class SearchHistoryService {
  static const String _keySearchHistory = 'search_history';
  static const int maxHistory = 20;
  
  static final List<String> _history = [];
  static final _historyController = StreamController<List<String>>.broadcast();
  
  static Stream<List<String>> get historyStream => _historyController.stream;
  static List<String> get history => List.unmodifiable(_history);
  
  /// 初始化
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _history.clear();
    _history.addAll(prefs.getStringList(_keySearchHistory) ?? []);
    _historyController.add(List.unmodifiable(_history));
  }
  
  /// 添加搜索记录
  static Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    _history.remove(query);
    _history.insert(0, query);
    
    if (_history.length > maxHistory) {
      _history.removeRange(maxHistory, _history.length);
    }
    
    await _saveHistory();
    _historyController.add(List.unmodifiable(_history));
  }
  
  /// 删除搜索记录
  static Future<void> removeFromHistory(String query) async {
    _history.remove(query);
    await _saveHistory();
    _historyController.add(List.unmodifiable(_history));
  }
  
  /// 清空搜索记录
  static Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    _historyController.add(List.unmodifiable(_history));
  }
  
  /// 保存到本地
  static Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySearchHistory, _history);
  }
  
  /// 热门搜索词
  static const List<String> hotSearches = [
    'nature', 'mountain', 'ocean', 'sunset', 'city',
    'forest', 'space', 'abstract', 'minimal', 'dark',
    'cat', 'dog', 'flower', 'car', 'travel',
  ];
}
