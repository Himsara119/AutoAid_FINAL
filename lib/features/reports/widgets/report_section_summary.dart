import 'package:flutter/material.dart';

/// Pills component showing selected sections for a report.
/// - Pass the list of section names (e.g., ["Overview","Service History"])
/// - Optional onRemove to show a close icon and make chips removable.
/// - Optional header and count display.
class ReportSectionSummary extends StatelessWidget {
  const ReportSectionSummary({
    super.key,
    required this.sections,
    this.title = 'Report Summary',
    this.showCount = true,
    this.onRemove, // (section) => void
    this.spacing = 8,
    this.runSpacing = 6,
  });

  final Iterable<String> sections;
  final String title;
  final bool showCount;
  final void Function(String section)? onRemove;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = sections.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (showCount)
          Text(
            'Selected sections: ${items.length}',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        if (showCount) const SizedBox(height: 8),
        Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: items.map((s) => _SectionChip(label: s, onRemove: onRemove)).toList(),
        ),
      ],
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({required this.label, this.onRemove});
  final String label;
  final void Function(String section)? onRemove;

  @override
  Widget build(BuildContext context) {
    final removable = onRemove != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E8FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE9D9FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
          ),
          if (removable) const SizedBox(width: 6),
          if (removable)
            GestureDetector(
              onTap: () => onRemove!(label),
              child: const Icon(Icons.close, size: 14, color: Color(0xFF7C3AED)),
            ),
        ],
      ),
    );
  }
}
//ADDED
