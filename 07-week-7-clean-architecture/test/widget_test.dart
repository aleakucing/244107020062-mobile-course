import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements NoteRepository {
  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async => (
        notes: [
          Note(title: 'A', updatedAt: DateTime(2026, 9, 27)),
        ],
        failure: null,
      );

  @override
  Future<({Note? note, Failure? failure})> addNote(
          {required String title, String body = ''}) =>
      throw UnimplementedError();

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
  Future<({Failure? failure})> markAllSynced() =>
      throw UnimplementedError();
}

void main() {
  testWidgets('NotesPage menampilkan daftar dari provider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [noteRepositoryProvider.overrideWithValue(FakeRepo())],
        child: const MaterialApp(home: NotesPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Catatan Offline'), findsOneWidget);
  });

  testWidgets('NotesPage menampilkan empty state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: NotesList([])),
      ),
    );
    // NotesList kosong -> ListView tanpa item, tidak crash.
    expect(find.byType(NotesList), findsOneWidget);
  });
}
