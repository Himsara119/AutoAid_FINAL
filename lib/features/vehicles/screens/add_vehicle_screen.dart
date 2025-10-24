// main.dart
import 'dart:developer' as dev;
import 'package:finalapp/features/vehicles/screens/vehicles_list_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firebase_options.dart'; // use if you generated options

/* ============================== APP ENTRY ============================== */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sw = Stopwatch()..start();
  try {
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    sw.stop();
    _d('Firebase.initializeApp() ✓ in ${sw.elapsedMilliseconds}ms');
  } catch (e, st) {
    _d('Firebase.initializeApp() ✖ $e', err: e, st: st);
    rethrow;
  }

  runApp(const AddVehicleApp());
}

void _d(String msg, {Object? err, StackTrace? st, String tag = 'AddVehicleApp'}) {
  if (kDebugMode) dev.log(msg, name: tag, error: err, stackTrace: st);
}

/* ============================== CONTROLLER ============================== */

class AddVehicleController {
  static const _tag = 'AddVehicleController';

  late final FirebaseFirestore _db;
  AddVehicleController() {
    try {
      _db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'autoaid',
      );
      _log('Firestore instance ready → db=autoaid');
    } catch (e, st) {
      _log('Firestore instance creation failed', err: e, st: st);
      rethrow;
    }
  }

  Future<void> saveVehicle({
    // requireds (basic)
    required String make,
    required String model,
    required String year,
    required String mileage,
    required String vin,
    required String status,

    // newly added UI fields
    String? trim,
    String? registrationNumber,
    required String fuelType, // petrol/diesel/hybrid/electric
    required bool isForSale,
    String? price,            // as text, we’ll parse
    required String currency, // LKR/USD/etc.

    String? serviceIntervalKm,
    String? serviceIntervalMonths,
    required bool reminderEnabled,
  }) async {
    _log('saveVehicle() inputs → '
        '{make:$make, model:$model, year:$year, mileage:$mileage, vin:$vin, '
        'status:$status, trim:$trim, reg:$registrationNumber, fuel:$fuelType, '
        'isForSale:$isForSale, price:$price, currency:$currency, '
        'svcKm:$serviceIntervalKm, svcMo:$serviceIntervalMonths, remind:$reminderEnabled}');

    final sw = Stopwatch()..start();

    // Parse & validate
    final yr = int.tryParse(year);
    final km = int.tryParse(mileage);
    if (yr == null || yr < 1900) throw ArgumentError('Invalid year: "$year"');
    if (km == null || km < 0) throw ArgumentError('Invalid mileage: "$mileage"');

    final p = (price?.trim().isEmpty ?? true) ? null : num.tryParse(price!.replaceAll(',', ''));
    if (price != null && price!.trim().isNotEmpty && p == null) {
      throw ArgumentError('Invalid price: "$price"');
    }

    final svcKm = (serviceIntervalKm?.trim().isEmpty ?? true)
        ? null
        : int.tryParse(serviceIntervalKm!.trim());
    final svcMo = (serviceIntervalMonths?.trim().isEmpty ?? true)
        ? null
        : int.tryParse(serviceIntervalMonths!.trim());

    final now = DateTime.now();

    final payload = <String, dynamic>{
      // base fields
      'make': make.trim(),
      'model': model.trim(),
      'trim': (trim ?? '').trim(),
      'year': yr,
      'vin': vin.trim(),
      'registration_number': (registrationNumber ?? '').trim(),
      'fuel_type': fuelType.toLowerCase(),
      'mileage': km,
      'status': status.toLowerCase(),

      // sales fields
      'is_for_sale': isForSale,
      'price': p,                // null if not provided
      'currency': currency,      // default LKR in UI

      // service & reminders
      'service_interval_km': svcKm ?? 1000,
      'service_interval_months': svcMo ?? 6,
      'reminder_enabled': reminderEnabled,

      // ownership defaults you were using
      'owner_id': 'users/user_dealer_owner_001',
      'current_owner_id': 'users/user_dealer_owner_001',
      'dealership_id': 'dealerships/dealer_001',

      // bookkeeping
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
      'deleted': false,

      // keep a photos array around for later upload flow
      'photos': <String>[],
    };

    _log('payload →\n${_pretty(payload)}');

    try {
      final doc = _db.collection('vehicles').doc(); // auto-id
      _log('writing → ${doc.path}');
      // merge:true lets you evolve schema safely
      await doc.set(payload, SetOptions(merge: true));
      sw.stop();
      _log('SUCCESS ✓ id=${doc.id} in ${sw.elapsedMilliseconds}ms');
    } on FirebaseException catch (e, st) {
      sw.stop();
      _log('FirebaseException ✖ [${e.code}] ${e.message}', err: e, st: st);
      rethrow;
    } catch (e, st) {
      sw.stop();
      _log('Unknown error ✖ $e', err: e, st: st);
      rethrow;
    }
  }

  void _log(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) dev.log(msg, name: _tag, error: err, stackTrace: st);
  }

  String _pretty(Map<String, dynamic> m) {
    final b = StringBuffer('{');
    var first = true;
    m.forEach((k, v) {
      if (!first) b.write(',\n');
      first = false;
      final vv = v is Timestamp ? 'Timestamp(${v.toDate().toIso8601String()})' : v;
      b.write('  $k: $vv');
    });
    b.write('\n}');
    return b.toString();
  }
}

/* ============================== APP / SCREEN ============================== */

class AddVehicleApp extends StatelessWidget {
  const AddVehicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);
    _d('MaterialApp build()', tag: 'AddVehicleUI');

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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: purple, width: 1.2),
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
  int _rev = 0;

  // basic fields
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final vinCtrl = TextEditingController();

  // new fields
  final trimCtrl = TextEditingController();
  final regNoCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final serviceKmCtrl = TextEditingController();
  final serviceMoCtrl = TextEditingController();

  String status = 'Active';
  final statuses = const ['Active', 'Pending', 'Sold', 'Archived'];

  String fuelType = 'petrol';
  final fuelTypes = const ['petrol', 'diesel', 'hybrid', 'electric'];

  String currency = 'LKR';
  final currencies = const ['LKR', 'USD', 'EUR', 'GBP'];



  bool isForSale = false;
  bool reminderEnabled = true;

  final _formKey = GlobalKey<FormState>();
  final _controller = AddVehicleController();

  static const _tag = 'AddVehicleScreen';
  void _log(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) dev.log(msg, name: _tag, error: err, stackTrace: st);
  }

  @override
  void dispose() {
    makeCtrl.dispose();
    modelCtrl.dispose();
    yearCtrl.dispose();
    mileageCtrl.dispose();
    vinCtrl.dispose();
    trimCtrl.dispose();
    regNoCtrl.dispose();
    priceCtrl.dispose();
    serviceKmCtrl.dispose();
    serviceMoCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    for (final c in [
      makeCtrl,
      modelCtrl,
      yearCtrl,
      mileageCtrl,
      vinCtrl,
      trimCtrl,
      regNoCtrl,
      priceCtrl,
      serviceKmCtrl,
      serviceMoCtrl,
    ]) {
      c.clear();
    }
    setState(() {
      status = 'Active';
      fuelType = 'petrol';
      currency = 'LKR';
      isForSale = false;
      reminderEnabled = true;
      _rev++;
    });
    _formKey.currentState?.reset();

    //Add this block here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {}); // forces a rebuild next frame
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final faded = TextStyle(color: Colors.black.withOpacity(0.65));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.to(() => const VehiclesScreen()),
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
                const Center(child: _AvatarUpload(size: 108)),
                const SizedBox(height: 20),

                // Make
                const _FieldLabel('Make'),
                TextFormField(
                  key: ValueKey('make_$_rev'),
                  controller: makeCtrl,
                  style: faded,
                  decoration: const InputDecoration(suffixIcon: _HintIcon()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Model
                const _FieldLabel('Model'),
                TextFormField(
                  key: ValueKey('model_$_rev'),
                  controller: modelCtrl,
                  style: faded,
                  decoration: const InputDecoration(suffixIcon: _HintIcon()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Trim
                const _FieldLabel('Trim'),
                TextFormField(
                  key: ValueKey('trim_$_rev'),
                  controller: trimCtrl,
                  style: faded,
                  decoration: const InputDecoration(hintText: 'EX / G / S'),
                ),
                const SizedBox(height: 16),

                // Year
                const _FieldLabel('Year'),
                TextFormField(
                  key: ValueKey('year_$_rev'),
                  controller: yearCtrl,
                  style: faded,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixIcon: Icon(Iconsax.calendar_1)),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1900) return 'Enter a valid year';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mileage
                const _FieldLabel('Mileage'),
                TextFormField(
                  key: ValueKey('mileage_$_rev'),
                  controller: mileageCtrl,
                  style: faded,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 45000'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid mileage';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // VIN
                const _FieldLabel('VIN'),
                TextFormField(
                  key: ValueKey('vin_$_rev'),
                  controller: vinCtrl,
                  style: faded,
                  decoration: const InputDecoration(hintText: '17 characters'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Registration number
                const _FieldLabel('Registration Number'),
                TextFormField(
                  key: ValueKey('reg_$_rev'),
                  controller: regNoCtrl,
                  style: faded,
                  decoration: const InputDecoration(hintText: 'WP-CAB-1234'),
                ),
                const SizedBox(height: 16),

                // Status
                const _FieldLabel('Status'),
                _Dropdown<String>(
                  value: status,
                  items: statuses,
                  onChanged: (v) => setState(() => status = v),
                ),
                const SizedBox(height: 18),

                // Fuel type
                const _FieldLabel('Fuel Type'),
                _Dropdown<String>(
                  value: fuelType,
                  items: fuelTypes,
                  onChanged: (v) => setState(() => fuelType = v),
                ),
                const SizedBox(height: 18),

                // Sale block
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Price'),
                          TextFormField(
                            key: ValueKey('price_$_rev'),
                            controller: priceCtrl,
                            style: faded,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'e.g. 7250000'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Currency'),
                          _Dropdown<String>(
                            value: currency,
                            items: currencies,
                            onChanged: (v) => setState(() => currency = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  value: isForSale,
                  onChanged: (v) => setState(() => isForSale = v),
                  title: const Text('Mark as For Sale'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6),

                // Service intervals
                const _FieldLabel('Service Interval'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: serviceKmCtrl,
                        style: faded,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'KM (e.g. 1000)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: serviceMoCtrl,
                        style: faded,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Months (e.g. 6)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  value: reminderEnabled,
                  onChanged: (v) => setState(() => reminderEnabled = v),
                  title: const Text('Enable reminders'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                _PrimaryButton(
                  text: 'Add Vehicle',
                  onPressed: () async {
                    final valid = _formKey.currentState?.validate() ?? false;
                    if (!valid) return;

                    try {
                      await _controller.saveVehicle(
                        make: makeCtrl.text,
                        model: modelCtrl.text,
                        year: yearCtrl.text,
                        mileage: mileageCtrl.text,
                        vin: vinCtrl.text,
                        status: status,
                        trim: trimCtrl.text,
                        registrationNumber: regNoCtrl.text,
                        fuelType: fuelType,
                        isForSale: isForSale,
                        price: priceCtrl.text,
                        currency: currency,
                        serviceIntervalKm: serviceKmCtrl.text,
                        serviceIntervalMonths: serviceMoCtrl.text,
                        reminderEnabled: reminderEnabled,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vehicle saved')),
                        );
                        _resetForm();
                      }
                    } on ArgumentError catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(e.message.toString())));
                      }
                    } on FirebaseException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Firestore error: ${e.message ?? e.code}')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
                const SizedBox(height: 14),
              ],
            ),
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

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(Iconsax.arrow_down_1, color: Colors.black.withOpacity(0.6)),
          items: items
              .map((e) => DropdownMenuItem<T>(
            value: e,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '$e',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.7),
                ),
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
