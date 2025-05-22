import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan.dart';
import 'package:golden_wallet/features/investment/models/historical_performance.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Investment plan detail screen
class InvestmentPlanDetailScreen extends StatefulWidget {
  final String planId;

  const InvestmentPlanDetailScreen({
    super.key,
    required this.planId,
  });

  @override
  State<InvestmentPlanDetailScreen> createState() =>
      _InvestmentPlanDetailScreenState();
}

class _InvestmentPlanDetailScreenState
    extends State<InvestmentPlanDetailScreen> {
  // Sample historical performance data (in a real app, this would come from the API)
  final List<HistoricalPerformance> _historicalPerformance = [
    HistoricalPerformance(
      date: DateTime.now().subtract(const Duration(days: 180)),
      returnPercentage: 3.2,
    ),
    HistoricalPerformance(
      date: DateTime.now().subtract(const Duration(days: 150)),
      returnPercentage: 3.5,
    ),
    HistoricalPerformance(
      date: DateTime.now().subtract(const Duration(days: 120)),
      returnPercentage: 3.1,
    ),
    HistoricalPerformance(
      date: DateTime.now().subtract(const Duration(days: 90)),
      returnPercentage: 3.8,
    ),
    HistoricalPerformance(
      date: DateTime.now().subtract(const Duration(days: 60)),
      returnPercentage: 4.2,
    ),
    HistoricalPerformance(
      date: DateTime.now().subtract(const Duration(days: 30)),
      returnPercentage: 4.5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);

    return FutureBuilder<InvestmentPlan?>(
      future: investmentProvider.getInvestmentPlanById(widget.planId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        final plan = snapshot.data;

        if (plan == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'investmentPlanNotFound'.tr(),
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
                _buildHistoricalPerformance(context),
                const SizedBox(height: 32),

                // Invest button
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                            0x47D4AF37), // AppTheme.primaryColor with 70 alpha
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
                        AppRoutes.investmentConfirmation,
                        arguments: widget.planId,
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
      },
    );
  }

  /// Build plan header
  Widget _buildPlanHeader(BuildContext context, InvestmentPlan plan) {
    final theme = Theme.of(context);

    return CustomCard(
      gradient: AppTheme.investmentGradient,
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
                  color: const Color(0x33FFFFFF), // White with 20% opacity
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentFrequencyIcon(plan.paymentFrequency),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plan.paymentFrequency.translationKey.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                  color: plan.riskLevel.color.withAlpha(51),
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: plan.riskLevel.color,
                        fontWeight: FontWeight.bold,
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
            '${_calculateAverageReturn(plan).toStringAsFixed(1)}%',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'expectedAnnualReturns'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xCCFFFFFF), // White with 80% opacity
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            const Color(0xCCFFFFFF), // White with 80% opacity
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.currency} ${plan.minInvestment.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            const Color(0xCCFFFFFF), // White with 80% opacity
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.duration.min} ${plan.duration.min == 1 ? 'month'.tr() : 'months'.tr()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
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

  /// Build plan description
  Widget _buildPlanDescription(BuildContext context, InvestmentPlan plan) {
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
  Widget _buildPlanDetails(BuildContext context, InvestmentPlan plan) {
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
              // Management fee (assumed to be 1% for all plans)
              _buildDetailRow(
                context: context,
                title: 'managementFee'.tr(),
                value: '1.0%',
              ),
              const Divider(),

              // Min investment
              _buildDetailRow(
                context: context,
                title: 'minimumInvestment'.tr(),
                value:
                    '${plan.currency} ${plan.minInvestment.toStringAsFixed(2)}',
              ),
              const Divider(),

              // Min duration
              _buildDetailRow(
                context: context,
                title: 'minimumDuration'.tr(),
                value:
                    '${plan.duration.min} ${plan.duration.min == 1 ? 'month'.tr() : 'months'.tr()}',
              ),
              const Divider(),

              // Max duration
              _buildDetailRow(
                context: context,
                title: 'maximumDuration'.tr(),
                value:
                    '${plan.duration.max} ${plan.duration.max == 1 ? 'month'.tr() : 'months'.tr()}',
              ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? const Color(0xFFD3D3D3) // Light grey for dark mode
                  : const Color(0xFF707070), // Dark grey for light mode
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build historical performance section
  Widget _buildHistoricalPerformance(BuildContext context) {
    // Sort historical performance by date
    final sortedPerformance =
        List<HistoricalPerformance>.from(_historicalPerformance)
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(
                                              0xFFD3D3D3) // Light grey for dark mode
                                          : const Color(
                                              0xFF707070), // Dark grey for light mode
                                    ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'return'.tr(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(
                                              0xFFD3D3D3) // Light grey for dark mode
                                          : const Color(
                                              0xFF707070), // Dark grey for light mode
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(
                                            0xFFD3D3D3) // Light grey for dark mode
                                        : const Color(
                                            0xFF707070), // Dark grey for light mode
                                  ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${isPositive ? '+' : ''}${performance.returnPercentage.toStringAsFixed(2)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
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
                  }),
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
            color: const Color(0x33808080), // Grey with 20% opacity
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
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
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFBDBDBD) // Light grey for dark mode
                        : const Color(0xFF757575), // Dark grey for light mode
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
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFBDBDBD) // Light grey for dark mode
                        : const Color(0xFF757575), // Dark grey for light mode
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
              const Color(0x80D4AF37), // AppTheme.goldColor with 50% opacity
              AppTheme.goldDark,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0x4DD4AF37), // AppTheme.goldColor with 30% opacity
                const Color(0x00B8860B), // AppTheme.goldDark with 0% opacity
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  /// Get icon for payment frequency
  IconData _getPaymentFrequencyIcon(PaymentFrequency frequency) {
    switch (frequency) {
      case PaymentFrequency.one_time:
        return Icons.payment;
      case PaymentFrequency.monthly:
        return Icons.calendar_month;
      case PaymentFrequency.quarterly:
        return Icons.date_range;
      case PaymentFrequency.semi_annually:
        return Icons.calendar_view_month;
      case PaymentFrequency.annually:
        return Icons.calendar_today;
    }
  }

  /// Calculate average return for a plan
  double _calculateAverageReturn(InvestmentPlan plan) {
    return (plan.expectedReturns.min + plan.expectedReturns.max) / 2;
  }
}
