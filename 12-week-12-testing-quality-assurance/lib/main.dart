import 'package:flutter/material.dart';

import 'is_valid_task_title.dart';
import 'task_repository.dart';

void main() {
  runApp(const MyApp());
}

class InMemoryTaskRepository implements TaskRepository {
  final List<String> _tasks = ['Baca materi Mobile'];

  @override
  Future<List<String>> getTasks() async => List.unmodifiable(_tasks);

  @override
  Future<void> addTask(String title) async => _tasks.add(title);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final TaskRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testing Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: TaskListPage(
        taskService: TaskService(repository ?? InMemoryTaskRepository()),
      ),
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key, required this.taskService});

  final TaskService taskService;

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _controller = TextEditingController();
  List<String> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await widget.taskService.loadTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat tugas: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    final text = _controller.text;
    if (!isValidTaskTitle(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tugas tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await widget.taskService.createTask(text);
      _controller.clear();
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar tugas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('task-title-field'),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tambah tugas baru...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const Key('save-task-button'),
                  tooltip: 'Simpan',
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _tasks.isEmpty
                ? const Center(child: Text('Belum ada tugas tercatat.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(_tasks[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
