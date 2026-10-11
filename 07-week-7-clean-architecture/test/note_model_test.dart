import 'package:clean_notes/core/format.dart';
import 'package:clean_notes/features/notes/data/models/note_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NoteModel roundtrip mempertahankan field', () {
    final now = DateTime(2026, 9, 27, 10, 30);
    final model =
        NoteModel(id: 1, title: 'Belanja', body: 'Susu', updatedAt: now, dirty: true);
    final back = NoteModel.fromMap(model.toMap());
    expect(back.id, 1);
    expect(back.title, 'Belanja');
    expect(back.body, 'Susu');
    expect(back.updatedAt, now);
    expect(back.dirty, isTrue);
    expect(back.toEntity().title, 'Belanja');
  });

  test('NoteModel.fromMap aman terhadap field hilang', () {
    final model = NoteModel.fromMap({'id': 7});
    expect(model.id, 7);
    expect(model.title, '');
    expect(model.body, '');
    expect(model.dirty, isFalse);
  });

  test('formatNoteDate murni dan deterministik', () {
    final dt = DateTime(2026, 9, 27, 8, 5);
    final s = formatNoteDate(dt);
    expect(s, contains('2026-09-27'));
    expect(s, contains('08:05'));
  });

  test('formatLastOpened null -> pesan default', () {
    expect(formatLastOpened(null), 'Belum pernah dicatat');
  });

  test('friendlyDbError mengandung kata lokal', () {
    expect(friendlyDbError(StateError('x')), contains('lokal'));
  });
}
