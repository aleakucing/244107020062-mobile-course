import '../../../../../core/failures.dart';
import '../repositories/note_repository.dart';

// Operasi bisnis sync offline-first (simulasi):
// menandai semua baris dirty menjadi bersih setelah "server" OK.
// Delay jaringan simulasi ada di presentation (notifier), bukan di sini,
// agar use case tetap murni dan mudah diuji.
class SyncNotes {
  const SyncNotes(this._repository);
  final NoteRepository _repository;

  Future<({Failure? failure})> call() {
    return _repository.markAllSynced();
  }
}
