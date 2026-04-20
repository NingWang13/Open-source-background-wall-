import 'package:flutter/material.dart';
import '../../core/services/collections_service.dart';

/// 收藏专辑管理页
/// [NEW] 新功能：收藏夹分组管理
class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  List<Collection> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
    CollectionsService.stream.listen((_) {
      if (mounted) _loadCollections();
    });
  }

  Future<void> _loadCollections() async {
    await CollectionsService.initialize();
    if (mounted) {
      setState(() {
        _collections = CollectionsService.allCollections;
      });
    }
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    int selectedIconCode = Icons.folder.codePoint;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新建收藏夹'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '例如：风景壁纸',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '简短描述...',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('图标: '),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Icons.folder, Icons.star, Icons.landscape,
                      Icons.pets, Icons.directions_car, Icons.code,
                    ].map((icon) {
                      final isSelected = selectedIconCode == icon.codePoint;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIconCode = icon.codePoint),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Icon(icon, size: 20),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await CollectionsService.createCollection(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  iconCodePoint: selectedIconCode,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadCollections();
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏夹'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建收藏夹',
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: _collections.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                final collection = _collections[index];
                return _CollectionCard(
                  collection: collection,
                  onTap: () => _openCollection(collection),
                  onEdit: () => _showEditDialog(collection),
                  onDelete: collection.id != 'default'
                      ? () => _deleteCollection(collection)
                      : null,
                );
              },
            ),
    );
  }

  void _openCollection(Collection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _CollectionDetailPage(collection: collection),
      ),
    );
  }

  Future<void> _showEditDialog(Collection collection) async {
    final nameController = TextEditingController(text: collection.name);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑收藏夹'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: '名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await CollectionsService.renameCollection(
                  collection.id,
                  nameController.text.trim(),
                );
                _loadCollections();
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
    nameController.dispose();
  }

  Future<void> _deleteCollection(Collection collection) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除收藏夹'),
        content: Text('确定删除 "${collection.name}"？里面的壁纸将移至"我的收藏"。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await CollectionsService.deleteCollection(collection.id);
      _loadCollections();
    }
  }
}

class _CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _CollectionCard({
    required this.collection,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  collection.iconData,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (collection.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        collection.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${collection.count} 张壁纸',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('重命名'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('删除', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 专辑详情页
class _CollectionDetailPage extends StatelessWidget {
  final Collection collection;

  const _CollectionDetailPage({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(collection.iconData, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '${collection.count} 张壁纸',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '详情页开发中...',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
