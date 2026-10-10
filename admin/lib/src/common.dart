import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Chapda ro'yxat, o'ngda tanlangan qayd. Qaror qabul qilingach ro'yxat yangilanadi.
class MasterDetail extends StatefulWidget {
  const MasterDetail({
    super.key,
    required this.title,
    required this.emptyText,
    required this.load,
    required this.subtitle,
    required this.detail,
  });

  final String title;
  final String emptyText;
  final Future<List<TreeRecord>> Function() load;
  final String Function(TreeRecord) subtitle;
  final Widget Function(TreeRecord tree, VoidCallback onDone) detail;

  @override
  State<MasterDetail> createState() => _MasterDetailState();
}

class _MasterDetailState extends State<MasterDetail> {
  late Future<List<TreeRecord>> _items = widget.load();
  String? _selectedId;

  void _reload() => setState(() {
    _items = widget.load();
    _selectedId = null;
  });

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<TreeRecord>>(
      future: _items,
      onRetry: _reload,
      builder: (context, items) {
        final selected = items.where((t) => t.id == _selectedId).firstOrNull ?? items.firstOrNull;
        return Row(
          children: [
            SizedBox(
              width: 340,
              child: Column(
                children: [
                  ListTile(
                    title: Text('${widget.title} (${items.length})', style: Theme.of(context).textTheme.titleMedium),
                    trailing: IconButton(onPressed: _reload, icon: const Icon(Icons.refresh), tooltip: 'Yangilash'),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: items.isEmpty
                        ? Center(child: Text(widget.emptyText))
                        : ListView(
                            children: [
                              for (final t in items)
                                ListTile(
                                  selected: t.id == selected?.id,
                                  leading: Icon(
                                    t.flags.isEmpty ? Icons.park : Icons.flag,
                                    color: t.flags.isEmpty ? Colors.green : Colors.orange,
                                  ),
                                  title: Text('${t.authorName ?? '—'} · ${t.speciesName ?? 'Noma\'lum tur'}'),
                                  subtitle: Text(widget.subtitle(t)),
                                  onTap: () => setState(() => _selectedId = t.id),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: selected == null
                  ? const SizedBox()
                  : KeyedSubtree(key: ValueKey(selected.id), child: widget.detail(selected, _reload)),
            ),
          ],
        );
      },
    );
  }
}

/// Moderator ko'radigan barcha ma'lumot: suratlar, joy, vaqtlar, belgilar, tarix.
class TreeInfo extends StatelessWidget {
  const TreeInfo({super.key, required this.tree, this.evidenceTypes, this.header});

  final TreeRecord tree;
  final Set<EvidenceType>? evidenceTypes;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final t = tree;
    final evidence = t.evidence.where((e) => evidenceTypes == null || evidenceTypes!.contains(e.type)).toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    final point = LatLng(t.lat, t.lng);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ?header,
        Row(
          children: [
            Expanded(
              child: Text(
                '${t.speciesName ?? 'Noma\'lum tur'} — ${t.authorName ?? ''}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            StatusChip(t.status),
          ],
        ),
        const SizedBox(height: 8),
        if (t.flags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in t.flags)
                Chip(
                  avatar: const Icon(Icons.flag, size: 16, color: Colors.orange),
                  label: Text(flagLabel(f)),
                  backgroundColor: Colors.orange.shade50,
                ),
            ],
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final e in evidence)
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EvidenceImage(e.storageKey, height: 240),
                    const SizedBox(height: 4),
                    Text(e.type.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      'Olingan: ${dateTimeFmt.format(e.capturedAt.toLocal())}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Server qabul qildi: ${dateTimeFmt.format(e.serverReceivedAt.toLocal())}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (e.accuracyM != null)
                      Text('GPS: ±${e.accuracyM!.toStringAsFixed(0)} m', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 320,
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(initialCenter: point, initialZoom: 17),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'uz.ekokelajak.admin',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: point,
                          radius: t.accuracyM,
                          useRadiusInMeter: true,
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 1,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Koordinata: ${t.lat.toStringAsFixed(6)}, ${t.lng.toStringAsFixed(6)}'),
                  Text('GPS aniqligi: ±${t.accuracyM.toStringAsFixed(0)} m'),
                  Text('Joy turi: ${t.siteType.label}'),
                  Text('Ruxsat tasdiqlangan: ${t.permissionConfirmed ? 'ha' : 'yo\'q'}'),
                  Text('Yuborilgan: ${dateTimeFmt.format(t.createdAt.toLocal())}'),
                  if (t.note != null) Text('Izoh: ${t.note}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Tarix', style: Theme.of(context).textTheme.titleMedium),
        for (final r in t.reviews.reversed)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(r.isSystem ? Icons.smart_toy_outlined : Icons.person_outline, size: 18),
            title: Text([r.decisionLabel, if (r.reasonCode != null) reasonLabel(r.reasonCode!)].join(' — ')),
            subtitle: Text([dateTimeFmt.format(r.createdAt.toLocal()), if (r.comment != null) r.comment!].join(' · ')),
          ),
      ],
    );
  }
}

/// Qaror tugmalari paneli: bosilganda amalni bajaradi va natijani ko'rsatadi.
class ActionBar extends StatefulWidget {
  const ActionBar({super.key, required this.actions});
  final List<({String label, IconData icon, Color color, Future<bool> Function(BuildContext) run})> actions;

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final a in widget.actions)
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: a.color),
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await a.run(context);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              icon: Icon(a.icon),
              label: Text(a.label),
            ),
        ],
      ),
    );
  }
}

/// Sabab va izoh so'raydigan dialog. Bekor qilinsa null.
Future<({String? reason, String comment})?> askReason(
  BuildContext context, {
  required String title,
  required bool reasonRequired,
}) {
  String? reason;
  final comment = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reasonRequired)
                DropdownButtonFormField<String>(
                  initialValue: reason,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Standart sabab'),
                  items: [
                    for (final e in reasonLabels.entries)
                      DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => reason = v),
                ),
              TextField(
                controller: comment,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Foydalanuvchiga izoh'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          FilledButton(
            onPressed: reasonRequired && reason == null
                ? null
                : () => Navigator.pop(context, (reason: reason, comment: comment.text)),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    ),
  );
}
