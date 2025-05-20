import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/models/user_investment_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';
import 'package:golden_wallet/shared/widgets/custom_text_field.dart';

/// Investment purchase screen
class InvestmentPurchaseScreen extends StatefulWidget {
  final String planId;

  const InvestmentPurchaseScreen({
    Key? key,
    required this.planId,
  }) : super(key: key);

  @override
  State<InvestmentPurchaseScreen> createState() =>
      _InvestmentPurchaseScreenState();
}

class _InvestmentPurchaseScreenState extends State<InvestmentPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int _selectedDuration = 0;
  bool _isRecurring = false;
  String _recurringFrequency = 'monthly';
  int _recurringDay = 1;
  double _recurringAmount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Initialize values based on the selected plan
  void _initializeValues() {
    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    final plan = investmentProvider.getInvestmentPlanById(widget.planId);

    if (plan != null) {
      _amountController.text = plan.minAmount.toString();
      _selectedDuration = plan.minDurationMonths;
      _recurringAmount = plan.minAmount *
          0.1; // 10% of initial investment as default recurring amount
    }
  }

  /// Calculate management fee
  double _calculateManagementFee() {
    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    final plan = investmentProvider.getInvestmentPlanById(widget.planId);

    if (plan == null || _amountController.text.isEmpty) return 0;

    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount * (plan.managementFeePercentage / 100);
  }

  /// Calculate expected returns
  double _calculateExpectedReturns() {
    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    final plan = investmentProvider.getInvestmentPlanById(widget.planId);

    if (plan == null || _amountController.text.isEmpty) return 0;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final annualReturn = amount * (plan.expectedReturnsPercentage / 100);
    final durationYears = _selectedDuration / 12;

    // Simple interest calculation for demonstration
    return annualReturn * durationYears;
  }

  /// Calculate total value at maturity
  double _calculateTotalValue() {
    if (_amountController.text.isEmpty) return 0;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final expectedReturns = _calculateExpectedReturns();

    return amount + expectedReturns;
  }

  /// Proceed to confirmation
  void _proceedToConfirmation() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text) ?? 0;

      // Create recurring details if selected
      RecurringInvestmentDetails? recurringDetails;
      if (_isRecurring) {
        final now = DateTime.now();
        recurringDetails = RecurringInvestmentDetails(
          frequency: _recurringFrequency,
          day: _recurringDay,
          amount: _recurringAmount,
          nextInvestmentDate: DateTime(now.year, now.month + 1, _recurringDay),
        );
      }

      // Navigate to confirmation screen
      Navigator.pushNamed(
        context,
        AppRoutes.investmentConfirmation,
        arguments: {
          'planId': widget.planId,
          'amount': amount,
          'duration': _selectedDuration,
          'isRecurring': _isRecurring,
          'recurringDetails': recurringDetails,
          'managementFee': _calculateManagementFee(),
          'expectedReturns': _calculateExpectedReturns(),
          'totalValue': _calculateTotalValue(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);
    final plan = investmentProvider.getInvestmentPlanById(widget.planId);
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    if (plan == null) {
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
          child: Text('investmentPlanNotFound'.tr()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'investIn'.tr(args: [plan.name]),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan summary
              _buildPlanSummary(context, plan),
              const SizedBox(height: 24),

              // Investment amount
              _buildInvestmentAmount(context, plan),
              const SizedBox(height: 24),

              // Investment duration
              _buildInvestmentDuration(context, plan),
              const SizedBox(height: 24),

              // Recurring investment option
              _buildRecurringInvestment(context, plan),
              const SizedBox(height: 24),

              // Investment summary
              _buildInvestmentSummary(context, plan),
              const SizedBox(height: 32),

              // Continue button
              Container(
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
                  text: 'continueToConfirmation'.tr(),
                  onPressed: _isLoading ? () {} : _proceedToConfirmation,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  backgroundColor: Colors.transparent,
                  textColor: Colors.white,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build plan summary
  Widget _buildPlanSummary(BuildContext context, InvestmentPlanModel plan) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name and type
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  plan.type.icon,
                  color: AppTheme.goldDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.type.translationKey.tr(),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expected returns and risk level
          Row(
            children: [
              // Expected returns
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'expectedReturns'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.expectedReturnsPercentage}% ${'perAnnum'.tr()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Risk level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'riskLevel'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: plan.riskLevel.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          plan.riskLevel.translationKey.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: plan.riskLevel.color,
                          ),
                        ),
                      ],
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

  /// Build investment amount section
  Widget _buildInvestmentAmount(
      BuildContext context, InvestmentPlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'investmentAmount'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _amountController,
          label: 'amount'.tr(),
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'amountRequired'.tr();
            }

            final amount = double.tryParse(value);
            if (amount == null) {
              return 'invalidAmount'.tr();
            }

            if (amount < plan.minAmount) {
              return 'amountTooLow'.tr(args: [plan.minAmount.toString()]);
            }

            if (plan.maxAmount != null && amount > plan.maxAmount!) {
              return 'amountTooHigh'.tr(args: [plan.maxAmount.toString()]);
            }

            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${'minAmount'.tr()}: \$${plan.minAmount.toStringAsFixed(2)}${plan.maxAmount != null ? ' • ${'maxAmount'.tr()}: \$${plan.maxAmount!.toStringAsFixed(2)}' : ''}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[300]
                : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // Quick amount buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickAmountButton(context, plan.minAmount),
            _buildQuickAmountButton(context, plan.minAmount * 2),
            _buildQuickAmountButton(context, plan.minAmount * 5),
            if (plan.maxAmount != null)
              _buildQuickAmountButton(context, plan.maxAmount!),
          ],
        ),
      ],
    );
  }

  /// Build quick amount button
  Widget _buildQuickAmountButton(BuildContext context, double amount) {
    return InkWell(
      onTap: () {
        setState(() {
          _amountController.text = amount.toString();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.goldColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: AppTheme.goldDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Build investment duration section
  Widget _buildInvestmentDuration(
      BuildContext context, InvestmentPlanModel plan) {
    // Generate duration options
    final durationOptions = <int>[];
    for (int i = plan.minDurationMonths;
        i <= (plan.maxDurationMonths ?? plan.minDurationMonths * 5);
        i += 12) {
      durationOptions.add(i);
    }

    // If no options were added (e.g., min duration is already high), add at least the min duration
    if (durationOptions.isEmpty) {
      durationOptions.add(plan.minDurationMonths);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'investmentDuration'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'selectDuration'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                ),
              ),
              const Divider(),

              // Duration options
              ...durationOptions.map((duration) {
                final isSelected = _selectedDuration == duration;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          duration < 12
                              ? '$duration ${'months'.tr()}'
                              : '${duration ~/ 12} ${duration == 12 ? 'year'.tr() : 'years'.tr()}',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.goldDark,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build recurring investment section
  Widget _buildRecurringInvestment(
      BuildContext context, InvestmentPlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recurringInvestment'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              // Toggle switch
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'setupRecurringInvestment'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                        });
                      },
                      activeColor: AppTheme.goldDark,
                      activeTrackColor: AppTheme.goldColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              // Recurring investment options (only shown if recurring is enabled)
              if (_isRecurring) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frequency selection
                      Text(
                        'frequency'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _recurringFrequency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'monthly',
                            child: Text('monthly'.tr()),
                          ),
                          DropdownMenuItem(
                            value: 'quarterly',
                            child: Text('quarterly'.tr()),
                          ),
                          DropdownMenuItem(
                            value: 'yearly',
                            child: Text('yearly'.tr()),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _recurringFrequency = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Day selection
                      Text(
                        'dayOfMonth'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _recurringDay,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items:
                            List.generate(28, (index) => index + 1).map((day) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text(day.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _recurringDay = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount selection
                      Text(
                        'recurringAmount'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _recurringAmount.toString(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _recurringAmount = double.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          if (_isRecurring) {
                            if (value == null || value.isEmpty) {
                              return 'amountRequired'.tr();
                            }

                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'invalidAmount'.tr();
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build investment summary section
  Widget _buildInvestmentSummary(
      BuildContext context, InvestmentPlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'investmentSummary'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              // Initial investment
              _buildSummaryRow(
                context: context,
                title: 'initialInvestment'.tr(),
                value:
                    '\$${_amountController.text.isEmpty ? '0.00' : double.tryParse(_amountController.text)?.toStringAsFixed(2) ?? '0.00'}',
              ),
              const Divider(),

              // Management fee
              _buildSummaryRow(
                context: context,
                title: 'managementFee'.tr(),
                value: '\$${_calculateManagementFee().toStringAsFixed(2)}',
                subtitle:
                    '${plan.managementFeePercentage}% ${'ofInvestment'.tr()}',
              ),
              const Divider(),

              // Expected returns
              _buildSummaryRow(
                context: context,
                title: 'expectedReturns'.tr(),
                value: '\$${_calculateExpectedReturns().toStringAsFixed(2)}',
                valueColor: AppTheme.successColor,
                subtitle:
                    '${plan.expectedReturnsPercentage}% ${'perAnnum'.tr()} × ${_selectedDuration / 12} ${'years'.tr()}',
              ),
              const Divider(),

              // Total value at maturity
              _buildSummaryRow(
                context: context,
                title: 'totalValueAtMaturity'.tr(),
                value: '\$${_calculateTotalValue().toStringAsFixed(2)}',
                valueColor: AppTheme.goldDark,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build summary row
  Widget _buildSummaryRow({
    required BuildContext context,
    required String title,
    required String value,
    String? subtitle,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                  ),
                ),
            ],
          ),

          // Value
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
