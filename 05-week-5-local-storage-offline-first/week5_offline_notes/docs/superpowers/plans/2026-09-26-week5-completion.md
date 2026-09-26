# Week5 Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Selesaikan TODO Week5: UI catatan SQLite + syncNotes + test hijau.

**Architecture:** Repository sudah ada (NoteRepository injeksi openDb). Tambah updateNote + sync.dart simulasi, provider Riverpod AsyncNotifier, UI Consumer, test dengan Fake repository in-memory (tanpa sqflite asli, pola Week4).

**Tech Stack:** Flutter, flutter_riverpod ^3.4.3, sqflite, shared_preferences, flutter_test.

**Spec:** docs/observasi-offline.md, docs/aturan-konflik.md, docs/keputusan-final.md, README.md TODO section.

## Global Constraints

- UI tidak memanggil SharedPreferences/SQLite langsung — lewat repository + provider.
- fetchNotes ORDER BY updated_at DESC (tetap).
- addNote/update selalu dirty=1 + updatedAt=now (last-write-wins).
- syncNotes simulasi delay 1 detik lalu markAllSynced.
- flutter analyze 0 error, flutter test hijau.

## Review Focus

- Judul kosong saat tambah/edit → ditolak dengan pesan, tidak insert baris kosong.
- Hapus catatan yang sudah dihapus → tidak crash, refresh list.
- Sync saat dirty=0 → tetap sukses, badge 0, tidak error.
- DB error (openDb throw) → notesProvider jadi AsyncError dengan pesan ramah.
- updated_at sama persis dua catatan → order stabil (id DESC sebagai tiebreak implisit, tidak crash).

---

### Task 1: Repository updateNote + sync.dart

**Files:**
- Modify: `lib/data/repositories/note_repository.dart`
- Create: `lib/data/sync.dart`
- Test: `test/note_test.dart` (bagian sync + update)

**Interfaces:**
- Consumes: `Note` di `lib/data/local/note.dart`, `NoteRepository{fetchNotes,addNote,deleteNote,countDirty,markAllSynced}`
- Produces: `Future<void> updateNote(Note note)` (set updatedAt=now, dirty=1), `Future<void> syncNotes(NoteRepository repo)` (delay 1s + markAllSynced)

- [ ] **Step 1: Tulis test gagal untuk updateNote + syncNotes di test/note_test.dart**
- [ ] **Step 2: Jalankan `flutter test test/note_test.dart` → FAIL (method/file belum ada)**
- [ ] **Step 3: Implementasi updateNote + sync.dart minimal**
- [ ] **Step 4: Jalankan test → PASS**
- [ ] **Step 5: Commit**

### Task 2: Notes providers (Riverpod)

**Files:**
- Create: `lib/data/notes_providers.dart`
- Test: `test/note_test.dart` (bagian provider)

**Interfaces:**
- Consumes: `NoteRepository`, `syncNotes`
- Produces: `noteRepositoryProvider`, `notesProvider (AsyncNotifier<List<Note>>)`, `dirtyCountProvider (FutureProvider<int>)`, `readNotesOnce(container)`, `friendlyDbError(error)`

- [ ] **Step 1: Tulis test provider sukses + error dengan FakeNoteRepository**
- [ ] **Step 2: Run test → FAIL**
- [ ] **Step 3: Implementasi notes_providers.dart (pola Week4 PostListNotifier + retry:null)**
- [ ] **Step 4: Run test → PASS**
- [ ] **Step 5: Commit**

### Task 3: NotesPage UI CRUD + badge dirty + tombol sync

**Files:**
- Modify: `lib/pages/notes_page.dart`
- Modify: `lib/pages/settings_page.dart` (hapus unused import material)
- Test: `test/widget_test.dart` (perbaiki: ProviderScope + override Fake)

**Interfaces:**
- Consumes: `notesProvider`, `dirtyCountProvider`, `darkModeProvider`
- Produces: UI list, dialog tambah/edit, hapus, badge dirty, tombol sync

- [ ] **Step 1: Tulis widget test gagal (find.text Catatan Offline, tambah catatan)**
- [ ] **Step 2: Run → FAIL (placeholder)**
- [ ] **Step 3: Implementasi NotesPage Consumer (list/error/loading/empty, FAB dialog, sync button, badge)**
- [ ] **Step 4: Run widget_test + analyze → PASS**
- [ ] **Step 5: Commit**

### Task 4: Docs + verifikasi akhir

**Files:**
- Modify: `README.md`, `docs/observasi-offline.md`, `screenshots/README.md`
- Test: full `flutter test`, `flutter analyze`

- [ ] **Step 1: Update checklist README + observasi (UI selesai, sync selesai, test hijau)**
- [ ] **Step 2: Run `flutter analyze` → 0 issue, `flutter test` → all pass**
- [ ] **Step 3: Commit**
