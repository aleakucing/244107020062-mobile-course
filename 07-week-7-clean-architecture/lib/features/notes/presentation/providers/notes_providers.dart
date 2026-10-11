import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';
import '../../data/repositories/note_repository_impl.dart';

// ── Dependency injection: satu-satunya tempat wiring ──
// Widget tidak pernah membuat repository sendiri.

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl();
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) throw Exception(result.failure!.message);
    return result.notes;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(getNotesProvider).call();
      if (result.failure != null) throw Exception(result.failure!.message);
      state = AsyncData(result.notes);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addNote({required String title, String body = ''}) async {
    final result =
        await ref.read(addNoteProvider).call(title: title, body: body);
    if (result.failure != null) throw Exception(result.failure!.message);
    ref.invalidateSelf();
  }

  Future<void> updateNote(Note note) async {
    // CRUD satu-baris: langsung repository -> notifier (tanpa use case).
    // Alasan tertulis di docs/keputusan-final.md (hindari over-engineering).
    final repo = ref.read(noteRepositoryProvider);
    final result = await repo.updateNote(note);
    if (result.failure != null) throw Exception(result.failure!.message);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    final result = await repo.deleteNote(id);
    if (result.failure != null) throw Exception(result.failure!.message);
    ref.invalidateSelf();
  }

  Future<void> sync() async {
    state = const AsyncLoading();
    try {
      // Simulasi delay jaringan di presentation, bukan di domain.
      await Future<void>.delayed(const Duration(seconds: 1));
      final result = await ref.read(syncNotesProvider).call();
      if (result.failure != null) throw Exception(result.failure!.message);
      final fresh = await ref.read(getNotesProvider).call();
      if (fresh.failure != null) throw Exception(fresh.failure!.message);
      state = AsyncData(fresh.notes);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

/// Jumlah catatan belum tersinkron (badge dirty).
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

String friendlyDbErrorForUi(Object error) => friendlyDbError(error);
