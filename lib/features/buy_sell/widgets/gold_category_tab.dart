import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/buy_sell/models/gold_models.dart';

/// Widget for gold category tab selection
class GoldCategoryTab extends StatelessWidget {
  final GoldCategory category;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GoldCategoryTab({
    super.key,
    required this.category,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    IconData getIcon() {
      switch (category) {
        case GoldCategory.grams:
          return Icons.scale;
        case GoldCategory.pounds:
          return Icons.monetization_on;
        case GoldCategory.bars:
          return Icons.view_module;
      }
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppTheme.goldColor.withAlpha(isDarkMode ? 60 : 40),
                      AppTheme.goldColor.withAlpha(isDarkMode ? 40 : 20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : isDarkMode
                    ? Colors.grey[850]
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.goldColor
                  : isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.goldColor.withAlpha(30),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.goldColor.withAlpha(isDarkMode ? 80 : 50)
                      : isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getIcon(),
                  color: isSelected ? AppTheme.goldDark : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.goldDark
                      : isDarkMode
                          ? Colors.grey[300]
                          : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
