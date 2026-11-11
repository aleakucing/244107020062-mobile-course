/// Kontrak abstraksi penyimpanan data tugas.
abstract interface class TaskRepository {
  Future<List<String>> getTasks();
  Future<void> addTask(String title);
}

/// Layanan bisnis tugas yang bergantung pada TaskRepository melalui Dependency Injection.
class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  Future<List<String>> loadTasks() {
    return _repository.getTasks();
  }

  Future<bool> createTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Judul tugas tidak boleh kosong.');
    }
    await _repository.addTask(trimmed);
    return true;
  }
}
