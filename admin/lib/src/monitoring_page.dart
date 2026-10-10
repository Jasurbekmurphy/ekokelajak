import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

import 'common.dart';

/// 30/90 kunlik kuzatuv suratlarini birinchi suratlar bilan solishtirib baholash.
class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = EcoApi();
    return MasterDetail(
      title: 'Kuzatuvlar',
      emptyText: 'Tekshiriladigan kuzatuv yo\'q',
      load: api.monitoringQueue,
      subtitle: (t) => t.checks.map((c) => c.kindLabel).join(', '),
      detail: (tree, onDone) {
        final check = tree.checks.first;
        Future<bool> decide(BuildContext context, MonitoringStatus result) async {
          final input = await askReason(context, title: result.label, reasonRequired: false);
          if (input == null) return false;
          await api.reviewMonitoring(check.id, result, comment: input.comment);
          onDone();
          return true;
        }

        return Column(
          children: [
            Expanded(
              child: TreeInfo(
                tree: tree,
                header: Card(
                  color: Colors.amber.shade50,
                  child: ListTile(
                    title: Text(check.kindLabel),
                    subtitle: Text(
                      [
                        'Yuborilgan: ${check.submittedAt == null ? '—' : dateTimeFmt.format(check.submittedAt!.toLocal())}',
                        ...check.flags.map(flagLabel),
                      ].join(' · '),
                    ),
                  ),
                ),
              ),
            ),
            ActionBar(
              actions: [
                (label: 'Tirik', icon: Icons.eco, color: Colors.green, run: (c) => decide(c, MonitoringStatus.alive)),
                (
                  label: 'Qurigan',
                  icon: Icons.dangerous,
                  color: Colors.brown,
                  run: (c) => decide(c, MonitoringStatus.dead),
                ),
                (
                  label: 'Topilmadi',
                  icon: Icons.search_off,
                  color: Colors.blueGrey,
                  run: (c) => decide(c, MonitoringStatus.notFound),
                ),
                (
                  label: 'Dalil yetarli emas',
                  icon: Icons.help_outline,
                  color: Colors.orange,
                  run: (c) => decide(c, MonitoringStatus.insufficient),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
