import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan.dart';
import 'package:golden_wallet/features/investment/models/investment_model.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Widget for displaying a user investment card
class UserInvestmentCard extends StatelessWidget {
  final Investment investment;
  final InvestmentPlan? plan;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(investment.status).withAlpha(25),
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
                      '${investment.currency} ${investment.initialInvestment.toStringAsFixed(2)}',
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
                      '${investment.currency} ${investment.currentValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (investment.currentValue -
                                    investment.initialInvestment) >=
                                0
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
                          investment.returnRate >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: investment.returnRate >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${investment.returnRate >= 0 ? '+' : ''}${investment.returnRate.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: investment.returnRate >= 0
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
                  // Calculate progress based on start and end dates
                  _calculateProgressPercentage(investment),
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
                value: _calculateProgressValue(investment),
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
                minHeight: 8,
              ),
            ),
          ],

          // We'll implement recurring investments in a future update
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

  /// Calculate progress percentage as a string
  String _calculateProgressPercentage(Investment investment) {
    if (investment.status == InvestmentStatus.completed) return '100.0%';
    if (investment.status == InvestmentStatus.cancelled) return '0.0%';

    final now = DateTime.now();
    final totalDuration =
        investment.endDate.difference(investment.startDate).inMilliseconds;
    final elapsedDuration = now.difference(investment.startDate).inMilliseconds;

    final progress = (elapsedDuration / totalDuration) * 100;
    return '${progress.clamp(0.0, 100.0).toStringAsFixed(1)}%';
  }

  /// Calculate progress value for the progress bar
  double _calculateProgressValue(Investment investment) {
    if (investment.status == InvestmentStatus.completed) return 1.0;
    if (investment.status == InvestmentStatus.cancelled) return 0.0;

    final now = DateTime.now();
    final totalDuration =
        investment.endDate.difference(investment.startDate).inMilliseconds;
    final elapsedDuration = now.difference(investment.startDate).inMilliseconds;

    final progress = elapsedDuration / totalDuration;
    return progress.clamp(0.0, 1.0);
  }
}
