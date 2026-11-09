import 'package:flutter/material.dart';

import 'cached_repository.dart';
import 'optimized_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final ItemRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Optimization Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: OptimizedListPage(repository: repository ?? CachedItemRepository()),
    );
  }
}
