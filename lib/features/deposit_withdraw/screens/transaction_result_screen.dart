import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/deposit_withdraw/models/deposit_withdraw_model.dart';
import 'package:golden_wallet/features/deposit_withdraw/providers/deposit_withdraw_provider.dart';
import 'package:golden_wallet/features/deposit_withdraw/utils/formatting_utils.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Screen for showing transaction result (success or failure)
class TransactionResultScreen extends StatelessWidget {
  final bool success;

  const TransactionResultScreen({
    Key? key,
    required this.success,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final depositWithdrawProvider =
        Provider.of<DepositWithdrawProvider>(context);
    final transaction = depositWithdrawProvider.currentTransaction;

    // If no transaction is available, show error
    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('error'.tr()),
          centerTitle: true,
        ),
        body: Center(
          child: Text('NoTransactionData'.tr()),
        ),
      );
    }

    final isDeposit = transaction.type == TransactionType.deposit;

    return Scaffold(
      appBar: AppBar(
        title: Text(success ? 'success'.tr() : 'failed'.tr()),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Result icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: success
                        ? AppTheme.successColor.withAlpha(30)
                        : AppTheme.errorColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      success ? Icons.check_circle : Icons.error,
                      color:
                          success ? AppTheme.successColor : AppTheme.errorColor,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Result title
                Text(
                  success
                      ? (isDeposit
                          ? 'DepositSuccess'.tr()
                          : 'WithdrawalSuccess'.tr())
                      : (isDeposit
                          ? 'DepositFailed'.tr()
                          : 'WithdrawalFailed'.tr()),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: success
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Result message
                Text(
                  success
                      ? (isDeposit
                          ? 'DepositSuccessMessage'.tr()
                          : 'WithdrawalSuccessMessage'.tr())
                      : (isDeposit
                          ? 'DepositFailedMessage'.tr()
                          : 'WithdrawalFailedMessage'.tr()),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Transaction details card
                if (success) _buildTransactionDetailsCard(context, transaction),
                if (!success && depositWithdrawProvider.error != null)
                  _buildErrorCard(context, depositWithdrawProvider.error!),

                const SizedBox(height: 32),

                // Buttons
                Column(
                  children: [
                    CustomButton(
                      text:
                          success ? 'ViewTransaction'.tr() : 'TryAgain'.tr(),
                      onPressed: () {
                        if (success) {
                          // Navigate to transaction details
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.transactions,
                            (route) => false,
                          );
                        } else {
                          // Go back to retry
                          Navigator.pop(context);
                        }
                      },
                      type: ButtonType.primary,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'BackToHome'.tr(),
                      onPressed: () {
                        // Clear current transaction
                        depositWithdrawProvider.clearCurrentTransaction();

                        // Navigate to dashboard
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.dashboard,
                          (route) => false,
                        );
                      },
                      type: ButtonType.secondary,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build transaction details card
  Widget _buildTransactionDetailsCard(
    BuildContext context,
    DepositWithdrawTransaction transaction,
  ) {
    final isDeposit = transaction.type == TransactionType.deposit;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Transaction amount
          Text(
            DepositWithdrawFormattingUtils.formatCurrency(transaction.amount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Transaction type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              transaction.type == TransactionType.deposit
                  ? 'depositCash'.tr()
                  : 'withdrawCash'.tr(),
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Transaction details
          _buildDetailRow(
            context: context,
            label: 'TransactionId'.tr(),
            value: transaction.id,
          ),
          const Divider(),

          _buildDetailRow(
            context: context,
            label: 'date'.tr(),
            value:
                DepositWithdrawFormattingUtils.formatDateTime(transaction.date),
          ),
          const Divider(),

          _buildDetailRow(
            context: context,
            label: 'PaymentMethod'.tr(),
            value: _getMethodTranslationKey(transaction.method),
          ),
          const Divider(),

          _buildDetailRow(
            context: context,
            label: 'TransactionFee'.tr(),
            value:
                DepositWithdrawFormattingUtils.formatCurrency(transaction.fee),
          ),
          const Divider(),

          _buildDetailRow(
            context: context,
            label: isDeposit ? 'ReceivableAmount'.tr() : 'PayableAmount'.tr(),
            value: DepositWithdrawFormattingUtils.formatCurrency(
                transaction.total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  /// Build error card
  Widget _buildErrorCard(BuildContext context, String error) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'ErrorDetails'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get translation key for payment method
  String _getMethodTranslationKey(DepositWithdrawMethod method) {
    switch (method) {
      case DepositWithdrawMethod.bankTransfer:
        return 'BankTransfer'.tr();
      case DepositWithdrawMethod.cardPayment:
        return 'CardPayment'.tr();
      case DepositWithdrawMethod.cash:
        return 'Cash'.tr();
      case DepositWithdrawMethod.physicalGold:
        return 'PhysicalGold'.tr();
    }
  }

  /// Build detail row
  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
