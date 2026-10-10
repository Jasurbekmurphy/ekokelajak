import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

TileLayer osmTiles() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'uz.ekokelajak.ekokelajak',
);

/// Faqat tasdiqlangan daraxtlar, ~100 m aniqlikda.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<PublicTree>> _trees = EcoApi().publicTrees();

  void _show(PublicTree t) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.species ?? 'Noma\'lum tur', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            StatusChip(t.status),
            if (t.plantedOn != null) ...[const SizedBox(height: 8), Text('Ekilgan: ${dateFmt.format(t.plantedOn!)}')],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xarita')),
      body: AsyncView<List<PublicTree>>(
        future: _trees,
        onRetry: () => setState(() => _trees = EcoApi().publicTrees()),
        builder: (context, trees) {
          final center = trees.isEmpty
              ? const LatLng(41.3111, 69.2797) // Toshkent
              : LatLng(
                  trees.map((t) => t.lat).reduce((a, b) => a + b) / trees.length,
                  trees.map((t) => t.lng).reduce((a, b) => a + b) / trees.length,
                );
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: trees.isEmpty ? 11 : 13),
                children: [
                  osmTiles(),
                  MarkerLayer(
                    markers: [
                      for (final t in trees)
                        Marker(
                          point: LatLng(t.lat, t.lng),
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () => _show(t),
                            child: Icon(Icons.park, color: t.status.color, size: 32),
                          ),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap')]),
                ],
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Tasdiqlangan daraxtlar: ${trees.length}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
