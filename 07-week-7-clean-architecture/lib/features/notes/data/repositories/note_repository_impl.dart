import 'package:sqflite/sqflite.dart';

import '../../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../local/db.dart';
import '../models/note_model.dart';

// Implementasi kontrak domain memakai SQLite.
// Semua exception mentah diubah menjadi Failure sebelum mencapai UI.
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes =
          rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await _openDb();
      final now = DateTime.now();
      final id = await db.insert(
        'notes',
        NoteModel(title: title, body: body, updatedAt: now, dirty: true)
            .toMap(),
      );
      return (
        note: Note(
            id: id, title: title, body: body, updatedAt: now, dirty: true),
        failure: null,
      );
    } catch (e) {
      return (
        note: null,
        failure: LocalFailure('Gagal menyimpan catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    try {
      final db = await _openDb();
      final now = DateTime.now();
      await db.update(
        'notes',
        {
          'title': note.title,
          'body': note.body,
          'updated_at': now.toIso8601String(),
          'dirty': 1,
        },
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return (
        note: Note(
          id: note.id,
          title: note.title,
          body: note.body,
          updatedAt: now,
          dirty: true,
        ),
        failure: null,
      );
    } catch (e) {
      return (
        note: null,
        failure: LocalFailure('Gagal mengubah catatan: $e'),
      );
    }
  }

  @override
  Future<({Failure? failure})> deleteNote(int id) async {
    try {
      final db = await _openDb();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (failure: null);
    } catch (e) {
      return (failure: LocalFailure('Gagal menghapus catatan: $e'));
    }
  }

  @override
  Future<({int dirtyCount, Failure? failure})> countDirty() async {
    try {
      final db = await _openDb();
      final rows = await db
          .rawQuery('SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
      final count = ((rows.first['c'] as num?)?.toInt() ?? 0);
      return (dirtyCount: count, failure: null);
    } catch (e) {
      return (
        dirtyCount: 0,
        failure: LocalFailure('Gagal menghitung dirty: $e'),
      );
    }
  }

  @override
  Future<({Failure? failure})> markAllSynced() async {
    try {
      final db = await _openDb();
      await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
      return (failure: null);
    } catch (e) {
      return (failure: LocalFailure('Gagal menandai sinkron: $e'));
    }
  }
}
