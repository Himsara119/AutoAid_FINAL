import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const AddVehicleApp());

class AddVehicleApp extends StatelessWidget {
  const AddVehicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Add Vehicle',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF6F4FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.85),
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: purple, width: 1.2),
          ),
        ),
      ),
      home: const AddVehicleScreen(),
    );
  }
}

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final makeCtrl = TextEditingController(text: 'Toyota');
  final modelCtrl = TextEditingController(text: 'Camry');
  final yearCtrl = TextEditingController(text: '2022');
  final mileageCtrl = TextEditingController(text: '25000');
  final vinCtrl = TextEditingController(text: '1HGBH41JXMN109186');

  String status = 'Active';
  final statuses = const ['Active', 'Pending', 'Sold', 'Archived'];

  @override
  void dispose() {
    makeCtrl.dispose();
    modelCtrl.dispose();
    yearCtrl.dispose();
    mileageCtrl.dispose();
    vinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final fadedText = TextStyle(color: Colors.black.withOpacity(0.65));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Iconsax.arrow_left_2, color: Colors.black.withOpacity(0.7)),
                  ),
                  Expanded(
                    child: Text('Add Vehicle',
                        textAlign: TextAlign.center,
                        style: t.titleLarge?.copyWith(
                            color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 18),

              // Avatar / Upload placeholder
              const Center(child: _AvatarUpload(size: 108)),

              const SizedBox(height: 20),

              const _FieldLabel('Make'),
              TextField(controller: makeCtrl, style: fadedText, decoration: const InputDecoration(suffixIcon: _HintIcon())),
              const SizedBox(height: 16),

              const _FieldLabel('Model'),
              TextField(controller: modelCtrl, style: fadedText, decoration: const InputDecoration(suffixIcon: _HintIcon())),
              const SizedBox(height: 16),

              const _FieldLabel('Year'),
              TextField(
                  controller: yearCtrl,
                  style: fadedText,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixIcon: Icon(Iconsax.calendar_1))),
              const SizedBox(height: 16),

              const _FieldLabel('Mileage'),
              TextField(controller: mileageCtrl, style: fadedText, decoration: const InputDecoration(suffixIcon: _HintIcon())),
              const SizedBox(height: 16),

              const _FieldLabel('VIN'),
              TextField(controller: vinCtrl, style: fadedText, decoration: const InputDecoration(suffixIcon: _HintIcon())),
              const SizedBox(height: 16),

              const _FieldLabel('Status'),
              _StatusDropdown(
                value: status,
                items: statuses,
                onChanged: (v) => setState(() => status = v),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const _Dot(color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Text('Currently Active', style: TextStyle(color: Colors.black.withOpacity(0.65))),
                ],
              ),

              const SizedBox(height: 18),

              _SectionTile(
                leading: const _DottedIcon(),
                title: 'Vehicle Photos',
                subtitle: '3 photos added',
                trailing: const _HintIcon(),
                onTap: () {},
              ),
              const SizedBox(height: 12),

              _SectionTile(
                leading: const _DottedIcon(),
                title: 'Insurance Details',
                subtitle: 'Update insurance info',
                trailing: const _HintIcon(),
                onTap: () {},
              ),

              const SizedBox(height: 24),

              _PrimaryButton(
                text: 'Add Vehicle',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vehicle saved')),
                  );
                },
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== MINI WIDGETS ============================== */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.black.withOpacity(0.75)),
      ),
    );
  }
}

class _HintIcon extends StatelessWidget {
  const _HintIcon({super.key});
  @override
  Widget build(BuildContext context) {
    return Icon(Iconsax.message_question, color: Colors.grey.withOpacity(0.6));
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(Iconsax.arrow_down_1, color: Colors.black.withOpacity(0.6)),
          items: items
              .map((e) => DropdownMenuItem<String>(
            value: e,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                e,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.7)),
              ),
            ),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, super.key});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleMedium?.copyWith(color: Colors.black.withOpacity(0.8))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: t.bodyMedium?.copyWith(color: Colors.black.withOpacity(0.55))),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _DottedIcon extends StatelessWidget {
  const _DottedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: c.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: c.primary.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Icon(Iconsax.message_question, color: c.primary.withOpacity(0.9)),
    );
  }
}

class _AvatarUpload extends StatelessWidget {
  const _AvatarUpload({required this.size, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Container(
          width: size * 0.38,
          height: size * 0.38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.primary.withOpacity(0.8), width: 2),
          ),
          child: Icon(Iconsax.message_question, color: c.primary.withOpacity(0.8)),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed, super.key});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: c.primary.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
