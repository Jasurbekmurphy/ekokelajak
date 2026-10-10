import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../common/capture_screen.dart';
import '../common/captured_photo.dart';
import '../common/location.dart';
import '../map/map_screen.dart' show osmTiles;

/// Daraxt qo'shish: 1) joy  2) suratlar  3) ma'lumot  → yuborish.
class AddTreeScreen extends StatefulWidget {
  const AddTreeScreen({super.key, required this.onSubmitted});
  final VoidCallback onSubmitted;

  @override
  State<AddTreeScreen> createState() => _AddTreeScreenState();
}

class _AddTreeScreenState extends State<AddTreeScreen> {
  final _api = EcoApi();
  int _step = 0;

  Position? _position;
  bool _locating = false;
  SiteType? _siteType;
  bool _permission = false;

  CapturedPhoto? _plantingPhoto;
  CapturedPhoto? _afterPhoto;

  late final Future<List<Species>> _species = _api.species();
  int? _speciesId;
  final _note = TextEditingController();

  bool _submitting = false;
  String _progress = '';

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      final p = await currentPosition();
      setState(() => _position = p);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _capture(bool planting) async {
    final photo = await CaptureScreen.open(
      context,
      title: planting ? 'Ekish jarayoni' : 'Yakuniy holat',
      hint: planting
          ? 'Ko\'chat, chuqur va tuproq ko\'rinadigan qilib ekish jarayonini suratga oling.'
          : 'Ekilgan daraxtni atrofi bilan birga, umumiy ko\'rinishda suratga oling.',
    );
    if (photo == null) return;
    setState(() => planting ? _plantingPhoto = photo : _afterPhoto = photo);
  }

  bool get _canContinue => switch (_step) {
    0 => _position != null && _siteType != null,
    1 => _plantingPhoto != null && _afterPhoto != null,
    _ => !_submitting,
  };

  Future<void> _submit() async {
    final position = _position!;
    setState(() {
      _submitting = true;
      _progress = 'Suratlar yuklanmoqda...';
    });
    try {
      final evidence = [
        await _plantingPhoto!.upload(_api, EvidenceType.plantingPhoto),
        await _afterPhoto!.upload(_api, EvidenceType.afterPhoto),
      ];
      setState(() => _progress = 'Qayd yuborilmoqda...');
      await _api.submitTree(
        lat: position.latitude,
        lng: position.longitude,
        accuracyM: position.accuracy,
        siteType: _siteType!,
        permissionConfirmed: _permission,
        speciesId: _speciesId,
        note: _note.text,
        evidence: evidence,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Qayd yuborildi! Moderator tekshirgach xaritada paydo bo\'ladi.')));
      widget.onSubmitted();
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daraxt qo\'shish')),
      body: Stepper(
        currentStep: _step,
        onStepTapped: _submitting ? null : (i) => setState(() => _step = i < _step ? i : _step),
        onStepContinue: !_canContinue ? null : (_step == 2 ? _submit : () => setState(() => _step++)),
        onStepCancel: _step == 0 || _submitting ? null : () => setState(() => _step--),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: Text(_step == 2 ? (_submitting ? _progress : 'Yuborish') : 'Davom etish'),
              ),
              const SizedBox(width: 8),
              if (details.onStepCancel != null)
                TextButton(onPressed: details.onStepCancel, child: const Text('Orqaga')),
            ],
          ),
        ),
        steps: [
          Step(title: const Text('Joyni tasdiqlash'), isActive: _step >= 0, content: _locationStep()),
          Step(title: const Text('Suratlar'), isActive: _step >= 1, content: _photosStep()),
          Step(title: const Text('Daraxt haqida'), isActive: _step >= 2, content: _infoStep()),
        ],
      ),
    );
  }

  Widget _locationStep() {
    final p = _position;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Joylashuv faqat moderatorga aniq ko\'rinadi. Ommaviy xaritada taxminan 100 m aniqlikda ko\'rsatiladi.',
        ),
        const SizedBox(height: 12),
        if (p != null) ...[
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(p.latitude, p.longitude),
                  initialZoom: 17,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  osmTiles(),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(p.latitude, p.longitude),
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Aniqlik: ${p.accuracy.toStringAsFixed(0)} m'),
          if (p.accuracy > 30)
            const Text(
              'GPS aniqligi past. Ochiq joyga chiqib, qayta aniqlang.',
              style: TextStyle(color: Colors.orange),
            ),
        ],
        OutlinedButton.icon(
          onPressed: _locating ? null : _locate,
          icon: const Icon(Icons.my_location),
          label: Text(_locating ? 'Aniqlanmoqda...' : (p == null ? 'Joylashuvni aniqlash' : 'Qayta aniqlash')),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<SiteType>(
          initialValue: _siteType,
          decoration: const InputDecoration(labelText: 'Joy turi'),
          items: [for (final s in SiteType.values) DropdownMenuItem(value: s, child: Text(s.label))],
          onChanged: (v) => setState(() => _siteType = v),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _permission,
          onChanged: (v) => setState(() => _permission = v ?? false),
          title: const Text('Bu joyda daraxt ekishga ruxsat bor'),
          subtitle: const Text('Masalan, maktab, mahalla yoki tadbir tashkilotchisi ruxsat bergan.'),
        ),
      ],
    );
  }

  Widget _photosStep() {
    Widget tile(String title, CapturedPhoto? photo, bool planting) => Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _capture(planting),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: photo == null
                  ? const ColoredBox(color: Color(0xFFEFEFEF), child: Icon(Icons.camera_alt, size: 32))
                  : Image.memory(photo.bytes, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(photo == null ? 'Suratga olish uchun bosing' : 'Olindi. Qayta olish uchun bosing'),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        const Text('Suratlar faqat ilova kamerasida olinadi.'),
        const SizedBox(height: 8),
        tile('1. Ekish jarayoni', _plantingPhoto, true),
        tile('2. Yakuniy holat', _afterPhoto, false),
      ],
    );
  }

  Widget _infoStep() {
    return FutureBuilder<List<Species>>(
      future: _species,
      builder: (context, snap) => Column(
        children: [
          DropdownButtonFormField<int>(
            initialValue: _speciesId,
            decoration: const InputDecoration(labelText: 'Daraxt turi'),
            items: [for (final s in snap.data ?? const <Species>[]) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: (v) => setState(() => _speciesId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Izoh (ixtiyoriy)'),
          ),
        ],
      ),
    );
  }
}
