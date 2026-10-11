import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/failures.dart';
import 'features/notes/domain/entities/note.dart';
import 'features/notes/domain/repositories/note_repository.dart';
import 'features/notes/presentation/providers/notes_providers.dart';
import 'main.dart';

/// Entrypoint KHUSUS screenshot/golden HP.
///
/// Alasan: `sqflite` tidak tersedia di Web/Windows tanpa ffi, sehingga
/// repository asli tidak bisa dibuka di Chrome. Entrypoint ini me-override
/// [noteRepositoryProvider] dengan [SeededNoteRepository] in-memory yang
/// mengimplementasikan kontrak domain yang sama. Seluruh widget yang
/// di-screenshot adalah widget produksi yang sama ([MyApp] asli);
/// hanya sumber datanya yang di-seed.
///
/// Di HP (Android/iOS) aplikasi tetap memakai `main.dart` + SQLite asli.
/// Jangan pakai file ini untuk rilis.
class SeededNoteRepository implements NoteRepository {
  SeededNoteRepository();

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
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    final sorted = [..._items]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return (notes: sorted, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    _items.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    final i = _items.indexWhere((e) => e.id == note.id);
    if (i == -1) {
      return (note: null, failure: const LocalFailure('Catatan tidak ada'));
    }
    final updated = Note(
      id: note.id,
      title: note.title,
      body: note.body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    _items[i] = updated;
    return (note: updated, failure: null);
  }

  @override
  Future<({Failure? failure})> deleteNote(int id) async {
    _items.removeWhere((e) => e.id == id);
    return (failure: null);
  }

  @override
  Future<({int dirtyCount, Failure? failure})> countDirty() async {
    return (dirtyCount: _items.where((e) => e.dirty).length, failure: null);
  }

  @override
  Future<({Failure? failure})> markAllSynced() async {
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
    return (failure: null);
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
