import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase manzili va ommaviy (publishable / anon) kaliti
/// `--dart-define-from-file=env.json` orqali beriladi. Maxfiy (secret) kalitni bu yerga qo'ymang.
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  static Future<void> init() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  }
}
