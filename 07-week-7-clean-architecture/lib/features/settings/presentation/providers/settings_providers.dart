import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';

// DI settings: widget tidak menyentuh SharedPreferences langsung.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result =
        await ref.watch(settingsRepositoryProvider).getDarkMode();
    if (result.failure != null) throw Exception(result.failure!.message);
    return result.darkMode;
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(settingsRepositoryProvider).setDarkMode(next);
      if (result.failure != null) throw Exception(result.failure!.message);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final result =
      await ref.watch(settingsRepositoryProvider).getLastOpened();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.lastOpened;
});
