import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const EditVehicleScreen());

class _DemoApp extends StatelessWidget {
  const _DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edit Vehicle',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins', // assumes Poppins is configured in pubspec
        scaffoldBackgroundColor: const Color(0xFFF4F2FF),
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: purple, width: 1.2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB8BDC7)),
        ),
      ),
      home: const EditVehicleScreen(),
    );
  }
}

class EditVehicleScreen extends StatefulWidget {
  const EditVehicleScreen({super.key});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _makeCtrl = TextEditingController(text: 'Toyota');
  final _modelCtrl = TextEditingController(text: 'Camry');
  final _yearCtrl = TextEditingController(text: '2022');
  final _mileageCtrl = TextEditingController(text: '25000');
  final _vinCtrl = TextEditingController(text: '1HGBH41JXMN109186');

  String _status = 'Active';

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    _vinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Edit Vehicle',
          style: t.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / photo picker
              Center(
                child: _CirclePhotoPicker(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pick vehicle photo')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              const _FieldLabel('Make'),
              TextField(
                controller: _makeCtrl,
                decoration: const InputDecoration(
                  hintText: 'Toyota',
                  suffixIcon: _HintIcon(),
                ),
              ),
              const SizedBox(height: 16),

              const _FieldLabel('Model'),
              TextField(
                controller: _modelCtrl,
                decoration: const InputDecoration(
                  hintText: 'Camry',
                  suffixIcon: _HintIcon(),
                ),
              ),
              const SizedBox(height: 16),

              const _FieldLabel('Year'),
              TextField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '2022',
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Iconsax.calendar_1),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const _FieldLabel('Mileage'),
              TextField(
                controller: _mileageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '25000',
                  suffixIcon: _HintIcon(),
                ),
              ),
              const SizedBox(height: 16),

              const _FieldLabel('VIN'),
              TextField(
                controller: _vinCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: '1HGBH41JXMN109186',
                  suffixIcon: _HintIcon(),
                ),
              ),
              const SizedBox(height: 16),

              const _FieldLabel('Status'),
              _StatusDropdown(
                value: _status,
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const _Dot(color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Text(
                    _status == 'Active' ? 'Currently Active' : 'Not Active',
                    style: t.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cards
              _InfoCard(
                leadingColor: c.primary.withOpacity(0.12),
                leadingIcon: Iconsax.image,
                title: 'Vehicle Photos',
                subtitle: '3 photos added',
                onTap: () => _toast(context, 'Open vehicle photos'),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                leadingColor: c.primary.withOpacity(0.12),
                leadingIcon: Iconsax.shield_tick,
                title: 'Insurance Details',
                subtitle: 'Update insurance info',
                onTap: () => _toast(context, 'Open insurance details'),
              ),

              const SizedBox(height: 24),

              // Save / Delete
              _PrimaryButton(
                text: 'Save Changes',
                onPressed: () => _toast(context, 'Vehicle saved'),
              ),
              const SizedBox(height: 12),
              _DangerOutlineButton(
                text: 'Delete Vehicle',
                onPressed: () => _toast(context, 'Vehicle deleted'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/* =============================== MINI WIDGETS =============================== */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _HintIcon extends StatelessWidget {
  const _HintIcon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 6),
      child: Icon(Iconsax.info_circle, color: Color(0xFFB8BDC7)),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(Iconsax.arrow_down_1),
          isExpanded: true,
          style: const TextStyle(fontSize: 16, color: Color(0xFF111827)),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: const [
            DropdownMenuItem(value: 'Active', child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Active'))),
            DropdownMenuItem(value: 'Inactive', child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Inactive'))),
            DropdownMenuItem(value: 'Pending', child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Pending'))),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.leadingColor,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color leadingColor;
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E8ED)),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: leadingColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(leadingIcon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      )),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const _HintIcon(),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(text),
      ),
    );
  }
}

class _DangerOutlineButton extends StatelessWidget {
  const _DangerOutlineButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          foregroundColor: red,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(text),
      ),
    );
  }
}

class _CirclePhotoPicker extends StatelessWidget {
  const _CirclePhotoPicker({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: c.primary, style: BorderStyle.solid, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
            ),
            child: Icon(Iconsax.message_question, color: c.primary, size: 26),
          ),
        ),
      ),
    );
  }
}
