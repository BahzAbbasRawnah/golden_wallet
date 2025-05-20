import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/models/user_investment_model.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Widget for displaying a user investment card
class UserInvestmentCard extends StatelessWidget {
  final UserInvestmentModel investment;
  final InvestmentPlanModel? plan;
  final VoidCallback onTap;
  
  const UserInvestmentCard({
    Key? key,
    required this.investment,
    required this.plan,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isActive = investment.status == InvestmentStatus.active;
    
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Plan name
              Text(
                plan?.name ?? 'unknownPlan'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(investment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  investment.status.translationKey.tr(),
                  style: TextStyle(
                    color: _getStatusColor(investment.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Investment amount and current value
          Row(
            children: [
              // Investment amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'investmentAmount'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${investment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Current value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'currentValue'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${investment.currentValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: investment.profitAmount >= 0
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
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
                      'return'.tr(),
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
                        Icon(
                          investment.returnPercentage >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: investment.returnPercentage >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${investment.returnPercentage >= 0 ? '+' : ''}${investment.returnPercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: investment.returnPercentage >= 0
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Progress bar (if active)
          if (isActive) ...[
            const SizedBox(height: 16),
            
            // Progress percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'progress'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${investment.progressPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
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
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
                minHeight: 8,
              ),
            ),
          ],
          
          // Recurring indicator (if applicable)
          if (investment.isRecurring && investment.recurringDetails != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'recurringInvestment'.tr(args: [
                    investment.recurringDetails!.frequency.tr(),
                    '\$${investment.recurringDetails!.amount.toStringAsFixed(2)}',
                  ]),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  /// Get color for investment status
  Color _getStatusColor(InvestmentStatus status) {
    switch (status) {
      case InvestmentStatus.active:
        return AppTheme.successColor;
      case InvestmentStatus.completed:
        return AppTheme.goldDark;
      case InvestmentStatus.cancelled:
        return AppTheme.errorColor;
      case InvestmentStatus.pending:
        return AppTheme.warningColor;
    }
  }
}
