import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/deposit_withdraw/models/deposit_withdraw_model.dart';
import 'package:golden_wallet/features/deposit_withdraw/providers/deposit_withdraw_provider.dart';
import 'package:golden_wallet/features/deposit_withdraw/screens/deposit_form_screen.dart';
import 'package:golden_wallet/features/deposit_withdraw/screens/withdraw_form_screen.dart';
import 'package:golden_wallet/features/transactions/models/transaction_model.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Screen for selecting between deposit and withdraw options
class DepositWithdrawSelectionScreen extends StatelessWidget {
  const DepositWithdrawSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final depositWithdrawProvider =
        Provider.of<DepositWithdrawProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('deposit_withdraw'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet balance card
                _buildWalletBalanceCard(context, depositWithdrawProvider),
                const SizedBox(height: 24),

                // Options title
                Text(
                  'select_option'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Deposit option
                _buildOptionCard(
                  context: context,
                  title: 'deposit_funds'.tr(),
                  description: 'deposit_description'.tr(),
                  icon: Icons.arrow_downward,
                  color: AppTheme.successColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DepositFormScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Withdraw option
                _buildOptionCard(
                  context: context,
                  title: 'withdraw_funds'.tr(),
                  description: 'withdraw_description'.tr(),
                  icon: Icons.arrow_upward,
                  color: AppTheme.warningColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WithdrawFormScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent transactions
                _buildRecentTransactions(context, depositWithdrawProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build wallet balance card
  Widget _buildWalletBalanceCard(
      BuildContext context, DepositWithdrawProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(70),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'walletBalance'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '\$${provider.cashBalance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    context: context,
                    title: 'goldBalance'.tr(),
                    value: '${provider.goldBalance.toStringAsFixed(2)} oz',
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceItem(
                    context: context,
                    title: 'cashBalance'.tr(),
                    value: '\$${provider.cashBalance.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build balance item
  Widget _buildBalanceItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51), // 0.2 opacity = 51/255
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(77), // 0.3 opacity = 77/255
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white
                            .withAlpha(204), // 0.8 opacity = 204/255
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build option card
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha(30), // 0.12 opacity
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
            size: 16,
          ),
        ],
      ),
    );
  }

  /// Build recent transactions
  Widget _buildRecentTransactions(
      BuildContext context, DepositWithdrawProvider provider) {
    final transactions = provider.transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recentTransactions'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Show recent transactions or empty state
        transactions.isEmpty
            ? _buildEmptyTransactions(context)
            : Column(
                children: [
                  // Show only the first 3 transactions
                  for (int i = 0; i < transactions.length && i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTransactionItem(context, transactions[i]),
                    ),

                  // View all button
                  if (transactions.length > 3)
                    CustomButton(
                      text: 'viewAllTransactions'.tr(),
                      onPressed: () {
                        Navigator.pushNamed(context, '/transactions');
                      },
                      type: ButtonType.secondary,
                    ),
                ],
              ),
      ],
    );
  }

  /// Build empty transactions state
  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'noTransactionsYet'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'transactionsWillAppearHere'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[500]
                        : Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color based on transaction type
  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return AppTheme.goldColor;
      case TransactionType.sell:
        return AppTheme.accentColor;
      case TransactionType.deposit:
        return AppTheme.successColor;
      case TransactionType.withdraw:
        return AppTheme.warningColor;
      case TransactionType.transfer:
        return AppTheme.infoColor;
      case TransactionType.investment:
        return AppTheme.primaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  /// Get icon based on transaction type
  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.add_circle_outline;
      case TransactionType.sell:
        return Icons.remove_circle_outline;
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdraw:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.investment:
        return Icons.trending_up;
      default:
        return Icons.circle;
    }
  }

  /// Get color based on transaction status
  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return AppTheme.warningColor;
      case TransactionStatus.completed:
        return AppTheme.successColor;
      case TransactionStatus.failed:
        return AppTheme.errorColor;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Get translation key based on transaction status
  String _getStatusTranslationKey(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'pending'.tr();
      case TransactionStatus.completed:
        return 'completed'.tr();
      case TransactionStatus.failed:
        return 'failed'.tr();
      case TransactionStatus.cancelled:
        return 'cancelled'.tr();
    }
  }

  /// Build transaction item
  Widget _buildTransactionItem(
      BuildContext context, DepositWithdrawTransaction transaction) {
    // Get color and icon based on transaction type
    final Color color = _getTransactionColor(transaction.type);
    final IconData icon = _getTransactionIcon(transaction.type);

    // This is a placeholder for transaction items
    // In a real app, we would use the actual transaction data
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type == TransactionType.deposit
                      ? 'depositCash'.tr()
                      : 'withdrawCash'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusTranslationKey(transaction.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(transaction.status),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
