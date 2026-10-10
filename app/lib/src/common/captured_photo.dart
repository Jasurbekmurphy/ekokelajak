import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:geolocator/geolocator.dart';

/// Ilova kamerasida olingan surat va u olingan paytdagi joylashuv.
class CapturedPhoto {
  CapturedPhoto({required this.bytes, required this.capturedAt, required this.position})
    : hash = sha256.convert(bytes).toString();

  final Uint8List bytes;
  final DateTime capturedAt;
  final Position position;
  final String hash;

  /// Suratni yuklaydi va bazaga yuboriladigan dalil yozuvini qaytaradi.
  Future<Map<String, dynamic>> upload(EcoApi api, EvidenceType type) async {
    final suffix = Random.secure().nextInt(1 << 32).toRadixString(16);
    final key = await api.uploadPhoto(bytes, '${capturedAt.millisecondsSinceEpoch}_${type.dbValue}_$suffix.jpg');
    return {
      'type': type.dbValue,
      'storage_key': key,
      'captured_at': capturedAt.toUtc().toIso8601String(),
      'file_hash': hash,
      'lat': position.latitude,
      'lng': position.longitude,
      'accuracy_m': position.accuracy,
      'is_mocked': position.isMocked,
    };
  }
}
