import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login_screen.dart';
import 'shell.dart';

class EcoKelajakApp extends StatelessWidget {
  const EcoKelajakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoKelajak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)), useMaterial3: true),
      home: Env.isConfigured ? const _AuthGate() : const _NotConfigured(),
    );
  }
}

/// Sessiya bo'lsa asosiy ilova, bo'lmasa kirish sahifasi.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final api = EcoApi();
    return StreamBuilder<AuthState>(
      stream: api.authChanges,
      builder: (context, _) => api.currentUser == null ? const LoginScreen() : const AppShell(),
    );
  }
}

class _NotConfigured extends StatelessWidget {
  const _NotConfigured();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Supabase sozlanmagan.\n\nIlovani `--dart-define-from-file=env.json` bilan ishga tushiring '
            '(namuna: env.example.json).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
