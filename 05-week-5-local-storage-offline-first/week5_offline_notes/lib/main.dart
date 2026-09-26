import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/prefs.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Root aplikasi Week 5: Offline Notes.
///
/// - Semua akses SharedPreferences lewat [prefsRepositoryProvider].
/// - Tema gelap/terang lewat [darkModeProvider] (AsyncNotifier).
/// - UI tidak memanggil SharedPreferences/SQLite langsung.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider).value ?? false;

    return MaterialApp(
      title: 'Offline Notes - Week 5',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeShell(),
    );
  }
}

/// Provider untuk waktu terakhir dibuka.
/// Ditulis saat [HomeShell] pertama dibuka via [PrefsRepository.markOpenedNow].
final lastOpenedProvider = FutureProvider<String?>((ref) {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Catat waktu dibuka sekali, lalu refresh provider tampilan.
    // addPostFrameCallback agar tidak memanggil ref saat build berjalan.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(prefsRepositoryProvider).markOpenedNow();
      ref.invalidate(lastOpenedProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      NotesPage(),
      SettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Catatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

/// Tab Pengaturan: toggle tema + info terakhir dibuka.
///
/// Seluruh baca/tulis preferensi lewat repository + provider,
/// tidak ada SharedPreferences.getInstance() di widget.
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

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
              data: (v) => Text(v ?? 'Belum pernah dicatat'),
              loading: () => const Text('Memuat...'),
              error: (e, _) => Text('Gagal memuat: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
