import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

import 'common.dart';

/// Yangi ekish qaydlari: tasdiqlash, dalil so'rash, rad etish, yuqoriga yuborish.
class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = EcoApi();
    return MasterDetail(
      title: 'Tekshiruv navbati',
      emptyText: 'Navbat bo\'sh',
      load: api.reviewQueue,
      subtitle: (t) => '${dateTimeFmt.format(t.createdAt.toLocal())} · ${t.status.label}',
      detail: (tree, onDone) {
        Future<bool> decide(BuildContext context, String decision, String title, {bool reason = false}) async {
          final input = await askReason(context, title: title, reasonRequired: reason);
          if (input == null) return false;
          await api.reviewTree(tree.id, decision, reasonCode: input.reason, comment: input.comment);
          onDone();
          return true;
        }

        return Column(
          children: [
            Expanded(child: TreeInfo(tree: tree)),
            ActionBar(
              actions: [
                (
                  label: 'Tasdiqlash',
                  icon: Icons.check,
                  color: Colors.green,
                  run: (c) => decide(c, 'approve', 'Ekishni tasdiqlash'),
                ),
                (
                  label: 'Qo\'shimcha dalil',
                  icon: Icons.add_a_photo,
                  color: Colors.orange,
                  run: (c) => decide(c, 'request_evidence', 'Qo\'shimcha dalil so\'rash', reason: true),
                ),
                (
                  label: 'Rad etish',
                  icon: Icons.close,
                  color: Colors.red,
                  run: (c) => decide(c, 'reject', 'Rad etish', reason: true),
                ),
                if (tree.status != TreeStatus.underReview)
                  (
                    label: 'Yuqoriga yuborish',
                    icon: Icons.upgrade,
                    color: Colors.indigo,
                    run: (c) => decide(c, 'escalate', 'Qo\'shimcha tekshiruvga yuborish'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
