import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<RankingRow>> _rows = EcoApi().ranking();

  @override
  Widget build(BuildContext context) {
    final me = EcoApi().currentUser?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Reyting')),
      body: AsyncView<List<RankingRow>>(
        future: _rows,
        onRetry: () => setState(() => _rows = EcoApi().ranking()),
        builder: (context, rows) => RefreshIndicator(
          onRefresh: () async {
            setState(() => _rows = EcoApi().ranking());
            await _rows;
          },
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Faqat tekshiruvdan o\'tgan amallar hisoblanadi: tasdiqlangan ekish +5, '
                  '30 kunlik kuzatuv +2, 90 kunda tirik +5.',
                ),
              ),
              if (rows.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Hali ball olganlar yo\'q.')),
              for (final r in rows)
                ListTile(
                  selected: r.userId == me,
                  leading: CircleAvatar(child: Text('${r.position}')),
                  title: Text(r.displayName),
                  subtitle: Text('${r.verifiedTrees} ta tasdiqlangan daraxt'),
                  trailing: Text('${r.points} ball', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
