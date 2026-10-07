import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "../providers/auth_provider.dart";
import "../routes.dart";

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: "mhs@kampus.ac.id");
  final _sandi = TextEditingController(text: "rahasia123");

  @override
  void dispose() {
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Masuk Kampus")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Masuk untuk membaca pengumuman kampus."),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: "Email kampus"),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sandi,
            decoration: const InputDecoration(labelText: "Kata sandi"),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          if (auth.hasError)
            Text("${auth.error}",
                style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: auth.isLoading
                ? null
                : () async {
                    await ref
                        .read(authStateProvider.notifier)
                        .login(_email.text.trim(), _sandi.text);
                    if (context.mounted &&
                        ref.read(authStateProvider).value == true) {
                      context.go(routeHome);
                    }
                  },
            child: auth.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Masuk"),
          ),
        ],
      ),
    );
  }
}
