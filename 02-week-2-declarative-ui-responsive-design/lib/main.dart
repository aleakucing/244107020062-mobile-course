import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                semanticLabel: isDark ? 'Mode Gelap' : 'Mode Terang',
              ),
              const SizedBox(width: 4),
              Semantics(
                label: 'Beralih mode tema',
                value: isDark ? 'Dark' : 'Light',
                child: CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 550 ? 2 : 1;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const StudentProfileCard(),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.6,
                children: const [
                  DashboardCard(title: 'Assignments', value: '8'),
                  DashboardCard(title: 'Attendance', value: '92%'),
                  DashboardCard(title: 'Portofolio', value: 'Ready'),
                  DashboardCard(title: 'Current week', value: '02'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class StudentProfileCard extends StatelessWidget {
  const StudentProfileCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama Mahasiswa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Muchammad Ibrahim Al Amin'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Row(
              children: [
                Text('NIM'),
                Expanded(child: Text('244107020062', textAlign: TextAlign.end)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text('Kelas'),
                Expanded(child: Text('TI-3F', textAlign: TextAlign.end)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text('Email'),
                Expanded(
                  child: Text(
                    '244107020062@polinema.ac.id',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}
