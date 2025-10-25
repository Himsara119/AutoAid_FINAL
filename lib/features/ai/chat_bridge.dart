// Zero-friction, in-memory handoff from Visual Scan to Chat.

import 'dart:io';
import '../ai/image_analysis_service.dart'; // for AnalysisResult

class ChatAttachment {
  final File imageFile;
  final AnalysisResult analysis;
  const ChatAttachment({required this.imageFile, required this.analysis});
}

/// One-slot conveyor belt. Visual Scan pushes; Chat pops.
class ChatBridge {
  ChatAttachment? _pending;

  void push(ChatAttachment a) => _pending = a;

  ChatAttachment? take() {
    final p = _pending;
    _pending = null;
    return p;
  }
}
