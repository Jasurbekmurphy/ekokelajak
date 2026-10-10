import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bazadagi holat nomlari enum bilan mos', () {
    const dbStatuses = [
      'submitted',
      'under_review',
      'needs_more_evidence',
      'verified_planted',
      'monitoring_due',
      'alive_confirmed',
      'dead_or_missing',
      'rejected',
    ];
    expect(dbStatuses.map(TreeStatus.parse).toSet().length, TreeStatus.values.length);
  });

  test('snake_case ↔ enum', () {
    expect(SiteType.publicSpace.dbValue, 'public_space');
    expect(SiteType.parse('event_area'), SiteType.eventArea);
    expect(MonitoringStatus.notFound.dbValue, 'not_found');
    expect(EvidenceType.parse('monitoring_photo'), EvidenceType.monitoringPhoto);
  });

  test('daraxt qaydi JSON dan o\'qiladi', () {
    final t = TreeRecord.fromJson({
      'id': 't1',
      'created_by': 'u1',
      'planted_at': '2026-10-10T10:00:00Z',
      'lat': 41.3,
      'lng': 69.2,
      'accuracy_m': 8,
      'site_type': 'school',
      'permission_confirmed': true,
      'status': 'needs_more_evidence',
      'flags': ['low_gps_accuracy'],
      'created_at': '2026-10-10T10:00:00Z',
      'species': {'name_uz': 'Chinor'},
      'profiles': {'display_name': 'Ali'},
      'evidence': [],
      'monitoring_checks': [],
      'reviews': [
        {'decision': 'submitted', 'created_at': '2026-10-10T10:00:00Z', 'reviewer_id': null},
        {
          'decision': 'request_evidence',
          'created_at': '2026-10-10T11:00:00Z',
          'reviewer_id': 'm1',
          'reason_code': 'photo_unclear',
          'to_status': 'needs_more_evidence',
        },
      ],
      'appeals': [],
    });
    expect(t.status, TreeStatus.needsMoreEvidence);
    expect(t.speciesName, 'Chinor');
    expect(t.lastDecision?.reasonCode, 'photo_unclear');
    expect(reasonLabel('photo_unclear'), contains('aniq'));
  });
}
