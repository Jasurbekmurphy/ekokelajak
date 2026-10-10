import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final api = EcoApi();
    try {
      if (_register) {
        final signedIn = await api.signUp(_email.text, _password.text, _name.text);
        if (!signedIn && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Emailingizga tasdiqlash xati yuborildi. Tasdiqlab, keyin kiring.')),
          );
          setState(() => _register = false);
        }
      } else {
        await api.signIn(_email.text, _password.text);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.park, size: 72, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 8),
                  Text('EcoKelajak', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Ekkan daraxtingizni qayd eting va kuzating', textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  if (_register) ...[
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Ommaviy ism yoki taxallus',
                        helperText: 'Reytingda ko\'rinadi. To\'liq ism shart emas.',
                      ),
                      validator: (v) => (v ?? '').trim().length < 2 ? 'Kamida 2 ta belgi' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => (v ?? '').contains('@') ? null : 'Email noto\'g\'ri',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Parol'),
                    validator: (v) => (v ?? '').length < 6 ? 'Kamida 6 ta belgi' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? 'Kuting...' : (_register ? 'Ro\'yxatdan o\'tish' : 'Kirish')),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => setState(() => _register = !_register),
                    child: Text(_register ? 'Akkauntim bor — kirish' : 'Yangi akkaunt ochish'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
