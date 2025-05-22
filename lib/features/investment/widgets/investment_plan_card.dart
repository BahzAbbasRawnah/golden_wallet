import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Widget for displaying an investment plan card
class InvestmentPlanCard extends StatelessWidget {
  final InvestmentPlan plan;
  final VoidCallback onTap;

  const InvestmentPlanCard({
    Key? key,
    required this.plan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan type and risk level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Plan frequency
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppTheme.goldDark,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plan.paymentFrequency.translationKey.tr(),
                      style: TextStyle(
                        color: AppTheme.goldDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Risk level
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.riskLevel.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: plan.riskLevel.color,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plan.riskLevel.translationKey.tr(),
                      style: TextStyle(
                        color: plan.riskLevel.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Plan name
          Text(
            plan.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),

          // Plan description
          Text(
            plan.description,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Plan details
          Row(
            children: [
              // Expected returns
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  title: 'expectedReturns'.tr(),
                  value:
                      '${plan.expectedReturns.min}-${plan.expectedReturns.max}%',
                  valueColor: AppTheme.goldDark,
                ),
              ),

              // Min investment
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  title: 'minInvestment'.tr(),
                  value:
                      '${plan.currency} ${plan.minInvestment.toStringAsFixed(0)}',
                ),
              ),

              // Duration
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  title: 'duration'.tr(),
                  value:
                      '${plan.duration.min}-${plan.duration.max} ${plan.duration.unit}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build detail item
  Widget _buildDetailItem({
    required BuildContext context,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[300]
                : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
