import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/notes_providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/main.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository() : super(openDb: _never);
  static Future<Database> _never() => throw UnimplementedError();

  final List<Note> items = [
    Note(id: 1, title: 'Catatan uji', body: 'Isi', updatedAt: DateTime(2026, 9, 26), dirty: true),
  ];

  @override
  Future<List<Note>> fetchNotes() async => [...items];

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    final n = Note(id: items.length + 1, title: title, body: body, updatedAt: DateTime.now(), dirty: true);
    items.add(n);
    return n;
  }

  @override
  Future<void> deleteNote(int id) async => items.removeWhere((e) => e.id == id);

  @override
  Future<void> updateNote(Note note) async {}

  @override
  Future<int> countDirty() async => items.where((e) => e.dirty).length;

  @override
  Future<void> markAllSynced() async {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('App tampil tab Catatan + daftar dari repository palsu', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Catatan Offline'), findsOneWidget);
    expect(find.text('Catatan uji'), findsOneWidget);
    expect(find.textContaining('belum tersinkron'), findsOneWidget);
  });

  testWidgets('FAB tambah membuka dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Catatan baru'), findsOneWidget);
  });
}
