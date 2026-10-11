import '../../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

// Satu operasi bisnis: ambil daftar catatan terurut updatedAt DESC.
// Sorting dilakukan di repository (query ORDER BY), use case hanya meneruskan.
class GetNotes {
  const GetNotes(this._repository);
  final NoteRepository _repository;

  Future<({List<Note> notes, Failure? failure})> call() {
    return _repository.fetchNotes();
  }
}
