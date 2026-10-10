import 'package:flutter/material.dart';

/// Daraxt qaydining holati. Bazadagi `tree_status` bilan bir xil.
enum TreeStatus {
  submitted('Tekshiruv kutilmoqda', Colors.blueGrey),
  underReview('Qo\'shimcha tekshiruvda', Colors.indigo),
  needsMoreEvidence('Qo\'shimcha dalil kerak', Colors.orange),
  verifiedPlanted('Ekish tasdiqlandi', Colors.green),
  monitoringDue('Kuzatuv kutilmoqda', Colors.amber),
  aliveConfirmed('Tirikligi tasdiqlandi', Color(0xFF1B5E20)),
  deadOrMissing('Qurigan yoki topilmadi', Colors.brown),
  rejected('Rad etildi', Colors.red);

  const TreeStatus(this.label, this.color);
  final String label;
  final Color color;

  static TreeStatus parse(String value) => values.byName(_camel(value));
}

enum MonitoringStatus {
  scheduled('Rejalashtirilgan'),
  submitted('Tekshiruv kutilmoqda'),
  alive('Tirik'),
  dead('Qurigan'),
  notFound('Topilmadi'),
  insufficient('Dalil yetarli emas'),
  overdue('Muddati o\'tgan');

  const MonitoringStatus(this.label);
  final String label;

  String get dbValue => _snake(name);
  static MonitoringStatus parse(String value) => values.byName(_camel(value));
}

enum SiteType {
  publicSpace('Jamoat joyi'),
  school('Ta\'lim muassasasi'),
  eventArea('Tadbir hududi'),
  mahalla('Mahalla'),
  other('Boshqa');

  const SiteType(this.label);
  final String label;

  String get dbValue => _snake(name);
  static SiteType parse(String value) => values.byName(_camel(value));
}

enum EvidenceType {
  plantingPhoto('Ekish jarayoni'),
  afterPhoto('Yakuniy holat'),
  monitoringPhoto('Kuzatuv surati');

  const EvidenceType(this.label);
  final String label;

  String get dbValue => _snake(name);
  static EvidenceType parse(String value) => values.byName(_camel(value));
}

/// Avtomatik tekshiruv belgilari — moderator uchun signal, hukm emas.
const flagLabels = {
  'duplicate_file': 'Bu fayl avval yuborilgan',
  'old_capture': 'Surat 24 soatdan oldin olingan',
  'low_gps_accuracy': 'GPS aniqligi past (>30 m)',
  'permission_not_confirmed': 'Joy ruxsati tasdiqlanmagan',
  'nearby_tree': '3 m ichida boshqa qayd bor',
  'high_volume': 'Qisqa vaqtda juda ko\'p qayd',
  'far_from_tree': 'Daraxtdan 50 m dan uzoqda olingan',
  'mock_location': 'Telefonda soxta joylashuv yoqilgan',
};

String flagLabel(String flag) => flagLabels[flag] ?? flag;

/// Moderator sabablari (bazadagi `reason_codes` bilan bir xil).
const reasonLabels = {
  'photo_unclear': 'Suratda daraxt yoki ekish jarayoni aniq ko\'rinmaydi',
  'not_planting': 'Surat ekish jarayonini ko\'rsatmaydi',
  'duplicate': 'Bu surat yoki daraxt avval yuborilgan',
  'location_mismatch': 'Joylashuv dalillarga mos kelmaydi',
  'low_gps_accuracy': 'GPS aniqligi juda past',
  'no_permission': 'Bu joyda ekishga ruxsat borligi ko\'rinmaydi',
  'suspected_fake': 'Surat tahrirlangan yoki sun\'iy bo\'lishi mumkin',
  'other': 'Boshqa sabab (izohda)',
};

String reasonLabel(String code) => reasonLabels[code] ?? code;

class Species {
  Species({required this.id, required this.name});
  final int id;
  final String name;

  factory Species.fromJson(Map<String, dynamic> j) => Species(id: j['id'] as int, name: j['name_uz'] as String);
}

class ReasonCode {
  ReasonCode({required this.code, required this.label});
  final String code;
  final String label;

  factory ReasonCode.fromJson(Map<String, dynamic> j) =>
      ReasonCode(code: j['code'] as String, label: j['label_uz'] as String);
}

class Evidence {
  Evidence({
    required this.id,
    required this.type,
    required this.storageKey,
    required this.capturedAt,
    required this.serverReceivedAt,
    required this.fileHash,
    this.lat,
    this.lng,
    this.accuracyM,
  });

  final String id;
  final EvidenceType type;
  final String storageKey;
  final DateTime capturedAt;
  final DateTime serverReceivedAt;
  final String fileHash;
  final double? lat;
  final double? lng;
  final double? accuracyM;

  factory Evidence.fromJson(Map<String, dynamic> j) => Evidence(
    id: j['id'] as String,
    type: EvidenceType.parse(j['type'] as String),
    storageKey: j['storage_key'] as String,
    capturedAt: DateTime.parse(j['captured_at'] as String),
    serverReceivedAt: DateTime.parse(j['server_received_at'] as String),
    fileHash: j['file_hash'] as String,
    lat: (j['lat'] as num?)?.toDouble(),
    lng: (j['lng'] as num?)?.toDouble(),
    accuracyM: (j['accuracy_m'] as num?)?.toDouble(),
  );
}

class MonitoringCheck {
  MonitoringCheck({
    required this.id,
    required this.treeId,
    required this.kind,
    required this.scheduledFor,
    required this.status,
    this.submittedAt,
    this.evidenceId,
    this.flags = const [],
  });

  final String id;
  final String treeId;
  final String kind; // d30 | d90
  final DateTime scheduledFor;
  final MonitoringStatus status;
  final DateTime? submittedAt;
  final String? evidenceId;
  final List<String> flags;

  String get kindLabel => kind == 'd30' ? '30 kunlik kuzatuv' : '90 kunlik kuzatuv';

  /// Foydalanuvchi hozir surat yubora oladimi (bazadagi qoida bilan bir xil).
  bool get canSubmit =>
      const [MonitoringStatus.scheduled, MonitoringStatus.overdue, MonitoringStatus.insufficient].contains(status) &&
      scheduledFor.isBefore(DateTime.now().add(const Duration(days: 3)));

  factory MonitoringCheck.fromJson(Map<String, dynamic> j) => MonitoringCheck(
    id: j['id'] as String,
    treeId: j['tree_id'] as String,
    kind: j['kind'] as String,
    scheduledFor: DateTime.parse(j['scheduled_for'] as String),
    status: MonitoringStatus.parse(j['status'] as String),
    submittedAt: j['submitted_at'] == null ? null : DateTime.parse(j['submitted_at'] as String),
    evidenceId: j['evidence_id'] as String?,
    flags: (j['flags'] as List?)?.cast<String>() ?? const [],
  );
}

class ReviewEntry {
  ReviewEntry({
    required this.decision,
    required this.createdAt,
    this.reasonCode,
    this.comment,
    this.toStatus,
    this.isSystem = false,
  });

  final String decision;
  final DateTime createdAt;
  final String? reasonCode;
  final String? comment;
  final TreeStatus? toStatus;
  final bool isSystem;

  static const decisionLabels = {
    'submitted': 'Yuborildi',
    'system_flag': 'Avtomatik belgi',
    'approve': 'Tasdiqlandi',
    'request_evidence': 'Qo\'shimcha dalil so\'raldi',
    'reject': 'Rad etildi',
    'escalate': 'Qo\'shimcha tekshiruvga yuborildi',
    'evidence_added': 'Dalil qo\'shildi',
    'monitoring_submitted': 'Kuzatuv surati yuborildi',
    'monitoring_reviewed': 'Kuzatuv tekshirildi',
    'appeal_opened': 'Murojaat yuborildi',
    'appeal_accepted': 'Murojaat qabul qilindi',
    'appeal_declined': 'Murojaat rad etildi',
  };

  String get decisionLabel => decisionLabels[decision] ?? decision;

  factory ReviewEntry.fromJson(Map<String, dynamic> j) => ReviewEntry(
    decision: j['decision'] as String,
    createdAt: DateTime.parse(j['created_at'] as String),
    reasonCode: j['reason_code'] as String?,
    comment: j['comment'] as String?,
    toStatus: j['to_status'] == null ? null : TreeStatus.parse(j['to_status'] as String),
    isSystem: j['reviewer_id'] == null,
  );
}

class Appeal {
  Appeal({
    required this.id,
    required this.treeId,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String treeId;
  final String message;
  final String status; // open | accepted | declined
  final DateTime createdAt;

  factory Appeal.fromJson(Map<String, dynamic> j) => Appeal(
    id: j['id'] as String,
    treeId: j['tree_id'] as String,
    message: j['message'] as String,
    status: j['status'] as String,
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}

class TreeRecord {
  TreeRecord({
    required this.id,
    required this.createdBy,
    required this.plantedAt,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    required this.siteType,
    required this.permissionConfirmed,
    required this.status,
    required this.flags,
    required this.createdAt,
    this.speciesName,
    this.note,
    this.authorName,
    this.evidence = const [],
    this.checks = const [],
    this.reviews = const [],
    this.appeals = const [],
  });

  final String id;
  final String createdBy;
  final DateTime plantedAt;
  final double lat;
  final double lng;
  final double accuracyM;
  final SiteType siteType;
  final bool permissionConfirmed;
  final TreeStatus status;
  final List<String> flags;
  final DateTime createdAt;
  final String? speciesName;
  final String? note;
  final String? authorName;
  final List<Evidence> evidence;
  final List<MonitoringCheck> checks;
  final List<ReviewEntry> reviews;
  final List<Appeal> appeals;

  /// Foydalanuvchiga ko'rsatiladigan oxirgi moderator sababi/izohi.
  ReviewEntry? get lastDecision {
    final decisions =
        reviews
            .where((r) => const ['reject', 'request_evidence', 'approve', 'appeal_declined'].contains(r.decision))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return decisions.isEmpty ? null : decisions.first;
  }

  bool get hasOpenAppeal => appeals.any((a) => a.status == 'open');

  /// PostgREST select ifodasi: daraxt va unga bog'liq yozuvlar.
  static const selectWithRelations =
      '*, species(name_uz), profiles(display_name), evidence(*), monitoring_checks(*), reviews(*), appeals(*)';

  factory TreeRecord.fromJson(Map<String, dynamic> j) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        ((j[key] as List?) ?? const []).map((e) => f(e as Map<String, dynamic>)).toList();

    return TreeRecord(
      id: j['id'] as String,
      createdBy: j['created_by'] as String,
      plantedAt: DateTime.parse(j['planted_at'] as String),
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
      accuracyM: (j['accuracy_m'] as num).toDouble(),
      siteType: SiteType.parse(j['site_type'] as String),
      permissionConfirmed: j['permission_confirmed'] as bool,
      status: TreeStatus.parse(j['status'] as String),
      flags: (j['flags'] as List).cast<String>(),
      createdAt: DateTime.parse(j['created_at'] as String),
      speciesName: (j['species'] as Map?)?['name_uz'] as String?,
      note: j['note'] as String?,
      authorName: (j['profiles'] as Map?)?['display_name'] as String?,
      evidence: list('evidence', Evidence.fromJson),
      checks: list('monitoring_checks', MonitoringCheck.fromJson)
        ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor)),
      reviews: list('reviews', ReviewEntry.fromJson)..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      appeals: list('appeals', Appeal.fromJson),
    );
  }
}

class PublicTree {
  PublicTree({
    required this.id,
    required this.lat,
    required this.lng,
    required this.status,
    this.species,
    this.plantedOn,
  });

  final String id;
  final double lat;
  final double lng;
  final TreeStatus status;
  final String? species;
  final DateTime? plantedOn;

  factory PublicTree.fromJson(Map<String, dynamic> j) => PublicTree(
    id: j['id'] as String,
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    status: TreeStatus.parse(j['status'] as String),
    species: j['species'] as String?,
    plantedOn: j['planted_on'] == null ? null : DateTime.parse(j['planted_on'] as String),
  );
}

class RankingRow {
  RankingRow({
    required this.userId,
    required this.displayName,
    required this.points,
    required this.verifiedTrees,
    required this.position,
  });

  final String userId;
  final String displayName;
  final int points;
  final int verifiedTrees;
  final int position;

  factory RankingRow.fromJson(Map<String, dynamic> j) => RankingRow(
    userId: j['user_id'] as String,
    displayName: j['display_name'] as String,
    points: j['points'] as int,
    verifiedTrees: j['verified_trees'] as int,
    position: (j['position'] as num).toInt(),
  );
}

class StatsSummary {
  StatsSummary({
    required this.submitted,
    required this.verified,
    required this.rejected,
    this.approvalRatePct,
    required this.d90Decided,
    required this.d90Alive,
    required this.d90Overdue,
    this.d90SurvivalPct,
    this.duplicateRatePct,
  });

  final int submitted;
  final int verified;
  final int rejected;
  final double? approvalRatePct;
  final int d90Decided;
  final int d90Alive;
  final int d90Overdue;
  final double? d90SurvivalPct;
  final double? duplicateRatePct;

  factory StatsSummary.fromJson(Map<String, dynamic> j) => StatsSummary(
    submitted: j['submitted'] as int,
    verified: j['verified'] as int,
    rejected: j['rejected'] as int,
    approvalRatePct: (j['approval_rate_pct'] as num?)?.toDouble(),
    d90Decided: j['d90_decided'] as int,
    d90Alive: j['d90_alive'] as int,
    d90Overdue: j['d90_overdue'] as int,
    d90SurvivalPct: (j['d90_survival_pct'] as num?)?.toDouble(),
    duplicateRatePct: (j['duplicate_rate_pct'] as num?)?.toDouble(),
  );
}

class Profile {
  Profile({required this.id, required this.displayName, required this.role});

  final String id;
  final String displayName;
  final String role; // user | reviewer | admin

  bool get isReviewer => role == 'reviewer' || role == 'admin';

  factory Profile.fromJson(Map<String, dynamic> j) =>
      Profile(id: j['id'] as String, displayName: j['display_name'] as String, role: j['role'] as String);
}

String _camel(String snake) {
  final parts = snake.split('_');
  return parts.first + parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

String _snake(String camel) => camel.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
