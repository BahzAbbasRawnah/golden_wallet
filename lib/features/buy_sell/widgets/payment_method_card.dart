import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';

/// Widget for payment method selection card
class PaymentMethodCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldColor.withAlpha(isDarkMode ? 40 : 30)
              : isDarkMode
                  ? Colors.grey[850]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
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
                    color: AppTheme.goldColor.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.goldColor.withAlpha(50)
                    : isDarkMode
                        ? Colors.grey[800]
                        : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.goldDark : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.goldDark
                          : isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.goldDark.withAlpha(200)
                            : isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppTheme.goldDark,
            ),
          ],
        ),
      ),
    );
  }
}
