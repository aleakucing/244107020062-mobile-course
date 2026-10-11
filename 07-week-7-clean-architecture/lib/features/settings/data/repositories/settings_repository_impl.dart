import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/failures.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  @override
  Future<({bool darkMode, Failure? failure})> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (darkMode: prefs.getBool(_darkModeKey) ?? false, failure: null);
    } catch (e) {
      return (
        darkMode: false,
        failure: LocalFailure('Gagal membaca tema: $e'),
      );
    }
  }

  @override
  Future<({Failure? failure})> setDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
      return (failure: null);
    } catch (e) {
      return (failure: LocalFailure('Gagal menyimpan tema: $e'));
    }
  }

  @override
  Future<({String? lastOpened, Failure? failure})> getLastOpened() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (
        lastOpened: prefs.getString(_lastOpenedKey),
        failure: null,
      );
    } catch (e) {
      return (
        lastOpened: null,
        failure: LocalFailure('Gagal membaca waktu dibuka: $e'),
      );
    }
  }

  @override
  Future<({Failure? failure})> markOpenedNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _lastOpenedKey, DateTime.now().toIso8601String());
      return (failure: null);
    } catch (e) {
      return (failure: LocalFailure('Gagal mencatat waktu dibuka: $e'));
    }
  }
}
