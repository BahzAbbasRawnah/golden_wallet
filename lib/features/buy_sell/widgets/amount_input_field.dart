import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golden_wallet/config/theme.dart';

/// Widget for amount input field
class AmountInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String unit;
  final IconData icon;
  final bool readOnly;
  final Function(String)? onChanged;
  final bool showIncrement;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final String? helperText;

  const AmountInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.unit,
    required this.icon,
    this.readOnly = false,
    this.onChanged,
    this.showIncrement = false,
    this.onIncrement,
    this.onDecrement,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.goldColor.withAlpha(50),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withAlpha(isDarkMode ? 40 : 20),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14.5),
                    bottomLeft: Radius.circular(14.5),
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.goldDark,
                  size: 24,
                ),
              ),
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    // This will trigger a rebuild when focus changes
                    if (hasFocus) {
                      // You could add animation or state change here
                    }
                  },
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    onChanged: onChanged,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (showIncrement) ...[
                _buildIncrementButton(
                  icon: Icons.remove,
                  onTap: onDecrement,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 8),
                _buildIncrementButton(
                  icon: Icons.add,
                  onTap: onIncrement,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              helperText!,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIncrementButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.goldColor.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.goldDark,
          size: 16,
        ),
      ),
    );
  }
}
