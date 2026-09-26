import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'data/local/note.dart';
import 'data/notes_providers.dart';
import 'data/repositories/note_repository.dart';
import 'main.dart';

/// Entrypoint KHUSUS screenshot web (`flutter run -d chrome -t lib/screenshot_main.dart`).
///
/// Alasan: plugin `sqflite` tidak tersedia di Web, sehingga [NoteRepository]
/// asli tidak bisa dibuka di Chrome. Entrypoint ini me-override
/// [noteRepositoryProvider] dengan [SeededNoteRepository] in-memory yang
/// mengimplementasikan kontrak repository yang sama (fetch/add/update/delete/
/// sync + flag `dirty`). Seluruh widget yang di-screenshot adalah widget
/// produksi yang sama ([NotesPage] asli); hanya sumber datanya yang di-seed.
///
/// Di HP (Android/iOS) aplikasi tetap memakai `main.dart` + SQLite asli.
/// Jangan pakai file ini untuk rilis.
class SeededNoteRepository extends NoteRepository {
  SeededNoteRepository() : super(openDb: _never);

  static Future<Database> _never() => throw UnimplementedError(
        'SeededNoteRepository tidak memakai SQLite (khusus screenshot web).',
      );

  final List<Note> _items = [
    Note(
      id: 1,
      title: 'Belanja mingguan',
      body: 'Susu, telur, roti',
      updatedAt: DateTime(2026, 9, 26, 9, 30),
      dirty: true,
    ),
    Note(
      id: 2,
      title: 'Ide offline-first',
      body: 'Tulis lokal dulu, sync saat online',
      updatedAt: DateTime(2026, 9, 25, 16, 0),
      dirty: true,
    ),
  ];
  int _nextId = 3;

  @override
  Future<List<Note>> fetchNotes() async {
    final sorted = [..._items]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    _items.add(note);
    return note;
  }

  @override
  Future<void> updateNote(Note note) async {
    final i = _items.indexWhere((e) => e.id == note.id);
    if (i == -1) return;
    _items[i] = Note(
      id: note.id,
      title: note.title,
      body: note.body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<int> countDirty() async => _items.where((e) => e.dirty).length;

  @override
  Future<void> markAllSynced() async {
    for (var i = 0; i < _items.length; i++) {
      final n = _items[i];
      _items[i] = Note(
        id: n.id,
        title: n.title,
        body: n.body,
        updatedAt: n.updatedAt,
        dirty: false,
      );
    }
  }
}

void main() {
  runApp(
    ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(SeededNoteRepository()),
      ],
      child: const MyApp(),
    ),
  );
}
