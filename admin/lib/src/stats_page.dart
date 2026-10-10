import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

/// README 11-bo'limdagi ko'rsatkichlar. Formulalar bazadagi `stats_summary` ko'rinishida.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncView<StatsSummary>(
      future: EcoApi().stats(),
      builder: (context, s) {
        String pct(double? v) => v == null ? '—' : '$v%';
        final rows = [
          ('Yuborilgan qaydlar', '${s.submitted}'),
          ('Tasdiqlangan ekishlar', '${s.verified}'),
          ('Rad etilgan', '${s.rejected}'),
          ('Tasdiqlash ulushi (tasdiqlangan / qaror chiqarilgan)', pct(s.approvalRatePct)),
          ('90 kunlik kuzatuvi baholangan', '${s.d90Decided}'),
          ('90 kunda tirik', '${s.d90Alive}'),
          ('90 kunlik kuzatuvi bajarilmagan', '${s.d90Overdue}'),
          ('90 kunlik yashab qolish ulushi', pct(s.d90SurvivalPct)),
          ('Takroriy deb belgilangan qaydlar ulushi', pct(s.duplicateRatePct)),
        ];
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Statistika', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            for (final (label, value) in rows)
              ListTile(
                title: Text(label),
                trailing: Text(value, style: Theme.of(context).textTheme.titleLarge),
              ),
          ],
        );
      },
    );
  }
}
