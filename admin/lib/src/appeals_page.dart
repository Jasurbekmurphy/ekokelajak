import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

import 'common.dart';

/// Qaror ustidan murojaatlar. Qabul qilinsa qayd qayta tekshiruvga tushadi.
class AppealsPage extends StatelessWidget {
  const AppealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = EcoApi();
    return MasterDetail(
      title: 'Murojaatlar',
      emptyText: 'Ochiq murojaat yo\'q',
      load: api.openAppeals,
      subtitle: (t) => t.status.label,
      detail: (tree, onDone) {
        final appeal = tree.appeals.first;
        Future<bool> resolve(BuildContext context, bool accept) async {
          final input = await askReason(
            context,
            title: accept ? 'Murojaatni qabul qilish' : 'Murojaatni rad etish',
            reasonRequired: false,
          );
          if (input == null) return false;
          await api.resolveAppeal(appeal.id, accept, comment: input.comment);
          onDone();
          return true;
        }

        return Column(
          children: [
            Expanded(
              child: TreeInfo(
                tree: tree,
                header: Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.gavel),
                    title: Text(appeal.message),
                    subtitle: Text('Murojaat: ${dateTimeFmt.format(appeal.createdAt.toLocal())}'),
                  ),
                ),
              ),
            ),
            ActionBar(
              actions: [
                (
                  label: 'Qabul qilish (qayta tekshirish)',
                  icon: Icons.replay,
                  color: Colors.green,
                  run: (c) => resolve(c, true),
                ),
                (label: 'Rad etish', icon: Icons.close, color: Colors.red, run: (c) => resolve(c, false)),
              ],
            ),
          ],
        );
      },
    );
  }
}
