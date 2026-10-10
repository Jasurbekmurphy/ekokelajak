import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

import '../common/capture_screen.dart';

/// Bitta daraxt: holat, sabab, suratlar, kuzatuvlar, tarix va murojaat.
class TreeDetailScreen extends StatefulWidget {
  const TreeDetailScreen({super.key, required this.treeId});
  final String treeId;

  @override
  State<TreeDetailScreen> createState() => _TreeDetailScreenState();
}

class _TreeDetailScreenState extends State<TreeDetailScreen> {
  final _api = EcoApi();
  late Future<TreeRecord> _tree = _api.tree(widget.treeId);
  bool _busy = false;

  void _reload() => setState(() => _tree = _api.tree(widget.treeId));

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitMonitoring(MonitoringCheck check) async {
    final photo = await CaptureScreen.open(
      context,
      title: check.kindLabel,
      hint: 'Daraxtni birinchi suratdagidek burchakdan, atrofi bilan birga suratga oling.',
    );
    if (photo == null) return;
    await _run(() async {
      final evidence = await photo.upload(_api, EvidenceType.monitoringPhoto);
      await _api.submitMonitoring(
        checkId: check.id,
        evidence: evidence,
        lat: photo.position.latitude,
        lng: photo.position.longitude,
        accuracyM: photo.position.accuracy,
      );
    }, 'Kuzatuv surati yuborildi');
  }

  Future<void> _addEvidence(TreeRecord tree, EvidenceType type) async {
    final photo = await CaptureScreen.open(
      context,
      title: type.label,
      hint: 'Moderator so\'ragan dalilni suratga oling.',
    );
    if (photo == null) return;
    await _run(() async {
      final evidence = await photo.upload(_api, type);
      await _api.addEvidence(tree.id, [evidence]);
    }, 'Dalil qo\'shildi, qayd qayta tekshiruvga yuborildi');
  }

  Future<void> _appeal(TreeRecord tree) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qaror ustidan murojaat'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 1000,
          decoration: const InputDecoration(hintText: 'Nima uchun qaror noto\'g\'ri deb hisoblaysiz?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Yuborish')),
        ],
      ),
    );
    if (message == null || message.trim().length < 5) return;
    await _run(() => _api.openAppeal(tree.id, message), 'Murojaat yuborildi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daraxt')),
      body: AsyncView<TreeRecord>(
        future: _tree,
        onRetry: _reload,
        builder: (context, t) {
          final decision = t.lastDecision;
          final canAppeal =
              const [TreeStatus.rejected, TreeStatus.needsMoreEvidence, TreeStatus.deadOrMissing].contains(t.status) &&
              !t.hasOpenAppeal;
          return AbsorbPointer(
            absorbing: _busy,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_busy) const LinearProgressIndicator(),
                Row(
                  children: [
                    Expanded(
                      child: Text(t.speciesName ?? 'Noma\'lum tur', style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    StatusChip(t.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Ekilgan: ${dateTimeFmt.format(t.plantedAt.toLocal())} · ${t.siteType.label}'),
                if (t.note != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(t.note!)),
                if (decision != null && decision.decision != 'approve')
                  Card(
                    color: t.status.color.withValues(alpha: 0.08),
                    margin: const EdgeInsets.only(top: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(decision.decisionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (decision.reasonCode != null) Text(reasonLabel(decision.reasonCode!)),
                          if (decision.comment != null) Text(decision.comment!),
                        ],
                      ),
                    ),
                  ),
                if (t.status == TreeStatus.needsMoreEvidence) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _addEvidence(t, EvidenceType.plantingPhoto),
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Ekish surati'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _addEvidence(t, EvidenceType.afterPhoto),
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Yakuniy holat surati'),
                      ),
                    ],
                  ),
                ],
                if (canAppeal)
                  TextButton.icon(
                    onPressed: () => _appeal(t),
                    icon: const Icon(Icons.gavel),
                    label: const Text('Qaror ustidan murojaat qilish'),
                  ),
                if (t.hasOpenAppeal) const Text('Murojaatingiz ko\'rib chiqilmoqda.'),
                if (t.checks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Kuzatuvlar', style: Theme.of(context).textTheme.titleMedium),
                  for (final c in t.checks)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: Text(c.kindLabel),
                      subtitle: Text('${dateFmt.format(c.scheduledFor.toLocal())} · ${c.status.label}'),
                      trailing: c.canSubmit
                          ? FilledButton(onPressed: () => _submitMonitoring(c), child: const Text('Suratga olish'))
                          : null,
                    ),
                ],
                const SizedBox(height: 16),
                Text('Dalillar', style: Theme.of(context).textTheme.titleMedium),
                for (final e in t.evidence) ...[
                  const SizedBox(height: 8),
                  Text('${e.type.label} · ${dateTimeFmt.format(e.capturedAt.toLocal())}'),
                  const SizedBox(height: 4),
                  EvidenceImage(e.storageKey),
                ],
                const SizedBox(height: 16),
                Text('Tarix', style: Theme.of(context).textTheme.titleMedium),
                for (final r in t.reviews.reversed)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(r.decisionLabel),
                    subtitle: Text(
                      [
                        dateTimeFmt.format(r.createdAt.toLocal()),
                        if (r.comment != null && r.decision != 'system_flag') r.comment!,
                      ].join(' · '),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
