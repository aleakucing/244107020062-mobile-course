# Perbandingan Storage — Week 5

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Sangat rendah (get/set primitif) | Rendah (key-box, filter manual) | Tinggi (SQL: WHERE, ORDER BY, JOIN) | Tinggi (SQL type-safe via Dart) |
| Relasi | Tidak ada | Tidak ada (embed manual) | Ada (FK, JOIN) | Ada (relasi + migrasi terstruktur) |
| Reaktivitas (stream) | Tidak (baca ulang manual) | Ya (`watchBox`) | Tidak bawaan (perlu Stream bungkus manual) | Ya (`watch()` stream reaktif) |
| Type-safety | Rendah (primitif + cast) | Sedang (adapter manual) | Rendah (Map mentah) | Tinggi (table class + codegen) |
| Boilerplate | Minimal | Kecil (init + adapter) | Sedang (openDB, SQL, mapping) | Besar (setup codegen + migrasi) |
| Kemudahan testing | Mudah (mock simpel) | Mudah (box in-memory) | Sedang (butuh fake/in-memory via injeksi `openDb`) | Sedang (test DB + codegen) |
| Cocok untuk 1000+ catatan | Tidak (satu string JSON = rapuh/lambat) | Cukup (box, tapi query kompleks manual) | Ya (indeks + `ORDER BY updated_at DESC`) | Ya (terbaik untuk query kompleks + stream) |

Skema 1000+ catatan (dipakai project ini, `sqflite`):

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated ON notes(updated_at DESC);
```

Lihat `lib/data/local/db.dart` (indeks opsional untuk skala besar).
