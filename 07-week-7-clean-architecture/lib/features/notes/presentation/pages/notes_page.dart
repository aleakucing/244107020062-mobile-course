import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

// Halaman bersih: hanya membaca state via provider.
// Tanpa SQL, Dio, JSON, SharedPreferences, formatting tanggal mentah.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          dirty.when(
            data: (n) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text(n == 0 ? 'sinkron' : '$n belum tersinkron'),
                visualDensity: VisualDensity.compact,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Sinkronkan',
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await ref.read(notesProvider.notifier).sync();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sinkron selesai (simulasi)')),
                );
              }
            },
          ),
        ],
      ),
      body: notes.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan.\nTambah lewat tombol +.',
                  textAlign: TextAlign.center),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notesProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final n = items[i];
                return NotesTile(note: n);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: friendlyDbError(e),
          onRetry: () => ref.read(notesProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah catatan',
        onPressed: () => showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NotesTile extends ConsumerWidget {
  const NotesTile({super.key, required this.note});
  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = note;
    return ListTile(
      leading: Icon(
        n.dirty ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
      ),
      title: Text(n.title),
      subtitle: Text(
        '${n.body}\n${formatNoteDate(n.updatedAt)}'.trim(),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      onTap: () => showEditDialog(context, ref, n),
      trailing: IconButton(
        tooltip: 'Hapus',
        icon: const Icon(Icons.delete_outline),
        onPressed: () =>
            ref.read(notesProvider.notifier).deleteNote(n.id!),
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  const NotesList(this.notes, {super.key});
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, i) => NotesTile(note: notes[i]),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

Future<void> showAddDialog(BuildContext context, WidgetRef ref) {
  final titleC = TextEditingController();
  final bodyC = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Catatan baru'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleC,
            decoration: const InputDecoration(labelText: 'Judul'),
            autofocus: true,
          ),
          TextField(
            controller: bodyC,
            decoration: const InputDecoration(labelText: 'Isi'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            final title = titleC.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Judul tidak boleh kosong')),
              );
              return;
            }
            Navigator.pop(context);
            try {
              await ref
                  .read(notesProvider.notifier)
                  .addNote(title: title, body: bodyC.text.trim());
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

Future<void> showEditDialog(BuildContext context, WidgetRef ref, Note n) {
  final titleC = TextEditingController(text: n.title);
  final bodyC = TextEditingController(text: n.body);
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ubah catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleC,
            decoration: const InputDecoration(labelText: 'Judul'),
            autofocus: true,
          ),
          TextField(
            controller: bodyC,
            decoration: const InputDecoration(labelText: 'Isi'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            final title = titleC.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Judul tidak boleh kosong')),
              );
              return;
            }
            Navigator.pop(context);
            await ref.read(notesProvider.notifier).updateNote(
                  Note(
                      id: n.id,
                      title: title,
                      body: bodyC.text.trim(),
                      updatedAt: n.updatedAt),
                );
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}
