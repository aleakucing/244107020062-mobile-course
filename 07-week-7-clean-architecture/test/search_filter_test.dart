import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:clean_notes/features/notes/domain/usecases/search_notes.dart';
import 'package:clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSearchRepo implements NoteRepository {
  final List<Note> items;

  FakeSearchRepo(this.items);

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: items, failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) => throw UnimplementedError();

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) =>
      throw UnimplementedError();

  @override
  Future<({Failure? failure})> deleteNote(int id) => throw UnimplementedError();

  @override
  Future<({int dirtyCount, Failure? failure})> countDirty() async =>
      (dirtyCount: 0, failure: null);

  @override
  Future<({Failure? failure})> markAllSynced() => throw UnimplementedError();
}

void main() {
  group('SearchNotes UseCase', () {
    final sampleNotes = [
      Note(
        id: 1,
        title: 'Belanja Mingguan',
        body: 'Beli susu dan roti',
        updatedAt: DateTime(2026, 10, 1),
      ),
      Note(
        id: 2,
        title: 'Tugas Kuliah',
        body: 'Pemrograman Mobile Clean Architecture',
        updatedAt: DateTime(2026, 10, 2),
      ),
      Note(
        id: 3,
        title: 'Ide Liburan',
        body: 'Jalan-jalan ke pantai',
        updatedAt: DateTime(2026, 10, 3),
      ),
    ];

    const search = SearchNotes();

    test('query kosong mengembalikan semua catatan', () {
      final result = search(notes: sampleNotes, query: '   ');
      expect(result.length, 3);
    });

    test('pencarian case-insensitive berdasarkan judul', () {
      final result = search(notes: sampleNotes, query: 'belanja');
      expect(result.length, 1);
      expect(result.first.title, 'Belanja Mingguan');
    });

    test('pencarian berdasarkan isi body catatan', () {
      final result = search(notes: sampleNotes, query: 'pantai');
      expect(result.length, 1);
      expect(result.first.id, 3);
    });

    test('query yang tidak cocok mengembalikan list kosong', () {
      final result = search(notes: sampleNotes, query: 'tidak-ada-keyword');
      expect(result, isEmpty);
    });
  });

  group('Search UI Widget Test', () {
    testWidgets(
      'menampilkan search field saat tombol cari ditekan dan menampilkan empty state jika tidak cocok',
      (tester) async {
        final sampleNotes = [
          Note(
            id: 1,
            title: 'Flutter Mobile',
            body: 'State management',
            updatedAt: DateTime(2026, 10, 1),
          ),
        ];

        final container = ProviderContainer(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              FakeSearchRepo(sampleNotes),
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: NotesPage()),
          ),
        );
        await tester.pumpAndSettle();

        // Verifikasi catatan tampil
        expect(find.text('Flutter Mobile'), findsOneWidget);

        // Buka search field
        await tester.tap(find.byTooltip('Cari catatan'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('search-notes-field')), findsOneWidget);

        // Masukkan kata kunci yang tidak cocok
        await tester.enterText(
          find.byKey(const Key('search-notes-field')),
          'Android Native',
        );
        await tester.pumpAndSettle();

        // Verifikasi empty state muncul
        expect(
          find.text('Tidak ada catatan yang cocok dengan "Android Native"'),
          findsOneWidget,
        );
        expect(find.text('Flutter Mobile'), findsNothing);

        // Tutup pencarian
        await tester.tap(find.byTooltip('Tutup pencarian'));
        await tester.pumpAndSettle();

        expect(find.text('Flutter Mobile'), findsOneWidget);
      },
    );
  });
}
