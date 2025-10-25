// Consumes the ChatBridge attachment, seeds messages, and calls LlamaClient.

import 'dart:developer' as dev;
import 'package:get/get.dart';
import '../chat_bridge.dart';
import '../image_analysis_service.dart';
import '../llama_client.dart';

class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant' | 'system'
  final String? text;
  final String? imagePath;

  ChatMessage({
    required this.id,
    required this.role,
    this.text,
    this.imagePath,
  });
}

class ChatController extends GetxController {
  final LlamaClient llama;

  ChatController(this.llama);

  final msgs = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    _consumeBridgeIfAny();
  }

  Future<void> _consumeBridgeIfAny() async {
    final bridge = Get.find<ChatBridge>();
    final attach = bridge.take();
    if (attach == null) return;

    _addImageMessage(attach);
    await _askLlamaWithSummary(attach.analysis);
  }

  void _addImageMessage(ChatAttachment a) {
    msgs.add(ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: 'user',
      imagePath: a.imageFile.path,
      text: 'Photo for inspection',
    ));

    // Optional: echo summary for transparency.
    msgs.add(ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_summary',
      role: 'user',
      text: _summary(a.analysis),
    ));
  }

  Future<void> _askLlamaWithSummary(AnalysisResult r) async {
    try {
      final reply = await llama.diagnose(
        userPrompt: 'Diagnose car issue from image and summary.',
        analysisSummary: _topline(r),
      );
      msgs.add(ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}_ai',
        role: 'assistant',
        text: reply,
      ));
    } catch (e, st) {
      dev.log('LLM call failed', name: 'Chat', error: e, stackTrace: st);
      msgs.add(ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}_err',
        role: 'assistant',
        text: 'AI service is unavailable right now. Try again later.',
      ));
    }
  }

  String _topline(AnalysisResult r) =>
      '${r.label} ${(r.confidence * 100).toStringAsFixed(1)}%';

  String _summary(AnalysisResult r) {
    final lead = _topline(r);
    final extras = (r.topK ?? const <String, double>{})
        .entries
        .where((e) => e.key != r.label)
        .take(3)
        .map((e) => '${e.key} ${(e.value * 100).toStringAsFixed(0)}%')
        .join(', ');
    return extras.isEmpty ? 'Scan summary: $lead' : 'Scan summary: $lead; also: $extras';
  }

  Future<void> sendUserText(String text) async {
    msgs.add(ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: 'user',
      text: text,
    ));
    final reply = await llama.diagnose(userPrompt: text);
    msgs.add(ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_ai',
      role: 'assistant',
      text: reply,
    ));
  }
}
