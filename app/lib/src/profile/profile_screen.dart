import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';

import '../trees/tree_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileData {
  _ProfileData(this.profile, this.points, this.trees);
  final Profile profile;
  final int points;
  final List<TreeRecord> trees;
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = EcoApi();
  late Future<_ProfileData> _data = _load();

  Future<_ProfileData> _load() async {
    final r = await Future.wait([_api.myProfile(), _api.myPoints(), _api.myTrees()]);
    return _ProfileData(r[0] as Profile, r[1] as int, r[2] as List<TreeRecord>);
  }

  void _reload() => setState(() => _data = _load());

  Future<void> _editName(String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ommaviy ism'),
        content: TextField(controller: controller, maxLength: 40, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Saqlash')),
        ],
      ),
    );
    if (name == null || name.trim().length < 2) return;
    try {
      await _api.updateDisplayName(name);
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [IconButton(onPressed: _api.signOut, icon: const Icon(Icons.logout), tooltip: 'Chiqish')],
      ),
      body: AsyncView<_ProfileData>(
        future: _data,
        onRetry: _reload,
        builder: (context, d) => RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _data;
          },
          child: ListView(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(d.profile.displayName, style: Theme.of(context).textTheme.titleLarge),
                subtitle: Text('${d.points} ball'),
                trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _editName(d.profile.displayName)),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text('Mening daraxtlarim (${d.trees.length})', style: Theme.of(context).textTheme.titleMedium),
              ),
              if (d.trees.isEmpty)
                const Padding(padding: EdgeInsets.all(16), child: Text('Hali daraxt qo\'shmagansiz.')),
              for (final t in d.trees)
                ListTile(
                  leading: Icon(Icons.park, color: t.status.color),
                  title: Text(t.speciesName ?? 'Noma\'lum tur'),
                  subtitle: Text(dateFmt.format(t.plantedAt.toLocal())),
                  trailing: StatusChip(t.status),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TreeDetailScreen(treeId: t.id)));
                    _reload();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
