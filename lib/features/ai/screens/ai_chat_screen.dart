// lib/features/ai_diagnosis/ui/ai_diagnosis_chat_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/chat_controller.dart';

class AiDiagnosisChatScreen extends StatelessWidget {
  const AiDiagnosisChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChatController>(); // put this in your binding before routing
    final inputCtrl = TextEditingController();
    final scroll = ScrollController();
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Diagnosis',
                style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(
              children: const [
                _StatusDot(color: Color(0xFF22C55E)),
                SizedBox(width: 6),
                Text('Online', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final msgs = c.msgs;
                return ListView.separated(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: msgs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ChatBubble(msg: msgs[i]),
                );
              }),
            ),
            _InputBar(
              controller: inputCtrl,
              onSend: () async {
                final txt = inputCtrl.text.trim();
                if (txt.isEmpty) return;
                inputCtrl.clear();
                await c.sendUserText(txt);
                await Future.delayed(const Duration(milliseconds: 50));
                if (scroll.hasClients) {
                  scroll.animateTo(
                    scroll.position.maxScrollExtent + 160,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------- BUBBLES --------------------------- */

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.msg});
  final ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    final isBot = msg.role == 'assistant';
    final isSystem = msg.role == 'system';

    final bg = isUser
        ? Colors.white
        : isSystem
        ? Colors.white
        : const Color(0xFF7C3AED);
    final fg = isUser || isSystem ? const Color(0xFF111827) : Colors.white;

    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final content = Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (msg.imagePath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(msg.imagePath!),
              width: 240,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),
          if ((msg.text ?? '').isNotEmpty) const SizedBox(height: 8),
        ],
        if ((msg.text ?? '').isNotEmpty)
          Text(
            msg.text!,
            style: TextStyle(color: fg, height: 1.35, fontSize: 14),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) const _BotAvatar(),
            if (!isUser) const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 6),
                    bottomRight: Radius.circular(isUser ? 6 : 18),
                  ),
                  border: isUser || isSystem
                      ? Border.all(color: const Color(0xFFE6E8ED))
                      : null,
                ),
                child: content,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // You can add timestamps if you store them in ChatMessage later
      ],
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF7C3AED),
        shape: BoxShape.circle,
      ),
      child: const Icon(Iconsax.cpu, size: 16, color: Colors.white),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

/* ----------------------------- INPUT BAR ---------------------------- */

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
        top: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Iconsax.microphone, size: 20, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        hintText: 'Describe the issue or symptoms…',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF7C3AED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.send_2, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
