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

/// Investment confirmation screen
class InvestmentConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> investmentData;

  const InvestmentConfirmationScreen({
    Key? key,
    required this.investmentData,
  }) : super(key: key);

  @override
  State<InvestmentConfirmationScreen> createState() =>
      _InvestmentConfirmationScreenState();
}

class _InvestmentConfirmationScreenState
    extends State<InvestmentConfirmationScreen> {
  bool _isLoading = false;
  bool _hasAcceptedTerms = false;

  /// Create the investment
  Future<void> _createInvestment() async {
    if (!_hasAcceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pleaseAcceptTerms'.tr()),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);

    final success = await investmentProvider.createInvestment(
      planId: widget.investmentData['planId'] as String,
      amount: widget.investmentData['amount'] as double,
      durationMonths: widget.investmentData['duration'] as int,
      isRecurring: widget.investmentData['isRecurring'] as bool,
      recurringDetails: widget.investmentData['recurringDetails']
          as RecurringInvestmentDetails?,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.investmentSuccess,
          arguments: widget.investmentData,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('investmentCreationFailed'.tr()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);
    final plan = investmentProvider
        .getInvestmentPlanById(widget.investmentData['planId'] as String);
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
          'confirmInvestment'.tr(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan summary
            _buildPlanSummary(context, plan),
            const SizedBox(height: 24),

            // Investment details
            _buildInvestmentDetails(context),
            const SizedBox(height: 24),

            // Terms and conditions
            _buildTermsAndConditions(context),
            const SizedBox(height: 32),

            // Confirm button
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
                text: 'confirmInvestment'.tr(),
                onPressed: _isLoading ? () {} : _createInvestment,
                isLoading: _isLoading,
                type: ButtonType.primary,
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: 16),

            // Cancel button
            CustomButton(
              text: 'cancel'.tr(),
              onPressed: _isLoading ? () {} : () => Navigator.pop(context),
              type: ButtonType.secondary,
              textColor: AppTheme.goldDark,
              isFullWidth: true,
            ),
          ],
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

  /// Build investment details
  Widget _buildInvestmentDetails(BuildContext context) {
    final amount = widget.investmentData['amount'] as double;
    final duration = widget.investmentData['duration'] as int;
    final isRecurring = widget.investmentData['isRecurring'] as bool;
    final recurringDetails = widget.investmentData['recurringDetails']
        as RecurringInvestmentDetails?;
    final managementFee = widget.investmentData['managementFee'] as double;
    final expectedReturns = widget.investmentData['expectedReturns'] as double;
    final totalValue = widget.investmentData['totalValue'] as double;

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
              // Initial investment
              _buildDetailRow(
                context: context,
                title: 'initialInvestment'.tr(),
                value: '\$${amount.toStringAsFixed(2)}',
              ),
              const Divider(),

              // Investment duration
              _buildDetailRow(
                context: context,
                title: 'investmentDuration'.tr(),
                value: duration < 12
                    ? '$duration ${'months'.tr()}'
                    : '${duration ~/ 12} ${duration == 12 ? 'year'.tr() : 'years'.tr()}',
              ),

              // Recurring investment (if applicable)
              if (isRecurring && recurringDetails != null) ...[
                const Divider(),
                _buildDetailRow(
                  context: context,
                  title: 'recurringInvestment'.tr(),
                  value:
                      '\$${recurringDetails.amount.toStringAsFixed(2)} ${recurringDetails.frequency.tr()}',
                ),
              ],

              const Divider(),

              // Management fee
              _buildDetailRow(
                context: context,
                title: 'managementFee'.tr(),
                value: '\$${managementFee.toStringAsFixed(2)}',
              ),
              const Divider(),

              // Expected returns
              _buildDetailRow(
                context: context,
                title: 'expectedReturns'.tr(),
                value: '\$${expectedReturns.toStringAsFixed(2)}',
                valueColor: AppTheme.successColor,
              ),
              const Divider(),

              // Total value at maturity
              _buildDetailRow(
                context: context,
                title: 'totalValueAtMaturity'.tr(),
                value: '\$${totalValue.toStringAsFixed(2)}',
                valueColor: AppTheme.goldDark,
                isBold: true,
              ),
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
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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

  /// Build terms and conditions
  Widget _buildTermsAndConditions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'termsAndConditions'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'investmentTermsDescription'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Terms list
                    ...[
                      'investmentTerm1',
                      'investmentTerm2',
                      'investmentTerm3',
                      'investmentTerm4'
                    ]
                        .map((term) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(
                                    child: Text(
                                      term.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            height: 1.5,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),

                    const SizedBox(height: 16),

                    // Accept terms checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _hasAcceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _hasAcceptedTerms = value ?? false;
                            });
                          },
                          activeColor: AppTheme.goldDark,
                        ),
                        Expanded(
                          child: Text(
                            'acceptTerms'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
