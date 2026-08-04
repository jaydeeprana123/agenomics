import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/consent_request_model.dart';
import '../../../data/repositories/consent_repository.dart';

class ConsentFormController extends GetxController {
  ConsentFormController({ConsentRepository? repository})
      : _repository = repository ?? Get.find<ConsentRepository>();

  final ConsentRepository _repository;

  late final SignatureController patientSignature;
  late final SignatureController clinicianSignature;

  final request = Rxn<ConsentRequestModel>();
  final purposes = const ConsentPurposes().obs;
  final clinicianName = ''.obs;
  final isSubmitting = false.obs;
  final isLoading = true.obs;

  final patientPadKey = GlobalKey();
  final clinicianPadKey = GlobalKey();

  StreamSubscription<ConsentRequestModel?>? _sub;

  @override
  void onInit() {
    super.onInit();
    patientSignature = SignatureController(
      penStrokeWidth: 2.4,
      penColor: AppColors.brand300,
      exportBackgroundColor: Colors.transparent,
    );
    clinicianSignature = SignatureController(
      penStrokeWidth: 2.4,
      penColor: AppColors.darkInk,
      exportBackgroundColor: Colors.transparent,
    );

    final args = Get.arguments;
    if (args is ConsentRequestModel) {
      _bindRequest(args);
      _listen(args.id);
    } else if (args is String) {
      _load(args);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> _load(String id) async {
    isLoading.value = true;
    try {
      final doc = await _repository.getRequest(id);
      if (doc != null) {
        _bindRequest(doc);
        _listen(id);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _bindRequest(ConsentRequestModel doc) {
    request.value = doc;
    purposes.value = doc.purposes;
    clinicianName.value = doc.clinicianName ?? '';
    isLoading.value = false;
  }

  void _listen(String id) {
    _sub?.cancel();
    _sub = _repository.watchRequest(id).listen((doc) {
      if (doc == null) return;
      request.value = doc;
    });
  }

  bool getValue(String key) {
    final p = purposes.value;
    switch (key) {
      case 'identityVerification':
        return p.identityVerification;
      case 'hieRecordRetrieval':
        return p.hieRecordRetrieval;
      case 'pharmacogenomicProcessing':
        return p.pharmacogenomicProcessing;
      case 'germlineInterpretation':
        return p.germlineInterpretation;
      case 'claimEvidenceAttachment':
        return p.claimEvidenceAttachment;
      case 'secondaryResearchUse':
        return p.secondaryResearchUse;
      case 'familyCascadeDisclosure':
        return p.familyCascadeDisclosure;
      default:
        return false;
    }
  }

  void setValue(String key, bool value) {
    final p = purposes.value;
    purposes.value = switch (key) {
      'identityVerification' => p.copyWith(identityVerification: value),
      'hieRecordRetrieval' => p.copyWith(hieRecordRetrieval: value),
      'pharmacogenomicProcessing' =>
        p.copyWith(pharmacogenomicProcessing: value),
      'germlineInterpretation' => p.copyWith(germlineInterpretation: value),
      'claimEvidenceAttachment' => p.copyWith(claimEvidenceAttachment: value),
      'secondaryResearchUse' => p.copyWith(secondaryResearchUse: value),
      'familyCascadeDisclosure' => p.copyWith(familyCascadeDisclosure: value),
      _ => p,
    };
  }

  void onClinicianBadgeTap() {
    if (clinicianName.value.trim().isEmpty) {
      clinicianName.value = 'Dr. — ordering oncologist';
    }
  }

  Future<void> submit() async {
    final current = request.value;
    if (current == null || !current.isPending) return;

    if (!purposes.value.identityVerification) {
      Get.snackbar(
        'Required',
        'Identity verification is always required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return;
    }

    if (patientSignature.isEmpty) {
      Get.snackbar(
        'Signature required',
        'Please capture the patient signature before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningBg,
        colorText: AppColors.warning,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      // Identity verification is always required.
      final finalPurposes =
          purposes.value.copyWith(identityVerification: true);

      String? patientUrl;
      String? clinicianUrl;

      final patientBytes = await patientSignature.toPngBytes();
      if (patientBytes != null) {
        patientUrl = await _repository.uploadSignature(
          requestId: current.id,
          role: 'patient',
          bytes: patientBytes,
        );
      }

      if (clinicianSignature.isNotEmpty) {
        final clinicianBytes = await clinicianSignature.toPngBytes();
        if (clinicianBytes != null) {
          clinicianUrl = await _repository.uploadSignature(
            requestId: current.id,
            role: 'clinician',
            bytes: clinicianBytes,
          );
        }
      }

      await _repository.submitConsent(
        requestId: current.id,
        purposes: finalPurposes,
        patientSignatureUrl: patientUrl,
        clinicianSignatureUrl: clinicianUrl,
        clinicianName: clinicianName.value.trim().isEmpty
            ? null
            : clinicianName.value.trim(),
      );

      Get.snackbar(
        'Consent approved',
        'Status updated to approved in real time.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
      Get.back(result: ConsentStatus.approved);
    } catch (e) {
      Get.snackbar(
        'Submit failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> decline() async {
    final current = request.value;
    if (current == null || !current.isPending) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.panel,
        title: const Text(
          'Decline all purposes?',
          style: TextStyle(color: AppColors.darkInk, fontFamily: 'Mulish'),
        ),
        content: const Text(
          'This will mark the consent request as declined. Treatment is unaffected.',
          style: TextStyle(color: AppColors.darkText2, fontFamily: 'Mulish'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isSubmitting.value = true;
    try {
      await _repository.declineConsent(current.id);
      Get.snackbar(
        'Consent declined',
        'Status updated to declined in real time.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningBg,
        colorText: AppColors.warning,
      );
      Get.back(result: ConsentStatus.declined);
    } catch (e) {
      Get.snackbar(
        'Decline failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<Uint8List?> capturePad(GlobalKey key) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  void onClose() {
    _sub?.cancel();
    patientSignature.dispose();
    clinicianSignature.dispose();
    super.onClose();
  }
}
