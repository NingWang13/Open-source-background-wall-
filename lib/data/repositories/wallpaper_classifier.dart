import '../models/wallpaper.dart';

/// 壁纸分类器 - 将壁纸按类别分组
/// 基于关键词匹配 description / author / tags
/// [Fix Bug 5] 实现真实的分类过滤逻辑
class WallpaperClassifier {
  /// 分类关键词映射（中文 + 英文双关键词）
  static const Map<String, List<String>> _categoryKeywords = {
    '自然':    [
      'nature', 'mountain', 'forest', 'ocean', 'beach', 'tree', 'flower',
      'landscape', 'sky', 'sunset', 'river', 'lake', 'sea', 'cloud',
      '自然', '森林', '海洋', '日落', '星空', '山水', '云', '风景',
    ],
    '城市':    [
      'city', 'urban', 'street', 'building', 'architecture', 'night',
      'neon', 'cityscape', 'bridge', 'road',
      '城市', '建筑', '夜景', '街道', '霓虹', '都市',
    ],
    '动物':    [
      'animal', 'dog', 'cat', 'bird', 'wildlife', 'lion', 'elephant',
      'horse', 'butterfly', 'fish',
      '动物', '猫', '狗', '鸟', '野生动物',
    ],
    '艺术':    [
      'art', 'abstract', 'painting', 'colorful', 'artistic', 'design',
      'creative', 'illustration',
      '艺术', '抽象', '色彩', '插画', '设计',
    ],
    '科技':    [
      'tech', 'technology', 'computer', 'code', 'digital', 'cyber',
      'space', 'rocket', 'robot',
      '科技', '技术', '电脑', '代码', '数字', '太空',
    ],
    '美女':    [
      'people', 'person', 'portrait', 'woman', 'man', 'model',
      'fashion', 'beauty',
      '人像', '美女', '男', '女', '时尚',
    ],
    '汽车':    [
      'car', 'vehicle', 'motorcycle', 'sports', 'racing', 'bike',
      '汽车', '车', '摩托', '跑车', '赛车', '机车',
    ],
  };

  /// 全部分类名称列表（与 UI FilterChip 对应）
  static const List<String> categories = [
    '全部', '自然', '城市', '动物', '艺术', '科技', '美女', '汽车',
  ];

  /// 判断单张壁纸是否属于指定分类
  static bool matches(String category, Wallpaper wallpaper) {
    if (category == '全部') return true;

    final keywords = _categoryKeywords[category] ?? [];
    if (keywords.isEmpty) return true;

    // 拼接所有可搜索文本
    final searchText = [
      wallpaper.description ?? '',
      wallpaper.author,
      ...wallpaper.tags,
    ].join(' ').toLowerCase();

    return keywords.any((kw) => searchText.contains(kw.toLowerCase()));
  }

  /// 对壁纸列表按分类过滤
  static List<Wallpaper> filter(List<Wallpaper> wallpapers, String category) {
    if (category == '全部') return wallpapers;
    return wallpapers.where((w) => matches(category, w)).toList();
  }
}
