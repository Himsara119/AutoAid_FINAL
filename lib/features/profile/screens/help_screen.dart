// lib/features/support/ui/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _feedback = TextEditingController();
  bool _anonymous = false;

  @override
  void dispose() {
    _feedback.dispose();
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
        title: const Text('Help & Support',
            style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ
              const _SectionTitle('Frequently Asked Questions'),
              const SizedBox(height: 8),
              const _FaqTile(
                question: 'How do I add a new vehicle to my inventory?',
                answer:
                'Go to Inventory → Add Vehicle. Enter VIN to auto-fill details or enter manually. Save to publish.',
              ),
              const SizedBox(height: 12),
              const _FaqTile(
                question: 'How can I manage customer inquiries?',
                answer:
                'Use the Inbox screen to view, reply, and tag inquiries. Enable notifications in Settings.',
              ),
              const SizedBox(height: 12),
              const _FaqTile(
                question: 'What payment methods are supported?',
                answer:
                'We support credit/debit cards and bank transfers in most regions. Check Billing → Payment Methods.',
              ),
              const SizedBox(height: 12),
              const _FaqTile(
                question: 'How do I update my dealership information?',
                answer:
                'Profile → Edit Profile. Update company details, address, and contact info, then Save.',
              ),
              const SizedBox(height: 12),
              const _FaqTile(
                question: 'Can I track my sales analytics?',
                answer:
                'Yes. Go to Reports → Sales Analytics for conversion rates, revenue, and top-performing vehicles.',
              ),

              const SizedBox(height: 18),
              const _SectionTitle('Contact Support'),
              const SizedBox(height: 8),

              // Email support (primary)
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Iconsax.message_edit, size: 18),
                  label: const Text('Email Support',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: _emailSupport,
                ),
              ),
              const SizedBox(height: 12),

              // Call hotline (secondary)
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Iconsax.call, size: 18, color: Color(0xFF111827)),
                  label: const Text('Call Hotline',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      )),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    side: const BorderSide(color: Color(0xFFE6E8ED)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _callHotline,
                ),
              ),
              const SizedBox(height: 12),

              // Support hours info card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Iconsax.clock, color: Color(0xFF2563EB)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Support Hours\n'
                            'Monday – Friday: 8:00 AM – 6:00 PM EST\n'
                            'Weekend: 10:00 AM – 4:00 PM EST',
                        style: TextStyle(color: Color(0xFF1F2937), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              const _SectionTitle('Submit Feedback'),
              const SizedBox(height: 8),

              // Feedback box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _feedback,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Tell us how we can improve your experience...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Anonymous + submit row
              Row(
                children: [
                  Checkbox(
                    value: _anonymous,
                    onChanged: (v) => setState(() => _anonymous = v ?? false),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const Expanded(
                    child: Text('Submit anonymously',
                        style: TextStyle(color: Color(0xFF111827))),
                  ),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: _submitFeedback,
                      child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              const _SectionTitle('Additional Resources'),
              const SizedBox(height: 8),

              // Resources list
              _ResourceTile(
                iconBg: const Color(0xFFF1E8FF),
                iconColor: const Color(0xFF7C3AED),
                icon: Iconsax.document_text,
                title: 'User Guide',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _ResourceTile(
                iconBg: const Color(0xFFEFF8FF),
                iconColor: const Color(0xFF2563EB),
                icon: Iconsax.video,
                title: 'Video Tutorials',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _ResourceTile(
                iconBg: const Color(0xFFEFFAF3),
                iconColor: const Color(0xFF16A34A),
                icon: Iconsax.message_question,
                title: 'Community Forum',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _emailSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Launching mail composer...')),
    );
  }

  void _callHotline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dialing support hotline...')),
    );
  }

  void _submitFeedback() {
    final text = _feedback.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter feedback before submitting.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for the feedback.')),
    );
    _feedback.clear();
    setState(() => _anonymous = false);
  }
}

/* ----------------------------- Widgets ----------------------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E8ED)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          iconColor: const Color(0xFF9CA3AF),
          collapsedIconColor: const Color(0xFF9CA3AF),
          title: Text(
            question,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            Text(answer, style: const TextStyle(color: Color(0xFF6B7280), height: 1.45)),
          ],
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    this.onTap,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE6E8ED)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Iconsax.arrow_right_3, color: Color(0xFF9CA3AF), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
