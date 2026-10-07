import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../data/announcements.dart";

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = cariPengumuman(id);
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pengumuman")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(item.judul, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(item.tanggal),
          const Divider(height: 32),
          Text(item.isi),
        ],
      ),
    );
  }
}
