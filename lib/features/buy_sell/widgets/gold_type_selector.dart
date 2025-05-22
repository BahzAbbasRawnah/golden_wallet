import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/buy_sell/models/gold_models.dart';

/// Widget for selecting gold type (karat)
class GoldTypeSelector extends StatelessWidget {
  final String label;
  final List<GoldKarat> options;
  final GoldKarat selectedOption;
  final Function(GoldKarat) onChanged;

  const GoldTypeSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.goldColor.withAlpha(30),
              width: 1,
            ),
          ),
          child: Row(
            children: options.map((option) {
              final isSelected = option.karat == selectedOption.karat;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.goldColor.withAlpha(isDarkMode ? 40 : 30)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: AppTheme.goldColor,
                              width: 1.5,
                            )
                          : null,
                    ),
                      child: Text(
                          option.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.goldDark
                                : isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
          
                    
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
