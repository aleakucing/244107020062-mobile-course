import 'repositories/note_repository.dart';

/// Simulasi sinkronisasi offline-first.
///
/// Aturan konflik: last-write-wins berdasarkan `updated_at`
/// (lihat `docs/aturan-konflik.md`). Setiap tulis lokal selalu
/// `dirty = 1`; setelah "server" jawab OK (simulasi delay),
/// semua baris ditandai bersih via [NoteRepository.markAllSynced].
Future<void> syncNotes(NoteRepository repo) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
}
