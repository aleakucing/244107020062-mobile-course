import '../../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

// Operasi bisnis dengan aturan validasi: judul tidak boleh kosong.
// Inilah contoh kapan use case dibutuhkan (ada aturan bisnis),
// bukan sekadar CRUD satu baris.
class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        (
          note: null,
          failure: const ValidationFailure('Judul tidak boleh kosong'),
        ),
      );
    }
    return _repository.addNote(title: trimmed, body: body.trim());
  }
}
