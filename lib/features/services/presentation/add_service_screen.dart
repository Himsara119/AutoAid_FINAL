import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const AddServiceRecordApp());

class AddServiceRecordApp extends StatelessWidget {
  const AddServiceRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Add Service Record',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple, surface: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: purple, width: 1.2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        ),
      ),
      home: const AddServiceRecordScreen(),
    );
  }
}

class AddServiceRecordScreen extends StatefulWidget {
  const AddServiceRecordScreen({super.key});

  @override
  State<AddServiceRecordScreen> createState() => _AddServiceRecordScreenState();
}

class _AddServiceRecordScreenState extends State<AddServiceRecordScreen> {
  final dateCtrl = TextEditingController();
  final nextDateCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final workshopCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? serviceType;
  final serviceTypes = const [
    'Oil Change',
    'Brake Service',
    'Tire Rotation',
    'Battery',
    'Inspection',
    'Other',
  ];

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2010),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Iconsax.arrow_left_2), onPressed: () {}),
        title: const Text(''),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE7E9EF)),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Center(
              child: Text(
                'Add Service Record',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 22, color: Color(0xFF111827)),
              ),
            ),
            const SizedBox(height: 24),

            const _FieldLabel('Service Date'),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () => _pickDate(dateCtrl),
                  icon: const Icon(Iconsax.calendar_1),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Next Service Date'),
            TextField(
              controller: nextDateCtrl,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () => _pickDate(nextDateCtrl),
                  icon: const Icon(Iconsax.calendar_1),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Mileage'),
            TextField(
              controller: mileageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter mileage',
                suffixText: 'miles',
              ),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Service Type'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6E8ED)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: serviceType,
                  isExpanded: true,
                  hint: const Text('Select service type'),
                  icon: const Icon(Iconsax.arrow_down_1),
                  borderRadius: BorderRadius.circular(14),
                  items: serviceTypes
                      .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => serviceType = v),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Workshop / Provider'),
            TextField(
              controller: workshopCtrl,
              decoration: const InputDecoration(hintText: 'Enter workshop or service provider'),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Cost'),
            TextField(
              controller: costCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00'),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Notes'),
            TextField(
              controller: notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes or details...',
              ),
            ),
            const SizedBox(height: 20),

            const _FieldLabel('Invoice'),
            _UploadArea(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload tapped')),
                );
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Record saved')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                child: const Text('Save Record'),
              ),
            ),
          ],
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
        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8DDE6)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.cloud_add, color: Colors.grey.shade500, size: 34),
              const SizedBox(height: 10),
              const Text('Upload Invoice',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 4),
              Text('PDF, JPG, PNG up to 10MB',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
