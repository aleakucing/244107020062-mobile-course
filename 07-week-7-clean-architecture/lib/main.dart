import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/notes/presentation/pages/notes_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Root aplikasi Week 7: Clean Notes (refactor Week 5 ke Clean Architecture).
///
/// - DI terpusat di provider tiap fitur, UI tidak membuat repository langsung.
/// - Domain steril dari Flutter/package; mapping hanya di model.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider).value ?? false;

    return MaterialApp(
      title: 'Clean Notes - Week 7',
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

final lastOpenedWriterProvider = FutureProvider<void>((ref) async {
  await ref.watch(settingsRepositoryProvider).markOpenedNow();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(settingsRepositoryProvider).markOpenedNow();
      ref.invalidate(lastOpenedProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      NotesPage(),
      SettingsPage(),
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
