import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan.dart';
import 'package:golden_wallet/features/investment/models/investment_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Investment detail screen
class InvestmentDetailScreen extends StatefulWidget {
  final String investmentId;

  const InvestmentDetailScreen({
    super.key,
    required this.investmentId,
  });

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  bool _isLoading = false;

  /// Add funds to the investment
  Future<void> _addFunds() async {
    // Show dialog to enter amount
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => _AddFundsDialog(),
    );

    if (amount == null || amount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    final success = await investmentProvider.addFunds(
      investmentId: widget.investmentId,
      amount: amount,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'fundsAddedSuccessfully'.tr() : 'failedToAddFunds'.tr(),
          ),
          backgroundColor:
              success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  /// Withdraw funds from the investment
  Future<void> _withdrawFunds(Investment investment) async {
    // Show dialog to enter amount
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => _WithdrawFundsDialog(
        maxAmount: investment.currentValue,
      ),
    );

    if (amount == null || amount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    final success = await investmentProvider.withdrawFunds(
      investmentId: widget.investmentId,
      amount: amount,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'fundsWithdrawnSuccessfully'.tr()
                : 'failedToWithdrawFunds'.tr(),
          ),
          backgroundColor:
              success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  /// Cancel the investment
  Future<void> _cancelInvestment() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cancelInvestment'.tr()),
        content: Text('cancelInvestmentConfirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'no'.tr(),
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'yes'.tr(),
              style: TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    final success =
        await investmentProvider.cancelInvestment(widget.investmentId);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'investmentCancelledSuccessfully'.tr()
                : 'failedToCancelInvestment'.tr(),
          ),
          backgroundColor:
              success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);

    return FutureBuilder<Investment?>(
      future: investmentProvider.getUserInvestmentById(widget.investmentId),
      builder: (context, investmentSnapshot) {
        if (investmentSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'investment'.tr(),
              showBackButton: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
              ),
            ),
          );
        }

        final investment = investmentSnapshot.data;

        if (investment == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'investmentNotFound'.tr(),
              showBackButton: true,
            ),
            body: Center(
              child: Text('investmentNotFound'.tr()),
            ),
          );
        }

        return FutureBuilder<InvestmentPlan?>(
          future: investmentProvider.getInvestmentPlanById(investment.planId),
          builder: (context, planSnapshot) {
            if (planSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: CustomAppBar(
                  title: 'investment'.tr(),
                  showBackButton: true,
                ),
                body: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
                  ),
                ),
              );
            }

            final plan = planSnapshot.data;

            if (plan == null) {
              return Scaffold(
                appBar: CustomAppBar(
                  title: 'investmentNotFound'.tr(),
                  showBackButton: true,
                ),
                body: Center(
                  child: Text('investmentPlanNotFound'.tr()),
                ),
              );
            }

            return Scaffold(
              appBar: CustomAppBar(
                title: plan.name,
                showBackButton: true,
              ),
              body: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Investment summary
                          _buildInvestmentSummary(context, investment, plan),
                          const SizedBox(height: 24),

                          // Investment details
                          _buildInvestmentDetails(context, investment, plan),
                          const SizedBox(height: 24),

                          // Transaction history
                          _buildTransactionHistory(context, investment),
                          const SizedBox(height: 24),

                          // Action buttons
                          if (investment.status == InvestmentStatus.active) ...[
                            Row(
                              children: [
                                // Add funds button
                                Expanded(
                                  child: CustomButton(
                                    text: 'addFunds'.tr(),
                                    onPressed: _addFunds,
                                    icon: Icons.add,
                                    type: ButtonType.secondary,
                                    textColor: AppTheme.goldDark,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Withdraw funds button
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.goldGradient,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withAlpha(70),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CustomButton(
                                      text: 'withdraw'.tr(),
                                      onPressed: () =>
                                          _withdrawFunds(investment),
                                      icon: Icons.arrow_downward,
                                      type: ButtonType.primary,
                                      backgroundColor: Colors.transparent,
                                      textColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Cancel investment button
                            CustomButton(
                              text: 'cancelInvestment'.tr(),
                              onPressed: _cancelInvestment,
                              icon: Icons.cancel,
                              type: ButtonType.text,
                              textColor: AppTheme.errorColor,
                              isFullWidth: true,
                            ),
                          ],
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  /// Build investment summary
  Widget _buildInvestmentSummary(
    BuildContext context,
    Investment investment,
    InvestmentPlan plan,
  ) {
    final theme = Theme.of(context);
    final isActive = investment.status == InvestmentStatus.active;
    final returnRate = investment.returnRate;
    final profitAmount = investment.currentValue - investment.initialInvestment;
    final isDark = theme.brightness == Brightness.dark;

    return CustomCard(
      gradient: AppTheme.investmentGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Investment status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x33FFFFFF) // White with 20% opacity
                      : const Color(0x1A000000), // Black with 10% opacity
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  investment.status.translationKey.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Remaining days (if active)
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x33FFFFFF) // White with 20% opacity
                        : const Color(0x1A000000), // Black with 10% opacity
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'daysRemaining'.tr(
                        args: [_calculateRemainingDays(investment).toString()]),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Current value
          Text(
            '${investment.currency} ${investment.currentValue.toStringAsFixed(2)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'currentValue'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? const Color(0xCCFFFFFF) // White with 80% opacity
                  : const Color(0xCC000000), // Black with 80% opacity
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar (if active)
          if (isActive) ...[
            // Progress percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'progress'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? const Color(0xCCFFFFFF) // White with 80% opacity
                        : const Color(0xCC000000), // Black with 80% opacity
                  ),
                ),
                Text(
                  '${_calculateProgressPercentage(investment).toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _calculateProgressValue(investment),
                backgroundColor: isDark
                    ? const Color(0x33FFFFFF) // White with 20% opacity
                    : const Color(0x1A000000), // Black with 10% opacity
                valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white : AppTheme.goldDark),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Investment stats
          Row(
            children: [
              // Initial investment
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'initialInvestment'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xCCFFFFFF) // White with 80% opacity
                            : const Color(0xCC000000), // Black with 80% opacity
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${investment.currency} ${investment.initialInvestment.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Return percentage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'returnPercentage'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xCCFFFFFF) // White with 80% opacity
                            : const Color(0xCC000000), // Black with 80% opacity
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          returnRate >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: returnRate >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${returnRate >= 0 ? '+' : ''}${returnRate.toStringAsFixed(2)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: returnRate >= 0
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Profit amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profit'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xCCFFFFFF) // White with 80% opacity
                            : const Color(0xCC000000), // Black with 80% opacity
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${investment.currency} ${profitAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: profitAmount >= 0
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build investment details
  Widget _buildInvestmentDetails(
    BuildContext context,
    Investment investment,
    InvestmentPlan plan,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'investmentDetails'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Plan details
          _buildDetailRow(
            context,
            'planName'.tr(),
            plan.name,
          ),
          _buildDetailRow(
            context,
            'planType'.tr(),
            plan.paymentFrequency.translationKey.tr(),
          ),
          _buildDetailRow(
            context,
            'riskLevel'.tr(),
            plan.riskLevel.translationKey.tr(),
          ),
          _buildDetailRow(
            context,
            'expectedReturn'.tr(),
            '${plan.expectedReturns.min}% - ${plan.expectedReturns.max}%',
          ),

          // Investment details
          _buildDetailRow(
            context,
            'startDate'.tr(),
            _formatDate(investment.startDate),
          ),
          _buildDetailRow(
            context,
            'endDate'.tr(),
            _formatDate(investment.endDate),
          ),
          _buildDetailRow(
            context,
            'duration'.tr(),
            'months'
                .tr(args: [_calculateDurationMonths(investment).toString()]),
          ),
          _buildDetailRow(
            context,
            'paymentFrequency'.tr(),
            plan.paymentFrequency.translationKey.tr(),
          ),
        ],
      ),
    );
  }

  /// Build transaction history
  Widget _buildTransactionHistory(
    BuildContext context,
    Investment investment,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'transactionHistory'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Initial investment transaction
          _buildTransactionItem(
            context,
            'initialInvestment'.tr(),
            investment.startDate,
            investment.initialInvestment,
            TransactionType.deposit,
          ),

          // Sample transactions (in a real app, these would come from the API)
          if (investment.status == InvestmentStatus.active) ...[
            _buildTransactionItem(
              context,
              'interestPayment'.tr(),
              DateTime.now().subtract(const Duration(days: 30)),
              investment.initialInvestment * 0.05,
              TransactionType.interest,
            ),
            _buildTransactionItem(
              context,
              'additionalDeposit'.tr(),
              DateTime.now().subtract(const Duration(days: 15)),
              500,
              TransactionType.deposit,
            ),
          ],

          // Completed investment transaction
          if (investment.status == InvestmentStatus.completed)
            _buildTransactionItem(
              context,
              'investmentMatured'.tr(),
              investment.endDate,
              investment.currentValue,
              TransactionType.withdrawal,
            ),

          // Cancelled investment transaction
          if (investment.status == InvestmentStatus.cancelled)
            _buildTransactionItem(
              context,
              'investmentCancelled'.tr(),
              DateTime.now().subtract(const Duration(days: 7)),
              investment.currentValue,
              TransactionType.withdrawal,
            ),
        ],
      ),
    );
  }

  /// Build a detail row
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a transaction item
  Widget _buildTransactionItem(
    BuildContext context,
    String description,
    DateTime date,
    double amount,
    TransactionType type,
  ) {
    final isPositive =
        type == TransactionType.interest || type == TransactionType.deposit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withAlpha(51)
                  : Colors.red.withAlpha(51),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              type == TransactionType.interest
                  ? Icons.attach_money
                  : type == TransactionType.deposit
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
              color: isPositive ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    color: Colors.white.withAlpha(153),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Transaction amount
          Text(
            '${isPositive ? '+' : '-'} \$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate remaining days
  int _calculateRemainingDays(Investment investment) {
    final now = DateTime.now();
    final difference = investment.endDate.difference(now);
    return difference.inDays < 0 ? 0 : difference.inDays;
  }

  /// Calculate progress percentage
  double _calculateProgressPercentage(Investment investment) {
    final totalDays =
        investment.endDate.difference(investment.startDate).inDays;
    final elapsedDays = DateTime.now().difference(investment.startDate).inDays;

    if (elapsedDays <= 0) return 0;
    if (elapsedDays >= totalDays) return 100;

    return (elapsedDays / totalDays) * 100;
  }

  /// Calculate progress value (0.0 to 1.0)
  double _calculateProgressValue(Investment investment) {
    return _calculateProgressPercentage(investment) / 100;
  }

  /// Format date
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Calculate duration in months
  int _calculateDurationMonths(Investment investment) {
    final months = (investment.endDate.year - investment.startDate.year) * 12 +
        investment.endDate.month -
        investment.startDate.month;
    return months <= 0 ? 1 : months;
  }
}

/// Transaction type enum
enum TransactionType {
  deposit,
  withdrawal,
  interest,
}

/// Add funds dialog
class _AddFundsDialog extends StatefulWidget {
  @override
  State<_AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<_AddFundsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('addFunds'.tr()),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'amount'.tr(),
            prefixText: '\$ ',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'pleaseEnterAmount'.tr();
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'pleaseEnterValidAmount'.tr();
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'cancel'.tr(),
            style: TextStyle(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              Navigator.pop(context, amount);
            }
          },
          child: Text(
            'add'.tr(),
            style: TextStyle(
              color: AppTheme.goldDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Withdraw funds dialog
class _WithdrawFundsDialog extends StatefulWidget {
  final double maxAmount;

  const _WithdrawFundsDialog({
    required this.maxAmount,
  });

  @override
  State<_WithdrawFundsDialog> createState() => _WithdrawFundsDialogState();
}

class _WithdrawFundsDialogState extends State<_WithdrawFundsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('withdrawFunds'.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'availableBalance'
                  .tr(args: ['\$${widget.maxAmount.toStringAsFixed(2)}']),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'amount'.tr(),
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'pleaseEnterAmount'.tr();
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'pleaseEnterValidAmount'.tr();
                }
                if (amount > widget.maxAmount) {
                  return 'insufficientBalance'.tr();
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'cancel'.tr(),
            style: TextStyle(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              Navigator.pop(context, amount);
            }
          },
          child: Text(
            'withdraw'.tr(),
            style: TextStyle(
              color: AppTheme.goldDark,
            ),
          ),
        ),
      ],
    );
  }
}
