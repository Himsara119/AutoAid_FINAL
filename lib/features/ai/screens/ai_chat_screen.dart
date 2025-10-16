// lib/features/ai_diagnosis/ui/ai_diagnosis_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AiDiagnosisChatScreen extends StatefulWidget {
  const AiDiagnosisChatScreen({super.key});

  @override
  State<AiDiagnosisChatScreen> createState() => _AiDiagnosisChatScreenState();
}

class _AiDiagnosisChatScreenState extends State<AiDiagnosisChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg.system(
      time: '10:33 AM',
      text: '• On a scale of 1–10, how severe is the pain?\n'
          '• Any nausea or sensitivity to light?\n'
          '• How’s your sleep quality lately?',
    ),
    _ChatMsg.user(
      time: '10:35 AM',
      text:
      'Pain is around 6/10. No nausea but I do feel sensitive to bright lights. Sleep has been poor - only 4–5 hours per night',
    ),
    _ChatMsg.bot(
      time: '10:37 AM',
      text:
      'Based on your symptoms, this could be related to:',
      causes: const [
        'Sleep deprivation headaches',
        'Tension headaches from stress',
        'Dehydration',
      ],
      recommendation:
      'I recommend improving your sleep schedule and staying hydrated. '
          'However, please consult a healthcare provider if symptoms persist.',
    ),
    _ChatMsg.typing(),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemBuilder: (context, i) => _ChatBubble(msg: _messages[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: _messages.length,
              ),
            ),
            _InputBar(
              controller: _controller,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      // remove typing, add user, add typing again
      _messages.removeWhere((m) => m.type == _MsgType.typing);
      _messages.add(_ChatMsg.user(time: _now(), text: txt));
      _messages.add(_ChatMsg.typing());
    });
    _controller.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 50), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });

    // Fake bot response (replace with your backend)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.removeWhere((m) => m.type == _MsgType.typing);
        _messages.add(
          _ChatMsg.bot(
            time: _now(),
            text: 'Thanks for the update. Logging your symptoms.',
            causes: const [],
            recommendation: 'If pain worsens or new symptoms appear, seek medical care.',
          ),
        );
      });
    });
  }

  String _now() {
    final dt = TimeOfDay.now();
    final h = dt.hourOfPeriod == 0 ? 12 : dt.hourOfPeriod;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

/* ---------------------------- DATA MODEL ---------------------------- */

enum _MsgType { user, bot, system, typing }

class _ChatMsg {
  final _MsgType type;
  final String time;
  final String text;
  final List<String> causes; // only for bot card
  final String? recommendation;

  _ChatMsg._({
    required this.type,
    required this.time,
    required this.text,
    this.causes = const [],
    this.recommendation,
  });

  factory _ChatMsg.user({required String time, required String text}) =>
      _ChatMsg._(type: _MsgType.user, time: time, text: text);

  factory _ChatMsg.bot({
    required String time,
    required String text,
    List<String> causes = const [],
    String? recommendation,
  }) =>
      _ChatMsg._(
        type: _MsgType.bot,
        time: time,
        text: text,
        causes: causes,
        recommendation: recommendation,
      );

  factory _ChatMsg.system({required String time, required String text}) =>
      _ChatMsg._(type: _MsgType.system, time: time, text: text);

  factory _ChatMsg.typing() => _ChatMsg._(type: _MsgType.typing, time: '', text: '');
}

/* --------------------------- UI WIDGETS ---------------------------- */

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.msg});
  final _ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.type == _MsgType.user;
    final isBot = msg.type == _MsgType.bot;
    final isSystem = msg.type == _MsgType.system;
    final isTyping = msg.type == _MsgType.typing;

    if (isTyping) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          _BotAvatar(),
          SizedBox(width: 8),
          _TypingBubble(),
        ],
      );
    }

    final bg = isUser
        ? Colors.white
        : isSystem
        ? Colors.white
        : const Color(0xFF7C3AED);
    final fg = isUser || isSystem ? const Color(0xFF111827) : Colors.white;

    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

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
                child: Column(
                  crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(msg.text,
                        style: TextStyle(color: fg, height: 1.35, fontSize: 14)),
                    if (isBot && msg.causes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _CausesCard(items: msg.causes),
                      if (msg.recommendation != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          msg.recommendation!,
                          style: const TextStyle(color: Colors.white, height: 1.4),
                        ),
                      ]
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (msg.time.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 44, // align under bubble near avatar
              right: isUser ? 4 : 0,
            ),
            child: Text(
              msg.time,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5),
            ),
          ),
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

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _Dot(),
          SizedBox(width: 4),
          _Dot(delay: 150),
          SizedBox(width: 4),
          _Dot(delay: 300),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({this.delay = 0});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();
  late final Animation<double> _a =
  Tween(begin: 0.3, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)).animate(_c);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () => _c.forward(from: 0));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}

class _CausesCard extends StatelessWidget {
  const _CausesCard({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6), // slightly lighter purple
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Iconsax.search_normal, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text('Possible', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Text('Causes:',
              style: t.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...items.map(
                (e) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white)),
                Expanded(child: Text(e, style: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ],
      ),
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
                        hintText: 'Type your symptoms or questions…',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 3,
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
