import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api.dart';
import 'models.dart';

final dateFmt = DateFormat('d MMMM y', 'uz');
final dateTimeFmt = DateFormat('d MMM y, HH:mm', 'uz');

/// Xatoni foydalanuvchiga tushunarli matnga aylantiradi.
String errorText(Object e) {
  if (e is PostgrestException) return e.message;
  if (e is AuthException) return e.message;
  if (e is StorageException) return 'Faylni yuklab bo\'lmadi: ${e.message}';
  return e.toString().replaceFirst('Exception: ', '');
}

void showError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText(e))));
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final TreeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: status.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.label,
        style: TextStyle(color: status.color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

/// FutureBuilder ustidan yuklanish/xato/ma'lumot holatlari va qayta yuklash.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.future, required this.builder, this.onRetry});

  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errorText(snap.error!), textAlign: TextAlign.center),
                  if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Qayta urinish')),
                ],
              ),
            ),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return builder(context, snap.data as T);
      },
    );
  }
}

/// Yopiq bucket'dagi suratni vaqtinchalik havola orqali ko'rsatadi.
class EvidenceImage extends StatelessWidget {
  const EvidenceImage(this.storageKey, {super.key, this.height = 180});
  final String storageKey;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FutureBuilder<String>(
        future: EcoApi().signedUrl(storageKey),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(snap.data!, fit: BoxFit.cover, width: double.infinity),
          );
        },
      ),
    );
  }
}
