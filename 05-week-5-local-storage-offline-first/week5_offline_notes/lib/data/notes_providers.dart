import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(noteRepositoryProvider);
    return repo.fetchNotes();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(noteRepositoryProvider);
      state = AsyncData(await repo.fetchNotes());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addNote({required String title, String body = ''}) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.addNote(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> updateNote(Note note) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.updateNote(note);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    ref.invalidateSelf();
  }

  Future<void> sync() async {
    final repo = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    try {
      await syncNotes(repo);
      state = AsyncData(await repo.fetchNotes());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  // Matikan retry otomatis Riverpod 3 agar error final dan mudah diuji.
  retry: (retryCount, error) => null,
);

/// Jumlah catatan belum tersinkron (badge dirty).
/// Dihitung dari list agar otomatis refresh mengikuti [notesProvider].
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final notes = await ref.watch(notesProvider.future);
  return notes.where((n) => n.dirty).length;
});

/// Helper testing: baca state pertama yang bukan loading.
Future<List<Note>> readNotesOnce(ProviderContainer container) {
  final completer = Completer<List<Note>>();
  final sub = container.listen<AsyncValue<List<Note>>>(
    notesProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      next.whenData(completer.complete);
      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readNotesErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Note>>>(
    notesProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      completer.complete(next.error);
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

String friendlyDbError(Object error) =>
    'Gagal memuat catatan lokal ($error). Data SQLite tetap aman, coba lagi.';
