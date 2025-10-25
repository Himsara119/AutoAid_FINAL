// lib/features/visual_scan/controllers/visual_scan_controller.dart
// Controller that owns image picking, calls the ImageAnalysisService,
// and hands off to Chat via ChatBridge.

import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// routes
import '../../../app.dart' show Routes;

// core AI + chat bridge
import '../chat_bridge.dart';
import '../image_analysis_service.dart';

class VisualScanController extends GetxController {
  VisualScanController(this.service);

  final ImageAnalysisService service;
  final ImagePicker _picker = ImagePicker();

  // observable states
  final loading = false.obs;
  final error = RxnString();
  final pickedImage = Rxn<File>();

  // guards to prevent double actions
  bool _picking = false;
  bool _analyzing = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _ensureInit();
  }

  Future<void> _ensureInit() async {
    if (service.isReady) return;
    loading.value = true;
    try {
      await service.init(); // service handles rootBundle internally
      dev.log('VisualScanController initialized.', name: 'VisualScan');
    } catch (e, st) {
      error.value = 'Init failed: $e';
      dev.log('Init failed', name: 'VisualScan', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  // --- Image picking ---

  Future<void> pickFromGallery() => _pick(ImageSource.gallery);
  Future<void> pickFromCamera() => _pick(ImageSource.camera);

  Future<void> _pick(ImageSource src) async {
    if (_picking) return; // prevent already_active spam
    _picking = true;
    try {
      final x = await _picker.pickImage(
        source: src,
        maxWidth: 1024,
        imageQuality: 95,
      );
      if (x == null) return;
      pickedImage.value = File(x.path);
      error.value = null;
      dev.log('Picked image: ${x.path}', name: 'VisualScan');
    } catch (e, st) {
      error.value = 'Image pick failed: $e';
      dev.log('Image pick failed', name: 'VisualScan', error: e, stackTrace: st);
    } finally {
      _picking = false;
    }
  }

  // --- Image analysis + chat handoff ---

  Future<void> analyzeAndSendToChat() async {
    if (_analyzing) return; // guard multiple taps
    final file = pickedImage.value;
    if (file == null) {
      error.value = 'No image selected';
      return;
    }

    if (!service.isReady) {
      await _ensureInit();
      if (!service.isReady) {
        error.value = 'AI model not ready';
        return;
      }
    }

    _analyzing = true;
    loading.value = true;
    try {
      final res = await service.analyze(file);
      final bridge = Get.find<ChatBridge>();
      bridge.push(ChatAttachment(imageFile: file, analysis: res));

      if (Get.currentRoute != Routes.chat) {
        Get.toNamed(Routes.chat);
      }

      dev.log('Analysis success: ${res.label} '
          '(${(res.confidence * 100).toStringAsFixed(2)}%)',
          name: 'VisualScan');
    } catch (e, st) {
      error.value = 'Analysis failed: $e';
      dev.log('Analysis failed', name: 'VisualScan', error: e, stackTrace: st);
    } finally {
      loading.value = false;
      _analyzing = false;
    }
  }
}
