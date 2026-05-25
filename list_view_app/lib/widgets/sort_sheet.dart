import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Bottom sheet that lets the user pick a [SortOrder].
/// Calls [onOrderChanged] and pops itself when a selection is made.
class SortSheet extends StatelessWidget {
  final SortOrder currentOrder;
  final ValueChanged<SortOrder> onOrderChanged;

  const SortSheet({
    super.key,
    required this.currentOrder,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Urutkan',
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih cara pengurutan daftar item.',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ...SortOrder.values.map((o) => _SortOption(
                order: o,
                isSelected: o == currentOrder,
                onTap: () {
                  onOrderChanged(o);
                  Navigator.of(context).pop();
                },
              )),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final SortOrder order;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon => switch (order) {
        SortOrder.nameAsc => Icons.sort_by_alpha_rounded,
        SortOrder.nameDesc => Icons.sort_by_alpha_rounded,
        SortOrder.newest => Icons.schedule_rounded,
        SortOrder.oldest => Icons.history_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(25)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 14),
            Text(
              order.label,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
