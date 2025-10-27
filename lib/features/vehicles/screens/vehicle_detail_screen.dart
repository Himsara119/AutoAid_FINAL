// lib/features/vehicles/ui/vehicle_details_screen.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../documents/controllers/documents_controller.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../models/vehicle_model.dart';

// tabs
import '../tabs/documents_tab.dart';
import '../tabs/overview_tab.dart';
import '../tabs/reports_tab.dart';
import '../tabs/service_tab.dart';
import 'edit_vehicle_screen.dart';

// Notifications screen
import '../../notifications/screens/notifications_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late final VehicleDetailController controller;

  // --- mirroring bits ---
  DocumentController? _docsCtl;
  StreamSubscription? _docsSub;

  void _d(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) {
      dev.log(msg, name: 'VehicleDetailsScreen', error: err, stackTrace: st);
    }
  }

  @override
  void initState() {
    super.initState();

    // Ensure controller is bound with a concrete vehicle id (same logic as before)
    final id = Get.parameters['id'] ?? (Get.arguments as String?);
    assert(id != null && id!.isNotEmpty, 'No vehicle id provided for VehicleDetailsScreen');

    // Bind the vehicle detail controller once
    if (!Get.isRegistered<VehicleDetailController>()) {
      Get.put(VehicleDetailController(id!));
      _d('Guard bound VehicleDetailController(id=$id)');
    }
    controller = Get.find<VehicleDetailController>();

    // ---------- START MIRRORING DOCUMENTS -> NOTIFICATIONS ----------
    // Put a per-vehicle DocumentController and subscribe to its stream.
    // The stream side-effect mirrors document expiry alerts into notifications.
    _docsCtl = Get.put(DocumentController(controller.id), tag: 'docs_${controller.id}', permanent: true);
    _docsSub = _docsCtl!.stream.listen(
          (_) {},
      onError: (e, st) => _d('Document mirroring stream error', err: e, st: st),
    );
    // ---------------------------------------------------------------
  }

  @override
  void dispose() {
    _docsSub?.cancel();
    _docsSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    _d('build()');

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left_2),
                    onPressed: () {
                      _d('Back pressed');
                      Get.back();
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Vehicle Overview',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475467),
                    ),
                  ),
                  const Spacer(),

                  // Per-vehicle notifications
                  IconButton(
                    tooltip: 'Vehicle notifications',
                    icon: const Icon(Iconsax.notification),
                    onPressed: () {
                      final vid = controller.id;
                      _d('Open notifications tapped (vehicleId=$vid)');
                      Get.to(() => NotificationsScreen(
                        vehicleId: controller.id,
                        title: 'Notifications',
                      ));
                    },
                  ),

                  // Optional: quick reload
                  IconButton(
                    tooltip: 'Reload',
                    onPressed: () {
                      _d('hardReload tapped');
                      controller.hardReload();
                    },
                    icon: const Icon(Iconsax.refresh),
                  ),

                  // Optional overflow: jump to global notifications (no vehicle filter)
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    icon: const Icon(Iconsax.more),
                    onSelected: (v) {
                      if (v == 'all_notifications') {
                        _d('Open global notifications (collectionGroup feed)');
                        Get.to(() => const NotificationsScreen(
                          title: 'Notifications',
                          // no vehicleId → global feed, ensure your feed controller supports this path
                        ));
                      } else if (v == 'edit') {
                        _d('Edit vehicle pressed');
                        Get.to(() => EditVehicleScreen(vehicleId: controller.id));
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'all_notifications',
                        child: Text('All notifications'),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit vehicle'),
                      ),
                    ],
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: divider),
              ),
            ),

            // IMAGE HERO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Obx(() {
                  if (controller.loading.value) {
                    return const _HeroSkeleton();
                  }
                  if (controller.error.value != null) {
                    return _ErrorCard(text: controller.error.value!);
                  }
                  final v = controller.vehicle.value;
                  if (v == null) return const _ImagePlaceholder();

                  final List<String> photos = _extractPhotos(v);
                  if (photos.isEmpty) return const _ImagePlaceholder();

                  return _HeroGallery(urls: photos);
                }),
              ),
            ),

            // HEADER SUMMARY
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Obx(() {
                  if (controller.loading.value) {
                    _d('header: loading');
                    return const _HeaderSkeleton();
                  }
                  if (controller.error.value != null) {
                    _d('header: error → ${controller.error.value}');
                    return Text(controller.error.value!,
                        style: const TextStyle(color: Colors.red));
                  }

                  final VehicleModel v = controller.vehicle.value!;
                  final t = Theme.of(context).textTheme;

                  _d('header: data ✓ ${v.make} ${v.model} y=${v.year} mi=${v.mileage}');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${v.make} ${v.model}'.trim(),
                        style: t.titleLarge?.copyWith(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MetaText(text: v.year > 0 ? v.year.toString() : '—'),
                          const _Dot(),
                          _MetaText(text: v.trim.isNotEmpty ? v.trim : '—'),
                          const _Dot(),
                          _MetaText(text: v.mileage > 0 ? '${v.mileage} km' : '—'),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ),
            ),

            // TABS HEADER
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeaderDelegate(
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    labelColor: c.primary,
                    unselectedLabelColor: const Color(0xFF6B7280),
                    indicatorColor: c.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Service History'),
                      Tab(text: 'Documents'),
                      Tab(text: 'Reports'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: Obx(() {
            if (controller.loading.value) {
              _d('body: loading');
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error.value != null) {
              _d('body: error → ${controller.error.value}');
              return Center(child: Text(controller.error.value!));
            }
            _d('body: data ✓ render tabs');
            return TabBarView(
              children: [
                const OverviewTab(),
                const ServiceHistoryTab(),
                DocumentsTab(vehicleId: controller.id),
                ReportsTab(vehicleId: controller.id),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Pulls photos from VehicleModel with maximum tolerance for schema differences.
  static List<String> _extractPhotos(VehicleModel v) {
    final urls = <String>[];

    // preferred: a photos array
    try {
      final p = v.photos;
      if (p != null) {
        urls.addAll(
          p.where((e) => e is String && e.toString().trim().isNotEmpty).cast<String>(),
        );
      }
    } catch (_) {}

    // secondary: primaryPhoto string field
    try {
      final prim = (v as dynamic).primaryPhoto as String?;
      if (prim != null && prim.trim().isNotEmpty && !urls.contains(prim)) {
        urls.insert(0, prim);
      }
    } catch (_) {}

    // tertiary: raw map lookups
    try {
      final raw = (v as dynamic).raw as Map<String, dynamic>?;
      if (raw != null) {
        final prim = raw['primary_photo'] as String?;
        final list = (raw['photos'] as List?)?.whereType<String>().toList() ?? const <String>[];
        if (prim != null && prim.trim().isNotEmpty && !urls.contains(prim)) {
          urls.insert(0, prim);
        }
        for (final u in list) {
          if (!urls.contains(u) && u.trim().isNotEmpty) urls.add(u);
        }
      }
    } catch (_) {}

    return urls;
  }
}

/* ------------------------ Header widgets ------------------------ */

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DEE8)),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5B3B3)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.red)),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DEE8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFEFF1F6),
            child: Icon(Iconsax.camera, color: Color(0xFF98A2B3), size: 28),
          ),
          SizedBox(height: 10),
          Text('No images', style: TextStyle(color: Color(0xFF98A2B3))),
        ],
      ),
    );
  }
}

class _HeroGallery extends StatefulWidget {
  const _HeroGallery({required this.urls});
  final List<String> urls;

  @override
  State<_HeroGallery> createState() => _HeroGalleryState();
}

class _HeroGalleryState extends State<_HeroGallery> {
  final _pc = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pc,
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final u = urls[i];
                return Image.network(
                  u,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => const _BrokenImage(),
                  loadingBuilder: (context, child, prog) {
                    if (prog == null) return child;
                    return const _HeroSkeleton();
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (urls.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(urls.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 18 : 6,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF475467) : const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF1F6),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF98A2B3)),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ShimmerBox(width: 180, height: 20),
        SizedBox(height: 8),
        _ShimmerBox(width: 220, height: 14),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F6),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF475467),
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('•', style: TextStyle(color: Color(0xFF98A2B3))),
    );
  }
}

/* ----------------------- Tabs Header ------------------------ */

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabsHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => kToolbarHeight - 8;
  @override
  double get maxExtent => kToolbarHeight - 8;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) => false;
}