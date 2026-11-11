import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:testing_lab/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'End-to-End flow: pengguna melihat daftar awal dan menambahkan tugas baru',
    (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verifikasi initial view
      expect(find.text('Daftar tugas'), findsOneWidget);
      expect(find.text('Baca materi Mobile'), findsOneWidget);

      // Pengguna mengisi form
      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Tugas Akhir Quality Assurance',
      );
      await tester.pumpAndSettle();

      // Pengguna menekan tombol simpan
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // Verifikasi tugas baru telah masuk dan dirender
      expect(find.text('Tugas Akhir Quality Assurance'), findsOneWidget);
    },
  );
}
