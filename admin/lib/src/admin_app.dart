import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'appeals_page.dart';
import 'monitoring_page.dart';
import 'queue_page.dart';
import 'stats_page.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoKelajak — moderator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)), useMaterial3: true),
      home: Env.isConfigured
          ? const _Gate()
          : const Scaffold(body: Center(child: Text('Supabase sozlanmagan: --dart-define-from-file=env.json'))),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final api = EcoApi();
    return StreamBuilder<AuthState>(
      stream: api.authChanges,
      builder: (context, _) {
        if (api.currentUser == null) return const _Login();
        return FutureBuilder<Profile>(
          key: ValueKey(api.currentUser!.id),
          future: api.myProfile(),
          builder: (context, snap) {
            if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            if (!snap.data!.isReviewer) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Bu panel faqat moderatorlar uchun.'),
                      TextButton(onPressed: api.signOut, child: const Text('Chiqish')),
                    ],
                  ),
                ),
              );
            }
            return _Shell(profile: snap.data!);
          },
        );
      },
    );
  }
}

class _Login extends StatefulWidget {
  const _Login();

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      await EcoApi().signIn(_email.text, _password.text);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('EcoKelajak moderator paneli', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Parol'),
                onSubmitted: (_) => _signIn(),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _busy ? null : _signIn, child: const Text('Kirish')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({required this.profile});
  final Profile profile;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [QueuePage(), MonitoringPage(), AppealsPage(), StatsPage()];
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.park, color: Color(0xFF2E7D32), size: 32),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.profile.displayName, style: const TextStyle(fontSize: 12)),
                      IconButton(onPressed: EcoApi().signOut, icon: const Icon(Icons.logout), tooltip: 'Chiqish'),
                    ],
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.inbox), label: Text('Navbat')),
              NavigationRailDestination(icon: Icon(Icons.event_repeat), label: Text('Kuzatuvlar')),
              NavigationRailDestination(icon: Icon(Icons.gavel), label: Text('Murojaatlar')),
              NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Statistika')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages[_index]),
        ],
      ),
    );
  }
}
