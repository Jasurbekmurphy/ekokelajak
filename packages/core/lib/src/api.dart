import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

/// Ilova va panel ishlatadigan barcha Supabase chaqiruvlari.
/// Holat va ball faqat bazadagi RPC funksiyalari orqali o'zgaradi.
class EcoApi {
  EcoApi([SupabaseClient? client]) : _db = client ?? Supabase.instance.client;

  final SupabaseClient _db;

  static const evidenceBucket = 'evidence';

  // --- Auth ------------------------------------------------------------------

  User? get currentUser => _db.auth.currentUser;
  Stream<AuthState> get authChanges => _db.auth.onAuthStateChange;

  Future<void> signIn(String email, String password) =>
      _db.auth.signInWithPassword(email: email.trim(), password: password);

  /// Ro'yxatdan o'tish. Supabase'da email tasdiqlash yoqilgan bo'lsa, sessiya null qaytadi.
  Future<bool> signUp(String email, String password, String displayName) async {
    final res = await _db.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': displayName.trim()},
    );
    return res.session != null;
  }

  Future<void> signOut() => _db.auth.signOut();

  Future<Profile> myProfile() async {
    final row = await _db.from('profiles').select().eq('id', currentUser!.id).single();
    return Profile.fromJson(row);
  }

  Future<void> updateDisplayName(String name) =>
      _db.from('profiles').update({'display_name': name.trim()}).eq('id', currentUser!.id);

  // --- Ma'lumotnomalar -------------------------------------------------------

  Future<List<Species>> species() async {
    final rows = await _db.from('species').select().order('id');
    return rows.map(Species.fromJson).toList();
  }

  Future<List<ReasonCode>> reasonCodes() async {
    final rows = await _db.from('reason_codes').select();
    return rows.map(ReasonCode.fromJson).toList();
  }

  // --- Fayllar ---------------------------------------------------------------

  /// Suratni foydalanuvchining o'z papkasiga yuklaydi va saqlash kalitini qaytaradi.
  Future<String> uploadPhoto(Uint8List bytes, String fileName) async {
    final key = '${currentUser!.id}/$fileName';
    await _db.storage
        .from(evidenceBucket)
        .uploadBinary(key, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    return key;
  }

  /// Yopiq faylni 1 soatlik vaqtinchalik havola orqali ochish.
  Future<String> signedUrl(String storageKey) => _db.storage.from(evidenceBucket).createSignedUrl(storageKey, 3600);

  // --- Foydalanuvchi amallari ------------------------------------------------

  Future<String> submitTree({
    required double lat,
    required double lng,
    required double accuracyM,
    required SiteType siteType,
    required bool permissionConfirmed,
    int? speciesId,
    String? note,
    required List<Map<String, dynamic>> evidence,
  }) async {
    final id = await _db.rpc(
      'submit_tree',
      params: {
        'p_lat': lat,
        'p_lng': lng,
        'p_accuracy_m': accuracyM,
        'p_site_type': siteType.dbValue,
        'p_permission_confirmed': permissionConfirmed,
        'p_species_id': speciesId,
        'p_note': note,
        'p_evidence': evidence,
      },
    );
    return id as String;
  }

  Future<void> addEvidence(String treeId, List<Map<String, dynamic>> evidence) =>
      _db.rpc('add_evidence', params: {'p_tree_id': treeId, 'p_evidence': evidence});

  Future<void> submitMonitoring({
    required String checkId,
    required Map<String, dynamic> evidence,
    required double lat,
    required double lng,
    required double accuracyM,
  }) => _db.rpc(
    'submit_monitoring',
    params: {
      'p_check_id': checkId,
      'p_evidence': [evidence],
      'p_lat': lat,
      'p_lng': lng,
      'p_accuracy_m': accuracyM,
    },
  );

  Future<void> openAppeal(String treeId, String message) =>
      _db.rpc('open_appeal', params: {'p_tree_id': treeId, 'p_message': message});

  Future<List<TreeRecord>> myTrees() async {
    final rows = await _db
        .from('trees')
        .select(TreeRecord.selectWithRelations)
        .eq('created_by', currentUser!.id)
        .order('created_at', ascending: false);
    return rows.map(TreeRecord.fromJson).toList();
  }

  Future<TreeRecord> tree(String id) async {
    final row = await _db.from('trees').select(TreeRecord.selectWithRelations).eq('id', id).single();
    return TreeRecord.fromJson(row);
  }

  Future<int> myPoints() async {
    final rows = await _db.from('points_ledger').select('points_delta').eq('user_id', currentUser!.id);
    return rows.fold<int>(0, (sum, r) => sum + (r['points_delta'] as int));
  }

  // --- Ommaviy ma'lumot ------------------------------------------------------

  Future<List<PublicTree>> publicTrees() async {
    final rows = await _db.from('public_trees').select();
    return rows.map(PublicTree.fromJson).toList();
  }

  Future<List<RankingRow>> ranking({int limit = 50}) async {
    final rows = await _db.from('ranking').select().order('position').limit(limit);
    return rows.map(RankingRow.fromJson).toList();
  }

  Future<StatsSummary> stats() async {
    final row = await _db.from('stats_summary').select().single();
    return StatsSummary.fromJson(row);
  }

  // --- Moderator amallari ----------------------------------------------------

  /// Qaror kutayotgan qaydlar, eng eskisi birinchi. Belgilanganlar ro'yxat boshida.
  Future<List<TreeRecord>> reviewQueue() async {
    final rows = await _db
        .from('trees')
        .select(TreeRecord.selectWithRelations)
        .inFilter('status', ['submitted', 'under_review'])
        .order('created_at');
    final list = rows.map(TreeRecord.fromJson).toList();
    list.sort((a, b) => (b.flags.isNotEmpty ? 1 : 0).compareTo(a.flags.isNotEmpty ? 1 : 0));
    return list;
  }

  /// Foydalanuvchi yuborgan, tekshiruv kutayotgan monitoring suratlari.
  Future<List<TreeRecord>> monitoringQueue() async {
    final rows = await _db
        .from('trees')
        .select(TreeRecord.selectWithRelations.replaceFirst('monitoring_checks(*)', 'monitoring_checks!inner(*)'))
        .eq('monitoring_checks.status', 'submitted');
    return rows.map(TreeRecord.fromJson).toList();
  }

  Future<List<TreeRecord>> openAppeals() async {
    final rows = await _db
        .from('trees')
        .select(TreeRecord.selectWithRelations.replaceFirst('appeals(*)', 'appeals!inner(*)'))
        .eq('appeals.status', 'open');
    return rows.map(TreeRecord.fromJson).toList();
  }

  Future<void> reviewTree(String treeId, String decision, {String? reasonCode, String? comment}) => _db.rpc(
    'review_tree',
    params: {'p_tree_id': treeId, 'p_decision': decision, 'p_reason_code': reasonCode, 'p_comment': comment},
  );

  Future<void> reviewMonitoring(String checkId, MonitoringStatus result, {String? comment}) =>
      _db.rpc('review_monitoring', params: {'p_check_id': checkId, 'p_result': result.dbValue, 'p_comment': comment});

  Future<void> resolveAppeal(String appealId, bool accept, {String? comment}) =>
      _db.rpc('resolve_appeal', params: {'p_appeal_id': appealId, 'p_accept': accept, 'p_comment': comment});
}
