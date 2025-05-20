import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/models/user_investment_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/features/investment/widgets/investment_plan_card.dart';
import 'package:golden_wallet/features/investment/widgets/user_investment_card.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Investment dashboard screen
class InvestmentDashboardScreen extends StatefulWidget {
  const InvestmentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentDashboardScreen> createState() =>
      _InvestmentDashboardScreenState();
}

class _InvestmentDashboardScreenState extends State<InvestmentDashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => _fetchData());
  }

  /// Fetch investment data
  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);

    // Check if the user has seen the onboarding
    await investmentProvider.initialize();

    // If this is the first time the user is visiting the investment tab and hasn't seen the onboarding,
    // navigate to the onboarding screen
    if (investmentProvider.isFirstTimeInvestmentVisit &&
        !investmentProvider.hasSeenOnboarding) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.investmentOnboarding);
        return;
      }
    }

    // Fetch investment plans and user investments
    await investmentProvider.fetchInvestmentPlans();
    await investmentProvider.fetchUserInvestments();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);
    final userInvestments = investmentProvider.userInvestments;
    final activeInvestmentPlans = investmentProvider.activeInvestmentPlans;
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'investments'.tr(),
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
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            color: AppTheme.goldDark,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.investmentOnboarding);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppTheme.goldDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portfolio summary
                _buildPortfolioSummary(context, userInvestments),
                const SizedBox(height: 24),

                // Performance chart
                _buildPerformanceChart(context, userInvestments),
                const SizedBox(height: 24),

                // Active investments
                _buildActiveInvestments(context, userInvestments),
                const SizedBox(height: 24),

                // Available investment plans
                _buildAvailableInvestmentPlans(context, activeInvestmentPlans),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.investmentPlans);
        },
        backgroundColor: AppTheme.goldDark,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build portfolio summary section
  Widget _buildPortfolioSummary(
      BuildContext context, List<UserInvestmentModel> userInvestments) {
    // Calculate total investment amount and current value
    double totalInvestment = 0;
    double totalCurrentValue = 0;

    for (final investment in userInvestments) {
      if (investment.status == InvestmentStatus.active ||
          investment.status == InvestmentStatus.pending) {
        totalInvestment += investment.amount;
        totalCurrentValue += investment.currentValue;
      }
    }

    // Calculate total profit and return percentage
    final totalProfit = totalCurrentValue - totalInvestment;
    final returnPercentage =
        totalInvestment > 0 ? (totalProfit / totalInvestment) * 100 : 0.0;

    return GoldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'portfolioSummary'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),

          // Total investment value
          Text(
            '\$${totalCurrentValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Return percentage
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: returnPercentage >= 0
                      ? AppTheme.successColor.withOpacity(0.2)
                      : AppTheme.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      returnPercentage >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: returnPercentage >= 0
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${returnPercentage >= 0 ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: returnPercentage >= 0
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'totalReturn'.tr(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Investment stats
          Row(
            children: [
              // Total invested
              Expanded(
                child: _buildPortfolioStatItem(
                  context: context,
                  title: 'totalInvested'.tr(),
                  value: '\$${totalInvestment.toStringAsFixed(2)}',
                  color: Colors.white,
                ),
              ),

              // Vertical divider
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),

              // Total profit
              Expanded(
                child: _buildPortfolioStatItem(
                  context: context,
                  title: 'totalProfit'.tr(),
                  value: '\$${totalProfit.toStringAsFixed(2)}',
                  color: totalProfit >= 0
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ),

              // Vertical divider
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),

              // Active investments
              Expanded(
                child: _buildPortfolioStatItem(
                  context: context,
                  title: 'activeInvestments'.tr(),
                  value: userInvestments
                      .where((i) =>
                          i.status == InvestmentStatus.active ||
                          i.status == InvestmentStatus.pending)
                      .length
                      .toString(),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build portfolio stat item
  Widget _buildPortfolioStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build performance chart section
  Widget _buildPerformanceChart(
      BuildContext context, List<UserInvestmentModel> userInvestments) {
    // Generate performance data
    final performanceData = _generatePerformanceData(userInvestments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'performanceOverTime'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.goldDark,
              ),
        ),
        const SizedBox(height: 16),

        // Chart
        CustomCard(
          child: Column(
            children: [
              // Time range selector
              Row(
                children: [
                  _buildTimeRangeButton(
                    context: context,
                    title: '1M',
                    isSelected: true,
                  ),
                  const SizedBox(width: 8),
                  _buildTimeRangeButton(
                    context: context,
                    title: '3M',
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildTimeRangeButton(
                    context: context,
                    title: '6M',
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildTimeRangeButton(
                    context: context,
                    title: '1Y',
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildTimeRangeButton(
                    context: context,
                    title: 'ALL',
                    isSelected: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart
              SizedBox(
                height: 200,
                child: LineChart(
                  _createLineChartData(performanceData),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build time range button
  Widget _buildTimeRangeButton({
    required BuildContext context,
    required String title,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        // Time range selection logic would go here
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? AppTheme.goldColor : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.goldDark : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Create line chart data
  LineChartData _createLineChartData(List<FlSpot> spots) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = 'JAN';
                  break;
                case 2:
                  text = 'MAR';
                  break;
                case 4:
                  text = 'MAY';
                  break;
                case 6:
                  text = 'JUL';
                  break;
                case 8:
                  text = 'SEP';
                  break;
                case 10:
                  text = 'NOV';
                  break;
                default:
                  return Container();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value == 0) return Container();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(
                  '\$${value.toInt()}K',
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
      maxX: 11,
      minY: 0,
      maxY: 6,
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

  /// Generate performance data for the chart
  List<FlSpot> _generatePerformanceData(
      List<UserInvestmentModel> userInvestments) {
    // This is a simplified mock implementation
    // In a real app, you would calculate this based on actual investment performance
    return [
      const FlSpot(0, 3),
      const FlSpot(1, 2.8),
      const FlSpot(2, 3.2),
      const FlSpot(3, 3.5),
      const FlSpot(4, 3.3),
      const FlSpot(5, 3.8),
      const FlSpot(6, 4.2),
      const FlSpot(7, 4.1),
      const FlSpot(8, 4.5),
      const FlSpot(9, 4.8),
      const FlSpot(10, 5.2),
      const FlSpot(11, 5.5),
    ];
  }

  /// Build active investments section
  Widget _buildActiveInvestments(
      BuildContext context, List<UserInvestmentModel> userInvestments) {
    final activeInvestments = userInvestments
        .where((investment) =>
            investment.status == InvestmentStatus.active ||
            investment.status == InvestmentStatus.pending)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title and view all button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'activeInvestments'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldDark,
                  ),
            ),
            if (activeInvestments.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.investmentManagement);
                },
                child: Text(
                  'viewAll'.tr(),
                  style: TextStyle(
                    color: AppTheme.goldDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Active investments list or empty state
        if (activeInvestments.isEmpty)
          _buildEmptyActiveInvestments(context)
        else
          Column(
            children: activeInvestments.map((investment) {
              final investmentProvider =
                  Provider.of<InvestmentProvider>(context, listen: false);
              final plan =
                  investmentProvider.getInvestmentPlanById(investment.planId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: UserInvestmentCard(
                  investment: investment,
                  plan: plan,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.investmentDetail,
                      arguments: investment.id,
                    );
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Build empty active investments state
  Widget _buildEmptyActiveInvestments(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: AppTheme.goldColor,
            ),
            const SizedBox(height: 16),
            Text(
              'noActiveInvestments'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'startInvestingNow'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                text: 'exploreInvestmentPlans'.tr(),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.investmentPlans);
                },
                type: ButtonType.primary,
                backgroundColor: Colors.transparent,
                textColor: Colors.white,
                width: 250,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build available investment plans section
  Widget _buildAvailableInvestmentPlans(
      BuildContext context, List<InvestmentPlanModel> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title and view all button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'availableInvestmentPlans'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldDark,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.investmentPlans);
              },
              child: Text(
                'viewAll'.tr(),
                style: TextStyle(
                  color: AppTheme.goldDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Investment plans list
        Column(
          children: plans.take(2).map((plan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InvestmentPlanCard(
                plan: plan,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.investmentPlanDetail,
                    arguments: plan.id,
                  );
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
