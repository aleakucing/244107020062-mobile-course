import '../../../../../core/failures.dart';
import '../entities/note.dart';

// Kontrak yang dibutuhkan domain. Tinggal di domain agar domain
// tidak bergantung pada implementasi (Dependency Inversion).
// Implementasi ada di data/repositories/note_repository_impl.dart.
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });

  Future<({Note? note, Failure? failure})> updateNote(Note note);

  Future<({Failure? failure})> deleteNote(int id);

  Future<({int dirtyCount, Failure? failure})> countDirty();

  Future<({Failure? failure})> markAllSynced();
}
