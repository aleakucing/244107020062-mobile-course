// Entity murni — tanpa import Flutter, tanpa mapping JSON/SQLite.
// Mapping hanya ada di data/models/note_model.dart.
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
