import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Investment plan detail screen
class InvestmentPlanDetailScreen extends StatelessWidget {
  final String planId;

  const InvestmentPlanDetailScreen({
    Key? key,
    required this.planId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);
    final plan = investmentProvider.getInvestmentPlanById(planId);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan header
            _buildPlanHeader(context, plan),
            const SizedBox(height: 24),

            // Plan description
            _buildPlanDescription(context, plan),
            const SizedBox(height: 24),

            // Plan details
            _buildPlanDetails(context, plan),
            const SizedBox(height: 24),

            // Historical performance
            _buildHistoricalPerformance(context, plan),
            const SizedBox(height: 32),

            // Invest button
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
                text: 'investNow'.tr(),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.investmentPurchase,
                    arguments: planId,
                  );
                },
                type: ButtonType.primary,
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build plan header
  Widget _buildPlanHeader(BuildContext context, InvestmentPlanModel plan) {
    return GoldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan type and risk level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Plan type
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      plan.type.icon,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plan.type.translationKey.tr(),
                      style: const TextStyle(
                        color: Colors.white,
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
                  color: plan.riskLevel.color.withOpacity(0.2),
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

          // Expected returns
          Text(
            '${plan.expectedReturnsPercentage}%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'expectedAnnualReturns'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Min investment and duration
          Row(
            children: [
              // Min investment
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'minInvestment'.tr(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${plan.minAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Min duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'minDuration'.tr(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.minDurationMonths} ${plan.minDurationMonths == 1 ? 'month'.tr() : 'months'.tr()}',
                      style: const TextStyle(
                        color: Colors.white,
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

  /// Build plan description
  Widget _buildPlanDescription(BuildContext context, InvestmentPlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'aboutThisPlan'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          plan.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
        ),
      ],
    );
  }

  /// Build plan details
  Widget _buildPlanDetails(BuildContext context, InvestmentPlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'planDetails'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              // Management fee
              _buildDetailRow(
                context: context,
                title: 'managementFee'.tr(),
                value: '${plan.managementFeePercentage}%',
              ),
              const Divider(),

              // Min investment
              _buildDetailRow(
                context: context,
                title: 'minimumInvestment'.tr(),
                value: '\$${plan.minAmount.toStringAsFixed(2)}',
              ),

              // Max investment (if applicable)
              if (plan.maxAmount != null) ...[
                const Divider(),
                _buildDetailRow(
                  context: context,
                  title: 'maximumInvestment'.tr(),
                  value: '\$${plan.maxAmount!.toStringAsFixed(2)}',
                ),
              ],

              const Divider(),

              // Min duration
              _buildDetailRow(
                context: context,
                title: 'minimumDuration'.tr(),
                value:
                    '${plan.minDurationMonths} ${plan.minDurationMonths == 1 ? 'month'.tr() : 'months'.tr()}',
              ),

              // Max duration (if applicable)
              if (plan.maxDurationMonths != null) ...[
                const Divider(),
                _buildDetailRow(
                  context: context,
                  title: 'maximumDuration'.tr(),
                  value:
                      '${plan.maxDurationMonths!} ${plan.maxDurationMonths == 1 ? 'month'.tr() : 'months'.tr()}',
                ),
              ],

              const Divider(),

              // Risk level
              _buildDetailRow(
                context: context,
                title: 'riskLevel'.tr(),
                value: plan.riskLevel.translationKey.tr(),
                valueColor: plan.riskLevel.color,
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

  /// Build historical performance section
  Widget _buildHistoricalPerformance(
      BuildContext context, InvestmentPlanModel plan) {
    // Sort historical performance by date
    final sortedPerformance =
        List<HistoricalPerformance>.from(plan.historicalPerformance)
          ..sort((a, b) => a.date.compareTo(b.date));

    // Create chart data
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedPerformance.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedPerformance[i].returnPercentage));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'historicalPerformance'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              // Chart
              SizedBox(
                height: 200,
                child: LineChart(
                  _createPerformanceChartData(spots, sortedPerformance),
                ),
              ),
              const SizedBox(height: 16),

              // Performance table
              Column(
                children: [
                  // Table header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'date'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'return'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
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

                  // Table rows
                  ...sortedPerformance.reversed.take(6).map((performance) {
                    final isPositive = performance.returnPercentage >= 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              DateFormat('MMM yyyy').format(performance.date),
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${isPositive ? '+' : ''}${performance.returnPercentage.toStringAsFixed(2)}%',
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
            ],
          ),
        ),
      ],
    );
  }

  /// Create performance chart data
  LineChartData _createPerformanceChartData(
    List<FlSpot> spots,
    List<HistoricalPerformance> performance,
  ) {
    // Find min and max values for Y axis
    double minY = 0;
    double maxY = 0;

    for (final spot in spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    // Add some padding to min and max
    minY = minY - 1;
    maxY = maxY + 1;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 2,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= performance.length || value.toInt() < 0) {
                return Container();
              }

              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(
                  DateFormat('MMM').format(performance[value.toInt()].date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              AppTheme.goldColor.withOpacity(0.5),
              AppTheme.goldDark,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.goldColor.withOpacity(0.3),
                AppTheme.goldDark.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
