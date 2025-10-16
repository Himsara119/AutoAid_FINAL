// lib/features/profile/ui/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _units = 'Metric';
  String _currency = 'USD';
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      bottomNavigationBar: _BottomNav(currentIndex: 1, onTap: (_) {}),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              // Header: gradient card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.profile_circle, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('John Anderson',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18)),
                          SizedBox(height: 2),
                          Text('john.anderson@email.com',
                              style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Profile section
              _SectionCard(
                title: 'Profile',
                children: [
                  _NavTile(
                    iconBg: const Color(0xFFEFF4FF),
                    icon: Iconsax.user_edit,
                    label: 'Edit Profile',
                    onTap: () {},
                  ),
                ],
              ),

              // AI Tools
              _SectionCard(
                title: 'AI Tools',
                children: [
                  _NavTile(
                    iconBg: const Color(0xFFFFF0F1),
                    icon: Iconsax.shield_search,
                    iconColor: const Color(0xFFEF6B6B),
                    label: 'AI Diagnosis',
                    onTap: () {},
                  ),
                  _NavTile(
                    iconBg: const Color(0xFFEFFAF3),
                    icon: Iconsax.scan_barcode,
                    iconColor: const Color(0xFF16A34A),
                    label: 'Visual Scan',
                    onTap: () {},
                  ),
                  _NavTile(
                    iconBg: const Color(0xFFF1E8FF),
                    icon: Iconsax.document_upload5,
                    iconColor: const Color(0xFF7C3AED),
                    label: 'Report Builder',
                    onTap: () {},
                  ),
                  _NavTile(
                    iconBg: const Color(0xFFFFF7E8),
                    icon: Iconsax.location5,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Mechanic Finder',
                    onTap: () {},
                  ),
                ],
              ),

              // Settings
              _SectionCard(
                title: 'Settings',
                children: [
                  _DropdownTile(
                    iconBg: const Color(0xFFEFF1F5),
                    icon: Iconsax.setting_2,
                    label: 'Units',
                    value: _units,
                    items: const ['Metric', 'Imperial'],
                    onChanged: (v) => setState(() => _units = v!),
                  ),
                  _DropdownTile(
                    iconBg: const Color(0xFFEFF1F5),
                    icon: Iconsax.dollar_circle,
                    label: 'Currency',
                    value: _currency,
                    items: const ['USD', 'EUR', 'LKR', 'GBP', 'JPY'],
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                  _SwitchTile(
                    iconBg: const Color(0xFFEFF1F5),
                    icon: Iconsax.sun_1,
                    label: 'Theme',
                    value: _dark,
                    onChanged: (v) => setState(() => _dark = v),
                  ),
                  _NavTile(
                    iconBg: const Color(0xFFEFF1F5),
                    icon: Iconsax.info_circle,
                    label: 'About',
                    onTap: () {},
                  ),
                ],
              ),

              // Help
              _SectionCard(
                title: 'Help',
                children: [
                  _NavTile(
                    iconBg: const Color(0xFFFFF7E8),
                    icon: Iconsax.message_question,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'FAQ',
                    onTap: () {},
                  ),
                  _NavTile(
                    iconBg: const Color(0xFFE6FFFB),
                    icon: Iconsax.support,
                    iconColor: const Color(0xFF06B6D4),
                    label: 'Support',
                    onTap: () {},
                  ),
                ],
              ),

              // Logout card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF0F0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Iconsax.logout, color: Color(0xFFEF4444)),
                    label: const Text('Logout',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------- Widgets ------------------------------- */

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // title
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Text(title,
                style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          ),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          ..._intersperse(children, const Divider(height: 1, color: Color(0xFFF0F2F5))),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.iconBg,
    required this.icon,
    required this.label,
    this.iconColor = const Color(0xFF111827),
    this.onTap,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const Icon(Iconsax.arrow_right_3, color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.iconBg,
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final Color iconBg;
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF111827), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                icon: const Icon(Iconsax.arrow_down_1, size: 16),
                items: items
                    .map((e) =>
                    DropdownMenuItem<String>(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.iconBg,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Color iconBg;
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF111827), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF7C3AED),
      unselectedItemColor: const Color(0xFF9CA3AF),
      items: const [
        BottomNavigationBarItem(icon: Icon(Iconsax.home_1), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
      ],
    );
  }
}

/* ----------------------------- helpers ----------------------------- */

List<Widget> _intersperse(List<Widget> list, Widget separator) {
  if (list.isEmpty) return list;
  return [
    for (int i = 0; i < list.length; i++) ...[
      list[i],
      if (i != list.length - 1) separator,
    ]
  ];
}
