import 'package:flutter/material.dart';

import 'cached_repository.dart';

/// Item widget terisolasi dengan const constructor dan RepaintBoundary
/// untuk mencegah unnecessary repaint pada widget tetangga saat scroll.
class OptimizedFeedTile extends StatelessWidget {
  const OptimizedFeedTile({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0.8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigo.shade100,
            child: Text(
              '${item.id}',
              style: TextStyle(
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            item.subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: const Icon(Icons.speed, color: Colors.green, size: 20),
        ),
      ),
    );
  }
}

/// Halaman daftar berkinerja tinggi menggunakan ListView.builder dan infinite scroll pagination.
class OptimizedListPage extends StatefulWidget {
  const OptimizedListPage({super.key, required this.repository});

  final ItemRepository repository;

  @override
  State<OptimizedListPage> createState() => _OptimizedListPageState();
}

class _OptimizedListPageState extends State<OptimizedListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<FeedItem> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await widget.repository.fetchPage(_currentPage);
      if (!mounted) return;

      if (newItems.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _items.addAll(newItems);
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // Mencegah memory leak dengan dispose listener dan controller
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimasi Performa (60 FPS)'),
        backgroundColor: Colors.indigo.shade50,
        actions: [
          IconButton(
            tooltip: 'Refresh Cache',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.repository.clearCache();
              setState(() {
                _items.clear();
                _currentPage = 1;
                _hasMore = true;
              });
              _loadNextPage();
            },
          ),
        ],
      ),
      body: _items.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return OptimizedFeedTile(item: _items[index]);
              },
            ),
    );
  }
}
