import '../../../../../core/failures.dart';

// Kontrak settings di domain — implementasi di data memakai SharedPreferences.
abstract class SettingsRepository {
  Future<({bool darkMode, Failure? failure})> getDarkMode();
  Future<({Failure? failure})> setDarkMode(bool value);
  Future<({String? lastOpened, Failure? failure})> getLastOpened();
  Future<({Failure? failure})> markOpenedNow();
}
