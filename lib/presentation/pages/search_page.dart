import 'package:flutter/material.dart';

/// 搜索页
class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _query = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜索壁纸...',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            setState(() => _query = value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() => _query = _searchController.text);
            },
          ),
        ],
      ),
      body: _query.isEmpty
          ? const Center(child: Text('输入关键词搜索壁纸'))
          : Center(child: Text('搜索: $_query')),
    );
  }
}
