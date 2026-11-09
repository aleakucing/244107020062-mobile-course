/// Entitas item data untuk demonstrasi pagination dan caching.
class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final int id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
}

/// Kontrak repository dengan strategi caching Stale-While-Revalidate.
abstract interface class ItemRepository {
  Future<List<FeedItem>> fetchPage(int page, {int pageSize = 15});
  List<FeedItem> getCachedItems();
  void clearCache();
}

/// Implementasi repository dengan optimasi memori dan caching offline-first.
class CachedItemRepository implements ItemRepository {
  CachedItemRepository({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;
  final Map<int, List<FeedItem>> _pageCache = {};

  @override
  List<FeedItem> getCachedItems() {
    return _pageCache.values.expand((list) => list).toList();
  }

  @override
  void clearCache() {
    _pageCache.clear();
  }

  @override
  Future<List<FeedItem>> fetchPage(int page, {int pageSize = 15}) async {
    // 1. Cek cache in-memory terlebih dahulu (Cache-Hit)
    if (_pageCache.containsKey(page)) {
      return _pageCache[page]!;
    }

    // 2. Simulasi fetch network dengan latensi terkendali
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }

    // Batasi hingga 4 halaman maksimum (60 items)
    if (page > 4) return [];

    final freshItems = List.generate(pageSize, (index) {
      final itemIndex = (page - 1) * pageSize + index + 1;
      return FeedItem(
        id: itemIndex,
        title: 'Laporan Aktivitas Mahasiswa #$itemIndex',
        subtitle: 'Optimasi rendering frame <16ms pada daftar $itemIndex',
        timestamp: DateTime(2026, 11, 9, 10, itemIndex % 60),
      );
    });

    // 3. Simpan ke cache
    _pageCache[page] = freshItems;
    return freshItems;
  }
}
