import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/notes_providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

/// Fake in-memory, pola sama seperti Week4 FakePostRepository.
/// Tidak menyentuh sqflite asli sehingga jalan di `flutter test`.
class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({List<Note>? seed}) : _items = [...?seed], super(openDb: _never);

  static Future<Database> _never() => throw UnimplementedError();

  final List<Note> _items;
  int _nextId = 1;
  bool throwError = false;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw StateError('DB rusak');
    final sorted = [..._items]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    if (throwError) throw StateError('DB rusak');
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
    if (throwError) throw StateError('DB rusak');
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
    if (throwError) throw StateError('DB rusak');
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<int> countDirty() async {
    if (throwError) throw StateError('DB rusak');
    return _items.where((e) => e.dirty).length;
  }

  @override
  Future<void> markAllSynced() async {
    if (throwError) throw StateError('DB rusak');
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
  group('Note model', () {
    test('toMap/fromMap roundtrip mempertahankan field', () {
      final now = DateTime(2026, 9, 26, 10, 0);
      final note = Note(id: 1, title: 'Belanja', body: 'Susu', updatedAt: now, dirty: true);
      final back = Note.fromMap(note.toMap());
      expect(back.id, 1);
      expect(back.title, 'Belanja');
      expect(back.body, 'Susu');
      expect(back.updatedAt, now);
      expect(back.dirty, isTrue);
    });

    test('fromMap aman terhadap field hilang', () {
      final note = Note.fromMap({'id': 7});
      expect(note.id, 7);
      expect(note.title, '');
      expect(note.body, '');
      expect(note.dirty, isFalse);
    });
  });

  group('NoteRepository (fake)', () {
    test('addNote menandai dirty=1', () async {
      final repo = FakeNoteRepository();
      final note = await repo.addNote(title: 'Halo', body: 'Isi');
      expect(note.dirty, isTrue);
      expect(await repo.countDirty(), 1);
    });

    test('fetchNotes urut updated_at DESC', () async {
      final repo = FakeNoteRepository(seed: [
        Note(id: 1, title: 'Lama', updatedAt: DateTime(2026, 1, 1), dirty: false),
        Note(id: 2, title: 'Baru', updatedAt: DateTime(2026, 9, 26), dirty: true),
      ]);
      final notes = await repo.fetchNotes();
      expect(notes.first.title, 'Baru');
      expect(notes.last.title, 'Lama');
    });

    test('updateNote refresh updatedAt + dirty=1', () async {
      final repo = FakeNoteRepository(seed: [
        Note(id: 1, title: 'Awal', updatedAt: DateTime(2026, 1, 1), dirty: false),
      ]);
      await repo.updateNote(Note(id: 1, title: 'Ubah', body: 'B', updatedAt: DateTime(2026, 1, 1)));
      final notes = await repo.fetchNotes();
      expect(notes.single.title, 'Ubah');
      expect(notes.single.dirty, isTrue);
      expect(await repo.countDirty(), 1);
    });

    test('deleteNote menghapus baris', () async {
      final repo = FakeNoteRepository(seed: [
        Note(id: 1, title: 'X', updatedAt: DateTime(2026, 1, 1)),
      ]);
      await repo.deleteNote(1);
      expect(await repo.fetchNotes(), isEmpty);
    });
  });

  group('syncNotes', () {
    test('dirty 2 -> 0 setelah sync', () async {
      final repo = FakeNoteRepository();
      await repo.addNote(title: 'A');
      await repo.addNote(title: 'B');
      expect(await repo.countDirty(), 2);
      await syncNotes(repo);
      expect(await repo.countDirty(), 0);
    });

    test('sync saat dirty=0 tetap sukses', () async {
      final repo = FakeNoteRepository();
      await syncNotes(repo);
      expect(await repo.countDirty(), 0);
    });

    test('NotesNotifier.sync tanpa circular dependency, dirty 0', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(seed: [
              Note(id: 1, title: 'A', updatedAt: DateTime(2026, 9, 26), dirty: true),
              Note(id: 2, title: 'B', updatedAt: DateTime(2026, 9, 25), dirty: true),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      await readNotesOnce(container);
      await container.read(notesProvider.notifier).sync();
      final dirty = await container.read(dirtyCountProvider.future);
      expect(dirty, 0);
    });
  });

  group('notesProvider', () {
    test('provider sukses dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(seed: [
              Note(id: 1, title: 'Tes', updatedAt: DateTime(2026, 9, 26), dirty: true),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notes = await readNotesOnce(container);
      expect(notes.length, 1);
      expect(notes.first.title, 'Tes');
    });

    test('provider error dengan repository palsu', () async {
      final fake = FakeNoteRepository()..throwError = true;
      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      final err = await readNotesErrorOnce(container);
      expect(err, isA<StateError>());
      expect(friendlyDbError(err!), contains('lokal'));
    });

    test('dirtyCountProvider menghitung yang dirty', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository(seed: [
            Note(id: 1, title: 'A', updatedAt: DateTime(2026, 9, 26), dirty: true),
            Note(id: 2, title: 'B', updatedAt: DateTime(2026, 9, 25), dirty: false),
          ])),
        ],
      );
      addTearDown(container.dispose);
      // Pastikan notes terload dulu.
      await readNotesOnce(container);
      final dirty = await container.read(dirtyCountProvider.future);
      expect(dirty, 1);
    });
  });
}
