import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Widget for displaying a transaction item in a list
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction header
            Row(
              children: [
                // Transaction icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: transaction.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    transaction.type.icon,
                    color: transaction.type.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Transaction info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.type.translationKey.tr(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        transaction.id,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),

                // Transaction amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.type.isIncoming ? '+' : '-'} ${transaction.currency} ${transaction.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: transaction.type.isIncoming
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                          ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Transaction details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gold weight and type
                if (transaction.goldWeight != null &&
                    transaction.goldType != null)
                  _buildDetailItem(
                    context,
                    'weight'.tr(),
                    '${transaction.goldWeight!.toStringAsFixed(2)} oz ${transaction.goldType}',
                  )
                else
                  _buildDetailItem(
                    context,
                    'amount'.tr(),
                    '\$${transaction.amount.toStringAsFixed(2)}',
                  ),

                // Price
                _buildDetailItem(
                  context,
                  'price'.tr(),
                  '\$${transaction.price.toStringAsFixed(2)}',
                ),

                // Status
                _buildStatusChip(context, transaction.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail item
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  /// Build status chip
  Widget _buildStatusChip(BuildContext context, TransactionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        status.translationKey.tr(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
