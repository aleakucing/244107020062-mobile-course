import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../providers/settings_providers.dart';

// Halaman pengaturan bersih: tanpa SharedPreferences langsung.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema gelap'),
            subtitle: const Text('Disimpan di SharedPreferences'),
            value: darkMode.value ?? false,
            onChanged: darkMode.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          if (darkMode.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          if (darkMode.hasError)
            ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: const Text('Gagal memuat tema'),
              subtitle: Text('${darkMode.error}'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Terakhir dibuka'),
            subtitle: lastOpened.when(
              data: (v) => Text(formatLastOpened(v)),
              loading: () => const Text('Memuat...'),
              error: (e, _) => Text('Gagal memuat: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
