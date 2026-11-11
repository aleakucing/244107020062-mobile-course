import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/is_valid_task_title.dart';

void main() {
  group('isValidTaskTitle Unit Tests', () {
    test('menerima judul yang berisi teks valid', () {
      expect(isValidTaskTitle('Belajar Flutter'), isTrue);
      expect(isValidTaskTitle('Mengerjakan QA Testing'), isTrue);
    });

    test('menolak teks kosong atau hanya berisi whitespace/spasi', () {
      expect(isValidTaskTitle(''), isFalse);
      expect(isValidTaskTitle('   '), isFalse);
      expect(isValidTaskTitle('\t\n'), isFalse);
    });

    test(
      'menolak judul yang melebihi batas 100 karakter (edge case batas atas)',
      () {
        final longTitle = 'A' * 101;
        expect(isValidTaskTitle(longTitle), isFalse);
      },
    );

    test('menerima judul tepat 100 karakter (boundary condition)', () {
      final boundaryTitle = 'A' * 100;
      expect(isValidTaskTitle(boundaryTitle), isTrue);
    });
  });
}
