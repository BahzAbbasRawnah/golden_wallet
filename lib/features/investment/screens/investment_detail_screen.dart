import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/models/user_investment_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Investment detail screen
class InvestmentDetailScreen extends StatefulWidget {
  final String investmentId;

  const InvestmentDetailScreen({
    Key? key,
    required this.investmentId,
  }) : super(key: key);

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
  Future<void> _withdrawFunds() async {
    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    final investment =
        investmentProvider.getUserInvestmentById(widget.investmentId);

    if (investment == null) return;

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
    final investment =
        investmentProvider.getUserInvestmentById(widget.investmentId);
    final plan = investment != null
        ? investmentProvider.getInvestmentPlanById(investment.planId)
        : null;
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    if (investment == null || plan == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: AppTheme.goldDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text('investmentNotFound'.tr()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plan.name,
          style: TextStyle(
            color: AppTheme.goldDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: AppTheme.goldDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
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
                                  color: AppTheme.primaryColor.withAlpha(70),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomButton(
                              text: 'withdraw'.tr(),
                              onPressed: _withdrawFunds,
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
  }

  /// Build investment summary
  Widget _buildInvestmentSummary(
    BuildContext context,
    UserInvestmentModel investment,
    InvestmentPlanModel plan,
  ) {
    final isActive = investment.status == InvestmentStatus.active;

    return GoldCard(
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  investment.status.translationKey.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Remaining days (if active)
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'daysRemaining'
                        .tr(args: [investment.remainingDays.toString()]),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Current value
          Text(
            '\$${investment.currentValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'currentValue'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
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
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${investment.progressPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: investment.progressPercentage / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${investment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          investment.returnPercentage >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: investment.returnPercentage >= 0
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${investment.returnPercentage >= 0 ? '+' : ''}${investment.returnPercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: investment.returnPercentage >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${investment.profitAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: investment.profitAmount >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
    UserInvestmentModel investment,
    InvestmentPlanModel plan,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'investmentDetails'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              // Plan name
              _buildDetailRow(
                context: context,
                title: 'plan'.tr(),
                value: plan.name,
              ),
              const Divider(),

              // Plan type
              _buildDetailRow(
                context: context,
                title: 'planType'.tr(),
                value: plan.type.translationKey.tr(),
              ),
              const Divider(),

              // Risk level
              _buildDetailRow(
                context: context,
                title: 'riskLevel'.tr(),
                value: plan.riskLevel.translationKey.tr(),
                valueColor: plan.riskLevel.color,
              ),
              const Divider(),

              // Start date
              _buildDetailRow(
                context: context,
                title: 'startDate'.tr(),
                value: DateFormat('MMM dd, yyyy').format(investment.startDate),
              ),
              const Divider(),

              // End date
              _buildDetailRow(
                context: context,
                title: 'endDate'.tr(),
                value: investment.endDate != null
                    ? DateFormat('MMM dd, yyyy').format(investment.endDate!)
                    : DateFormat('MMM dd, yyyy').format(
                        investment.startDate.add(
                            Duration(days: investment.durationMonths * 30)),
                      ),
              ),
              const Divider(),

              // Duration
              _buildDetailRow(
                context: context,
                title: 'duration'.tr(),
                value: investment.durationMonths < 12
                    ? '${investment.durationMonths} ${'months'.tr()}'
                    : '${investment.durationMonths ~/ 12} ${investment.durationMonths == 12 ? 'year'.tr() : 'years'.tr()}',
              ),

              // Recurring investment details (if applicable)
              if (investment.isRecurring &&
                  investment.recurringDetails != null) ...[
                const Divider(),
                _buildDetailRow(
                  context: context,
                  title: 'recurringInvestment'.tr(),
                  value:
                      '${investment.recurringDetails!.frequency.tr()} - \$${investment.recurringDetails!.amount.toStringAsFixed(2)}',
                ),
                const Divider(),
                _buildDetailRow(
                  context: context,
                  title: 'nextInvestmentDate'.tr(),
                  value: DateFormat('MMM dd, yyyy')
                      .format(investment.recurringDetails!.nextInvestmentDate),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build transaction history
  Widget _buildTransactionHistory(
    BuildContext context,
    UserInvestmentModel investment,
  ) {
    // Sort transactions by date (newest first)
    final transactions =
        List<InvestmentTransaction>.from(investment.transactions)
          ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transactionHistory'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              // Table header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'date'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'type'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'amount'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Transaction rows
              ...transactions.map((transaction) {
                final isPositive = transaction.type == 'deposit' ||
                    transaction.type == 'interest';

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Date
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(transaction.date),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                          ),
                        ),
                      ),

                      // Type
                      Expanded(
                        flex: 2,
                        child: Text(
                          'transactionType${transaction.type.capitalize()}'
                              .tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Amount
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPositive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build detail row
  Widget _buildDetailRow({
    required BuildContext context,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for adding funds
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'amount'.tr(),
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'amountRequired'.tr();
                }

                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'invalidAmount'.tr();
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
            if (_formKey.currentState?.validate() ?? false) {
              final amount = double.tryParse(_amountController.text) ?? 0;
              Navigator.pop(context, amount);
            }
          },
          child: Text(
            'add'.tr(),
            style: TextStyle(
              color: AppTheme.goldDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog for withdrawing funds
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
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'amount'.tr(),
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'maxWithdrawal'
                    .tr(args: [widget.maxAmount.toStringAsFixed(2)]),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'amountRequired'.tr();
                }

                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'invalidAmount'.tr();
                }

                if (amount > widget.maxAmount) {
                  return 'amountExceedsBalance'.tr();
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
            if (_formKey.currentState?.validate() ?? false) {
              final amount = double.tryParse(_amountController.text) ?? 0;
              Navigator.pop(context, amount);
            }
          },
          child: Text(
            'withdraw'.tr(),
            style: TextStyle(
              color: AppTheme.goldDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
