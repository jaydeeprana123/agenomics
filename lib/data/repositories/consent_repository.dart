import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/consent_request_model.dart';
import '../models/patient_model.dart';

/// Real-time consent requests backed by Firestore only (no Storage / images).
class ConsentRepository {
  ConsentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String collection = 'consent_requests';
  static const String devicesCollection = 'consent_devices';

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(collection);

  /// Create a pending consent request from desktop patient selection.
  Future<ConsentRequestModel> createConsentRequest(PatientModel patient) async {
    final patientRef = patient.uhid.isNotEmpty
        ? patient.uhid
        : 'ASTR-${DateTime.now().year}-${patient.id.hashCode.abs().toString().padLeft(6, '0')}';

    final draft = ConsentRequestModel(
      id: '',
      patientId: patient.id,
      patientUhid: patient.uhid,
      patientName: patient.name,
      emiratesId: patient.emiratesId,
      hospitalId: patient.hospitalId,
      patientRef: patientRef,
      status: ConsentStatus.pending,
      purposes: const ConsentPurposes(),
      source: 'desktop',
    );

    final doc = await _col.add(draft.toFirestore(isCreate: true));
    final snap = await doc.get();
    return ConsentRequestModel.fromFirestore(snap);
  }

  /// Live stream of all pending consent requests (mobile inbox).
  Stream<List<ConsentRequestModel>> watchPendingRequests() {
    return _col
        .where('status', isEqualTo: ConsentStatus.pending)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ConsentRequestModel.fromFirestore).toList();
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  /// Live stream of the latest consent request for a patient (desktop badge).
  Stream<ConsentRequestModel?> watchLatestForPatient(String patientId) {
    if (patientId.isEmpty) {
      return Stream.value(null);
    }
    return _col
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final list = snap.docs.map(ConsentRequestModel.fromFirestore).toList();
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return list.first;
    });
  }

  /// Live stream of a single consent document.
  Stream<ConsentRequestModel?> watchRequest(String requestId) {
    if (requestId.isEmpty) return Stream.value(null);
    return _col.doc(requestId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ConsentRequestModel.fromFirestore(snap);
    });
  }

  Future<ConsentRequestModel?> getRequest(String requestId) async {
    final snap = await _col.doc(requestId).get();
    if (!snap.exists) return null;
    return ConsentRequestModel.fromFirestore(snap);
  }

  /// Latest consent per patient for the current page of patients.
  Future<Map<String, ConsentRequestModel>> getLatestByPatientIds(
    List<String> patientIds,
  ) async {
    final result = <String, ConsentRequestModel>{};
    for (final id in patientIds) {
      if (id.isEmpty) continue;
      final snap = await _col.where('patientId', isEqualTo: id).get();
      if (snap.docs.isEmpty) continue;
      final list = snap.docs.map(ConsentRequestModel.fromFirestore).toList();
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      result[id] = list.first;
    }
    return result;
  }

  /// Approve consent — Firestore data only (no images).
  Future<void> submitConsent({
    required String requestId,
    required ConsentPurposes purposes,
    String? clinicianName,
    bool patientSigned = false,
    bool clinicianSigned = false,
  }) async {
    await _col.doc(requestId).update({
      'status': ConsentStatus.approved,
      'purposes': purposes.toJson(),
      'clinicianName': clinicianName,
      'patientSigned': patientSigned,
      'clinicianSigned': clinicianSigned,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> declineConsent(String requestId) async {
    await _col.doc(requestId).update({
      'status': ConsentStatus.declined,
      'purposes': const ConsentPurposes().declinedAll.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Register FCM token for consent-device push targeting.
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await _db.collection(devicesCollection).doc(token).set({
      'token': token,
      'platform': platform,
      'role': 'consent_tablet',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
