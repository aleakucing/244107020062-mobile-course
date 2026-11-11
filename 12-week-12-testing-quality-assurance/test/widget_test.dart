import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/main.dart';
import 'package:testing_lab/task_repository.dart';

class MockTaskRepository implements TaskRepository {
  MockTaskRepository({List<String>? tasks, this.error})
    : _tasks = tasks != null ? List.from(tasks) : [];

  final List<String> _tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    if (error != null) throw error!;
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> addTask(String title) async {
    if (error != null) throw error!;
    _tasks.add(title);
  }
}

void main() {
  group('TaskListPage Widget Tests', () {
    testWidgets('menampilkan judul halaman tugas dan item awal', (
      tester,
    ) async {
      final repo = MockTaskRepository(tasks: ['Baca materi Flutter']);

      await tester.pumpWidget(MyApp(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Daftar tugas'), findsOneWidget);
      expect(find.text('Baca materi Flutter'), findsOneWidget);
    });

    testWidgets('menampilkan snackbar peringatan saat input tugas kosong', (
      tester,
    ) async {
      final repo = MockTaskRepository(tasks: []);

      await tester.pumpWidget(MyApp(repository: repo));
      await tester.pumpAndSettle();

      // Tekan tombol simpan saat textfield kosong
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
    });

    testWidgets(
      'pengguna memasukkan teks dan berhasil menambahkan tugas ke daftar',
      (tester) async {
        final repo = MockTaskRepository(tasks: ['Tugas pertama']);

        await tester.pumpWidget(MyApp(repository: repo));
        await tester.pumpAndSettle();

        // Ketik judul tugas baru
        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          'Praktikum Testing Week 12',
        );
        await tester.pumpAndSettle();

        // Tekan tombol simpan
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();

        // Verifikasi item baru muncul di layar
        expect(find.text('Praktikum Testing Week 12'), findsOneWidget);
        expect(find.text('Tugas pertama'), findsOneWidget);
      },
    );

    testWidgets('menampilkan pesan error saat repository mengalami kegagalan', (
      tester,
    ) async {
      final repo = MockTaskRepository(error: Exception('Gagal koneksi server'));

      await tester.pumpWidget(MyApp(repository: repo));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Gagal memuat tugas: Exception: Gagal koneksi server',
        ),
        findsOneWidget,
      );
    });
  });
}
