// lib/features/profile/ui/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController(text: 'Sarah Johnson');
  final _email = TextEditingController(text: 'sarah.johnson@email.com');
  final _phone = TextEditingController(text: '+1 (555) 123-4567');
  final _company = TextEditingController(text: 'Premium Auto Group');
  final _address = TextEditingController(
      text: '123 Business District, Suite 456 New York, NY 10001');

  ImageProvider? _avatar;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _company.dispose();
    _address.dispose();
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF0F2F6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          )
                        ],
                        image: _avatar != null
                            ? DecorationImage(image: _avatar!, fit: BoxFit.cover)
                            : null,
                      ),
                      child: _avatar == null
                          ? const Icon(Iconsax.user, color: Color(0xFF9CA3AF), size: 40)
                          : null,
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: GestureDetector(
                        onTap: _changePhoto,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Iconsax.camera, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _changePhoto,
                  child: const Text('Edit Photo',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                      )),
                ),

                const SizedBox(height: 10),

                // Full Name
                const _Label('Full Name'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      hintText: 'Sarah Johnson',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Full name is required' : null,
                  ),
                ),

                const SizedBox(height: 12),

                // Email
                const _Label('Email'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'sarah.johnson@email.com',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (v) {
                      final x = v?.trim() ?? '';
                      final rx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                      if (x.isEmpty) return 'Email is required';
                      if (!rx.hasMatch(x)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Phone
                const _Label('Phone Number'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '+1 (555) 123-4567',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Company
                const _Label('Company/Dealership Name'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _company,
                    decoration: const InputDecoration(
                      hintText: 'Premium Auto Group',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Address (Optional)
                const _Label('Address (Optional)'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _address,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '123 Business District, Suite 456 New York, NY 10001',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Save
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      shadowColor: const Color(0xFF7C3AED).withOpacity(0.25),
                    ),
                    onPressed: _save,
                    child: const Text('Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 10),

                // Cancel
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE6E8ED)),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---------------------------- Actions ---------------------------- */

  void _changePhoto() {
    // TODO: hook to image_picker or camera. For now just show a sheet.
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PickerRow(
                icon: Iconsax.camera,
                label: 'Take Photo',
                onTap: () {
                  Navigator.pop(context);
                  // setState(() => _avatar = ...);
                },
              ),
              const SizedBox(height: 8),
              _PickerRow(
                icon: Iconsax.image,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  // setState(() => _avatar = ...);
                },
              ),
              const SizedBox(height: 8),
              _PickerRow(
                icon: Iconsax.trash,
                label: 'Remove Photo',
                danger: true,
                onTap: () {
                  setState(() => _avatar = null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    Navigator.of(context).maybePop();
  }
}

/* ---------------------------- UI Pieces ---------------------------- */

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFEF4444) : const Color(0xFF111827);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
