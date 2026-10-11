import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_notes/features/notes/domain/usecases/add_note.dart';
import 'package:clean_notes/features/notes/domain/usecases/sync_notes.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotes implements NoteRepository {
  FakeNotes({this.failOnAdd = false, this.failOnSync = false});
  final bool failOnAdd;
  final bool failOnSync;
  final List<Note> saved = [];

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: saved, failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (failOnAdd) {
      return (
        note: null,
        failure: const LocalFailure('Gagal menyimpan (simulasi)'),
      );
    }
    final note = Note(
        title: title, body: body, updatedAt: DateTime(2026, 9, 27), dirty: true);
    saved.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) =>
      throw UnimplementedError();

  @override
  Future<({Failure? failure})> deleteNote(int id) =>
      throw UnimplementedError();

  @override
  Future<({int dirtyCount, Failure? failure})> countDirty() =>
      throw UnimplementedError();

  @override
  Future<({Failure? failure})> markAllSynced() async {
    if (failOnSync) {
      return (failure: const LocalFailure('sync gagal (simulasi)'));
    }
    return (failure: null);
  }
}

void main() {
  test('AddNote menolak judul kosong tanpa menyentuh repository', () async {
    final repo = FakeNotes();
    final result = await AddNote(repo).call(title: '   ');
    expect(result.note, isNull);
    expect(result.failure, isA<ValidationFailure>());
    expect(repo.saved, isEmpty);
  });

  test('AddNote sukses meneruskan entity dirty=true', () async {
    final repo = FakeNotes();
    final result =
        await AddNote(repo).call(title: 'Belanja', body: 'Susu');
    expect(result.failure, isNull);
    expect(result.note?.title, 'Belanja');
    expect(result.note?.dirty, isTrue);
  });

  test('AddNote meneruskan failure repository', () async {
    final repo = FakeNotes(failOnAdd: true);
    final result = await AddNote(repo).call(title: 'A');
    expect(result.note, isNull);
    expect(result.failure, isA<LocalFailure>());
  });

  test('SyncNotes sukses tanpa melempar', () async {
    final repo = FakeNotes();
    final result = await SyncNotes(repo).call();
    expect(result.failure, isNull);
  });

  test('SyncNotes meneruskan failure', () async {
    final repo = FakeNotes(failOnSync: true);
    final result = await SyncNotes(repo).call();
    expect(result.failure, isA<LocalFailure>());
  });
}
