import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/catalog/models/category_model.dart';

/// Widget for displaying a category chip with gold-themed styling
class CategoryChip extends StatelessWidget {
  final ProductCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define gold-themed colors
    final goldColorLight = const Color(0x1AD4AF37); // 10% opacity
    final goldColorMedium = const Color(0x4DD4AF37); // 30% opacity
    final goldColorSemi = const Color(0x80D4AF37); // 50% opacity

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: goldColorMedium,
        highlightColor: goldColorLight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.goldColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.goldDark : goldColorSemi,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: goldColorMedium,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.getIcon(),
                size: 18,
                color: isSelected ? Colors.white : AppTheme.goldDark,
              ),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.goldDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
