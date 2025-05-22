import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/features/transactions/providers/transaction_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Transaction Detail Screen
class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return FutureBuilder<Transaction?>(
      future: provider.getTransactionById(transactionId),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for the transaction
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error message if transaction not found
        if (snapshot.data == null) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: Center(
              child: Text(
                'transactionNotFound'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        // Show transaction details
        final transaction = snapshot.data!;

        return Scaffold(
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction header
                _buildTransactionHeader(context, transaction),
                const SizedBox(height: 24),

                // Transaction details
                _buildTransactionDetails(context, transaction),
                const SizedBox(height: 24),

                // Payment details
                if (transaction.paymentMethod != null)
                  _buildPaymentDetails(context, transaction),
                if (transaction.paymentMethod != null)
                  const SizedBox(height: 24),

                // Notes
                if (transaction.description != null)
                  _buildNotes(context, transaction),
                if (transaction.description != null) const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(context, transaction),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build app bar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'transactionDetails'.tr(),
        style: TextStyle(
          color: AppTheme.goldDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppTheme.goldDark,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Build transaction header
  Widget _buildTransactionHeader(
      BuildContext context, Transaction transaction) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction type and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: transaction.type.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transaction.type.icon,
                      color: transaction.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    transaction.type.translationKey.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              _buildStatusChip(context, transaction.status),
            ],
          ),
          const SizedBox(height: 16),

          // Transaction ID and date
          _buildDetailRow(
            context,
            'transactionId'.tr(),
            transaction.id,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'transactionDate'.tr(),
            DateFormat('MMM dd, yyyy HH:mm').format(transaction.date),
          ),
          if (transaction.reference != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'transactionReference'.tr(),
              transaction.reference!,
            ),
          ],
          const SizedBox(height: 16),

          // Transaction amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transaction.type.color.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'totalAmount'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${transaction.type.isIncoming ? '+' : '-'} ${transaction.currency} ${transaction.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: transaction.type.isIncoming
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build transaction details
  Widget _buildTransactionDetails(
      BuildContext context, Transaction transaction) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'transactionDetails'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Gold details
          if (transaction.goldWeight != null &&
              transaction.goldType != null) ...[
            _buildDetailRow(
              context,
              'goldType'.tr(),
              transaction.goldType!,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'weight'.tr(),
              '${transaction.goldWeight!.toStringAsFixed(2)} ${'grams'.tr()}',
            ),
            if (transaction.goldCategory != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                'category'.tr(),
                transaction.goldCategory!,
              ),
            ],
          ],

          // Price details
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'price'.tr(),
            '${transaction.currency} ${transaction.price.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'amount'.tr(),
            '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            'total'.tr(),
            '${transaction.currency} ${transaction.totalAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  /// Build payment details
  Widget _buildPaymentDetails(BuildContext context, Transaction transaction) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'paymentDetails'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'paymentMethod'.tr(),
            _getPaymentMethodName(context, transaction.paymentMethod!),
          ),
        ],
      ),
    );
  }

  /// Build notes
  Widget _buildNotes(BuildContext context, Transaction transaction) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'description'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            transaction.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context, Transaction transaction) {
    return Row(
      children: [
        // Share button
        Expanded(
          child: CustomButton(
            text: 'share'.tr(),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('shareNotImplemented'.tr()),
                ),
              );
            },
            icon: Icons.share,
            type: ButtonType.secondary,
            textColor: AppTheme.goldDark,
          ),
        ),
        const SizedBox(width: 16),

        // Report issue button (only for completed transactions)
        if (transaction.status == TransactionStatus.completed)
          Expanded(
            child: CustomButton(
              text: 'reportIssue'.tr(),
              onPressed: () {
                // TODO: Implement report issue functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('reportNotImplemented'.tr()),
                  ),
                );
              },
              icon: Icons.report_problem,
              type: ButtonType.secondary,
              textColor: AppTheme.errorColor,
            ),
          ),

        // Cancel button (only for pending transactions)
        if (transaction.status == TransactionStatus.pending)
          Expanded(
            child: CustomButton(
              text: 'cancel'.tr(),
              onPressed: () {
                // TODO: Implement cancel functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('cancelNotImplemented'.tr()),
                  ),
                );
              },
              icon: Icons.cancel,
              type: ButtonType.secondary,
              textColor: AppTheme.errorColor,
            ),
          ),
      ],
    );
  }

  /// Build detail row
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? AppTheme.goldDark : null,
              ),
        ),
      ],
    );
  }

  /// Build status chip
  Widget _buildStatusChip(BuildContext context, TransactionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.color.withAlpha(128),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.translationKey.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Get payment method name
  String _getPaymentMethodName(BuildContext context, String paymentMethod) {
    switch (paymentMethod) {
      case 'wallet':
        return 'walletPayment'.tr();
      case 'bank_transfer':
        return 'bankTransferPayment'.tr();
      case 'card':
        return 'cardPaymentMethod'.tr();
      case 'cash':
        return 'cashPayment'.tr();
      default:
        return paymentMethod;
    }
  }
}
