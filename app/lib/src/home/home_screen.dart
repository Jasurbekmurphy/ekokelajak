import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

import '../trees/tree_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onAddTree});
  final VoidCallback onAddTree;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeData {
  _HomeData(this.trees, this.stats);
  final List<TreeRecord> trees;
  final StatsSummary stats;
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _data = _load();

  Future<_HomeData> _load() async {
    final api = EcoApi();
    final results = await Future.wait([api.myTrees(), api.stats()]);
    return _HomeData(results[0] as List<TreeRecord>, results[1] as StatsSummary);
  }

  static const _verified = [
    TreeStatus.verifiedPlanted,
    TreeStatus.monitoringDue,
    TreeStatus.aliveConfirmed,
    TreeStatus.deadOrMissing,
  ];
  static const _pending = [TreeStatus.submitted, TreeStatus.underReview, TreeStatus.needsMoreEvidence];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoKelajak')),
      body: AsyncView<_HomeData>(
        future: _data,
        onRetry: () => setState(() => _data = _load()),
        builder: (context, d) {
          final verified = d.trees.where((t) => _verified.contains(t.status)).length;
          final pending = d.trees.where((t) => _pending.contains(t.status)).length;
          final due = [
            for (final t in d.trees)
              for (final c in t.checks)
                if (c.canSubmit) (tree: t, check: c),
          ];
          final needEvidence = d.trees.where((t) => t.status == TreeStatus.needsMoreEvidence).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _data = _load());
              await _data;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: widget.onAddTree,
                    icon: const Icon(Icons.add_circle, size: 28),
                    label: const Text('Daraxt qo\'shish', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCard(label: 'Tasdiqlangan', value: '$verified', color: Colors.green),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Tekshiruvda', value: '$pending', color: Colors.blueGrey),
                  ],
                ),
                if (due.isNotEmpty || needEvidence.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Sizdan kutilmoqda', style: Theme.of(context).textTheme.titleMedium),
                  for (final item in due)
                    Card(
                      color: Colors.amber.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.photo_camera, color: Colors.amber),
                        title: Text('${item.check.kindLabel}: ${item.tree.speciesName ?? 'daraxt'}'),
                        subtitle: const Text('Daraxtning hozirgi holatini suratga oling'),
                        onTap: () => _open(item.tree.id),
                      ),
                    ),
                  for (final t in needEvidence)
                    Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.info, color: Colors.orange),
                        title: Text('Qo\'shimcha dalil kerak: ${t.speciesName ?? 'daraxt'}'),
                        subtitle: Text(t.lastDecision?.comment ?? 'Batafsil ko\'rish uchun bosing'),
                        onTap: () => _open(t.id),
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                Text('Umumiy natijalar', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tasdiqlangan ekishlar: ${d.stats.verified}'),
                        Text('Yuborilgan qaydlar: ${d.stats.submitted}'),
                        if (d.stats.d90Decided > 0)
                          Text(
                            '90 kunda tirik: ${d.stats.d90Alive} / ${d.stats.d90Decided} '
                            '(${d.stats.d90SurvivalPct}%), kuzatuvsiz: ${d.stats.d90Overdue}',
                          ),
                        const SizedBox(height: 8),
                        const Text(
                          'Faqat tekshiruvdan o\'tgan ma\'lumotlar hisoblanadi.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _open(String treeId) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TreeDetailScreen(treeId: treeId)));
    setState(() => _data = _load());
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
