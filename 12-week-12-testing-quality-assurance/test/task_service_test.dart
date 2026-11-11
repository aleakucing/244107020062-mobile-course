import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/task_repository.dart';

/// Fake repository terkendali tanpa dependensi database sungguhan atau network.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<String>? initialTasks, this.error})
    : _tasks = initialTasks != null ? List.from(initialTasks) : [];

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
  group('TaskService dengan FakeTaskRepository', () {
    test('loadTasks meneruskan data dari repository secara konsisten (Arrange-Act-Assert)', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(
        initialTasks: ['Baca materi', 'Tulis pengujian'],
      );
      final service = TaskService(fakeRepo);

      // Act
      final result = await service.loadTasks();

      // Assert
      expect(result, ['Baca materi', 'Tulis pengujian']);
      expect(result.length, 2);
    });

    test('loadTasks melempar exception saat repository mengalami error (Failure scenario)', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(
        error: Exception('Database disconnected'),
      );
      final service = TaskService(fakeRepo);

      // Act & Assert
      expect(
        () => service.loadTasks(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'pesan error',
            contains('Database disconnected'),
          ),
        ),
      );
    });

    test('createTask berhasil menambahkan task baru ke repository', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(initialTasks: []);
      final service = TaskService(fakeRepo);

      // Act
      final success = await service.createTask('Integrasi Testing');

      // Assert
      expect(success, isTrue);
      expect(await fakeRepo.getTasks(), ['Integrasi Testing']);
    });

    test('createTask menolak input kosong dengan ArgumentError', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository();
      final service = TaskService(fakeRepo);

      // Act & Assert
      expect(() => service.createTask('    '), throwsArgumentError);
    });
  });
}
