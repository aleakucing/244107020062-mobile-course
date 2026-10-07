import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "../data/announcements.dart";
import "../messaging/push_service.dart";
import "../providers/auth_provider.dart";
import "../routes.dart";

final debugTokenProvider = FutureProvider<String>((ref) async {
  final access = await ref.watch(tokenStoreProvider).readAccess();
  if (access == null) return "-";
  return shortToken(access);
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(debugTokenProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengumuman Kampus"),
        actions: [
          IconButton(
            tooltip: "Keluar",
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(routeLogin);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text("Notifikasi perangkat"),
              subtitle: Text(
                  "Topik: $topicPengumuman\nToken akses: ${token.value ?? "..."}"),
            ),
          ),
          const SizedBox(height: 8),
          for (final item in daftarPengumuman)
            Card(
              child: ListTile(
                title: Text(item.judul),
                subtitle: Text(item.tanggal),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(announcementRoute(item.id)),
              ),
            ),
        ],
      ),
    );
  }
}
