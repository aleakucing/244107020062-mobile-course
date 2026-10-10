import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements NoteRepository {
  List<Note> items = [];

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: items, failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final newNote = Note(
      id: items.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 9, 27),
      dirty: true,
    );
    items.add(newNote);
    return (note: newNote, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) =>
      throw UnimplementedError();

  @override
  Future<({Failure? failure})> deleteNote(int id) => throw UnimplementedError();

  @override
  Future<({int dirtyCount, Failure? failure})> countDirty() =>
      throw UnimplementedError();

  @override
  Future<({Failure? failure})> markAllSynced() => throw UnimplementedError();
}

void main() {
  testWidgets('validasi judul kosong menampilkan pesan error di UI dialog', (
    tester,
  ) async {
    final fakeRepo = FakeRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Buka dialog tambah catatan
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Catatan baru'), findsOneWidget);

    // Klik tombol Simpan tanpa mengisi form
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Verifikasi pesan error validator Form muncul
    expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
    // Verifikasi repository tidak dipanggil / belum ada catatan tersimpan
    expect(fakeRepo.items, isEmpty);
  });
}
