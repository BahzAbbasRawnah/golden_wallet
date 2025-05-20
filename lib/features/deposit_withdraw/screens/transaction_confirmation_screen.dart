import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/deposit_withdraw/models/deposit_withdraw_model.dart';
import 'package:golden_wallet/features/deposit_withdraw/providers/deposit_withdraw_provider.dart';
import 'package:golden_wallet/features/deposit_withdraw/screens/transaction_result_screen.dart';
import 'package:golden_wallet/features/deposit_withdraw/utils/formatting_utils.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/features/transactions/providers/transaction_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Screen for confirming deposit/withdraw transaction
class TransactionConfirmationScreen extends StatefulWidget {
  const TransactionConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<TransactionConfirmationScreen> createState() =>
      _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState
    extends State<TransactionConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final depositWithdrawProvider =
        Provider.of<DepositWithdrawProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
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

    return Scaffold(
      appBar: AppBar(
        title: Text('ConfirmTransaction'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction summary card
                _buildTransactionSummaryCard(context, transaction),
                const SizedBox(height: 24),

                // Transaction details
                Text(
                  'TransactionDetails'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Transaction details card
                _buildTransactionDetailsCard(context, transaction),
                const SizedBox(height: 24),

                // Payment method details
                Text(
                  'PaymentMethodDetails'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Payment method details card
                _buildPaymentMethodDetailsCard(context, transaction),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'cancel'.tr(),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'confirm'.tr(),
                        onPressed: () async {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text('ProcessingTransaction'.tr()),
                                ],
                              ),
                            ),
                          );

                          // Process transaction
                          try {
                            final success = await depositWithdrawProvider
                                .processTransaction(
                              transactionProvider,
                            );

                            if (mounted) {
                              // Close loading dialog
                              Navigator.of(context).pop();

                              // Navigate to result screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionResultScreen(
                                    success: success,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              // Close loading dialog
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        type: ButtonType.primary,
                        isLoading: depositWithdrawProvider.isLoading,
                      ),
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

  /// Build transaction summary card
  Widget _buildTransactionSummaryCard(
    BuildContext context,
    DepositWithdrawTransaction transaction,
  ) {
    final isDeposit = transaction.type == TransactionType.deposit;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Transaction type icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: transaction.type.color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                transaction.type.icon,
                color: transaction.type.color,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Transaction type
          Text(
            transaction.type.translationKey.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Transaction amount
          Text(
            DepositWithdrawFormattingUtils.formatCurrency(transaction.amount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.type.color,
                ),
          ),
          const SizedBox(height: 24),

          // Transaction fee
          _buildSummaryRow(
            context: context,
            label: 'TransactionFee'.tr(),
            value:
                DepositWithdrawFormattingUtils.formatCurrency(transaction.fee),
          ),
          const SizedBox(height: 12),

          // Total amount
          _buildSummaryRow(
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

  /// Build summary row
  Widget _buildSummaryRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }

  /// Build transaction details card
  Widget _buildTransactionDetailsCard(
    BuildContext context,
    DepositWithdrawTransaction transaction,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Transaction ID
          _buildDetailRow(
            context: context,
            label: 'TransactionId'.tr(),
            value: transaction.id,
          ),
          const Divider(),

          // Transaction date
          _buildDetailRow(
            context: context,
            label: 'TransactionDate'.tr(),
            value:
                DepositWithdrawFormattingUtils.formatDateTime(transaction.date),
          ),
          const Divider(),

          // Transaction status
          _buildDetailRow(
            context: context,
            label: 'TransactionStatus'.tr(),
            value: transaction.status.translationKey.tr(),
            valueColor: transaction.status.color,
          ),

          // Notes (if any)
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const Divider(),
            _buildDetailRow(
              context: context,
              label: 'notes'.tr(),
              value: transaction.notes!,
            ),
          ],
        ],
      ),
    );
  }

  /// Build payment method details card
  Widget _buildPaymentMethodDetailsCard(
    BuildContext context,
    DepositWithdrawTransaction transaction,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Payment method
          _buildDetailRow(
            context: context,
            label: 'PaymentMethod'.tr(),
            value: transaction.method.translationKey.tr(),
          ),

          // Method-specific details
          if (transaction.method == DepositWithdrawMethod.bankTransfer &&
              transaction.bankDetails != null) ...[
            const Divider(),
            _buildBankDetails(context, transaction.bankDetails!),
          ] else if (transaction.method == DepositWithdrawMethod.cardPayment &&
              transaction.cardDetails != null) ...[
            const Divider(),
            _buildCardDetails(context, transaction.cardDetails!),
          ],

          // Reference number (if any)
          if (transaction.reference != null &&
              transaction.reference!.isNotEmpty) ...[
            const Divider(),
            _buildDetailRow(
              context: context,
              label: 'transactionReference'.tr(),
              value: transaction.reference!,
            ),
          ],
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bank details
  Widget _buildBankDetails(BuildContext context, BankAccountDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          context: context,
          label: 'bankName'.tr(),
          value: details.bankName,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context: context,
          label: 'accountNumber'.tr(),
          value: details.accountNumber,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context: context,
          label: 'accountHolderName'.tr(),
          value: details.accountHolderName,
        ),
        if (details.swiftCode != null && details.swiftCode!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            context: context,
            label: 'swiftCode'.tr(),
            value: details.swiftCode!,
          ),
        ],
        if (details.iban != null && details.iban!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            context: context,
            label: 'iban'.tr(),
            value: details.iban!,
          ),
        ],
      ],
    );
  }

  /// Build card details
  Widget _buildCardDetails(BuildContext context, CardDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          context: context,
          label: 'cardNumber'.tr(),
          value: DepositWithdrawFormattingUtils.formatCardNumber(
              details.cardNumber),
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context: context,
          label: 'cardHolderName'.tr(),
          value: details.cardHolderName,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context: context,
          label: 'expiryDate'.tr(),
          value: details.expiryDate,
        ),
      ],
    );
  }
}
