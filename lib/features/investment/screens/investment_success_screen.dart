import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';

/// Investment success screen
class InvestmentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> investmentData;
  
  const InvestmentSuccessScreen({
    Key? key,
    required this.investmentData,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);
    final plan = investmentProvider.getInvestmentPlanById(investmentData['planId'] as String);
    final amount = investmentData['amount'] as double;
    final totalValue = investmentData['totalValue'] as double;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Success animation
              Lottie.asset(
                'assets/animations/success.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 32),
              
              // Success title
              Text(
                'investmentSuccessful'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldDark,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Success message
              Text(
                'investmentSuccessMessage'.tr(args: [
                  '\$${amount.toStringAsFixed(2)}',
                  plan?.name ?? '',
                ]),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Investment details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Investment amount
                    _buildDetailRow(
                      context: context,
                      title: 'investmentAmount'.tr(),
                      value: '\$${amount.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    
                    // Expected value at maturity
                    _buildDetailRow(
                      context: context,
                      title: 'expectedValueAtMaturity'.tr(),
                      value: '\$${totalValue.toStringAsFixed(2)}',
                      valueColor: AppTheme.goldDark,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // View investment button
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
                  text: 'viewMyInvestments'.tr(),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.investmentManagement,
                      (route) => route.settings.name == AppRoutes.investment,
                    );
                  },
                  type: ButtonType.primary,
                  backgroundColor: Colors.transparent,
                  textColor: Colors.white,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(height: 16),
              
              // Back to dashboard button
              CustomButton(
                text: 'backToDashboard'.tr(),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.investment,
                    (route) => false,
                  );
                },
                type: ButtonType.secondary,
                textColor: AppTheme.goldDark,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
}
