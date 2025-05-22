import 'package:flutter/material.dart';
import 'package:golden_wallet/config/theme.dart';

/// Model for transaction detail
class TransactionDetail {
  final String label;
  final String value;

  const TransactionDetail({
    required this.label,
    required this.value,
  });
}

/// Widget for transaction summary card
class TransactionSummaryCard extends StatelessWidget {
  final String title;
  final List<TransactionDetail> details;
  final TransactionDetail total;

  const TransactionSummaryCard({
    super.key,
    required this.title,
    required this.details,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.goldColor.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...details.map((detail) => _buildDetailRow(
                detail.label,
                detail.value,
                isDarkMode,
              )),
          const Divider(height: 24),
          _buildDetailRow(
            total.label,
            total.value,
            isDarkMode,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDarkMode, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? AppTheme.goldDark
                  : isDarkMode
                      ? Colors.grey[300]
                      : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? AppTheme.goldDark
                  : isDarkMode
                      ? Colors.grey[300]
                      : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
