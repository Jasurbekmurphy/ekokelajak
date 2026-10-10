import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/admin_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('uz');
  await Env.init();
  runApp(const AdminApp());
}
