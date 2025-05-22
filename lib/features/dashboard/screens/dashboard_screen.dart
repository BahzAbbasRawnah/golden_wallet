import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/transactions/screens/transactions_screen.dart';
import 'package:golden_wallet/features/profile/screens/profile_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_dashboard_screen.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/features/notifications/providers/notification_provider.dart';
import 'package:golden_wallet/features/catalog/screens/catalog_screen.dart';
import 'package:golden_wallet/features/notifications/widgets/notification_item.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Dashboard screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTimeRange = 0; // 0: 7 days, 1: 30 days, 2: 90 days
  int _selectedNavIndex = 0;
  bool _firstTimeInvestmentTab = true;

  // List of screens for bottom navigation
  List<Widget>? _screens;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // We'll initialize screens in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_initialized) {
      _screens = [
        _buildHomeScreen(),
        _buildCatalogScreen(),
        _buildInvestmentScreen(),
        const TransactionsScreen(),
        _buildProfileScreen(),
      ];
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If screens aren't initialized yet, show a loading indicator
    if (_screens == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedNavIndex,
        children: _screens!,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Build home screen (dashboard)
  Widget _buildHomeScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              _buildAppBar(context),
              const SizedBox(height: 24),

              // Wallet balance card
              _buildWalletBalanceCard(context),
              const SizedBox(height: 24),

              // Transaction history
              _buildTransactionHistory(context),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Latest gold price
              _buildLatestGoldPrice(context),
            ],
          ),
        ),
      ),
    );
  }

  // Build catalog screen
  Widget _buildCatalogScreen() {
    return const CatalogScreen();
  }

  // Build investment screen
  Widget _buildInvestmentScreen() {
    return const InvestmentDashboardScreen();
  }

  // Build profile screen
  Widget _buildProfileScreen() {
    return const ProfileScreen();
  }

  // Build app bar
  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'welcome'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'welcomeMessage'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                  ),
            ),
          ],
        ),
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                  icon: const Icon(Icons.notifications_outlined),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    final unreadCount = provider.unreadCount;
                    if (unreadCount == 0) return const SizedBox.shrink();

                    return Positioned(
                      top: 8,
                      right: 8,
                      child: NotificationBadge(
                        count: unreadCount,
                        size: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor:
                    AppTheme.primaryColor.withAlpha(51), // 0.2 opacity = 51/255
                child: const Icon(
                  Icons.person_outline,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build wallet balance card
  Widget _buildWalletBalanceCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFD700), // Gold
          Color(0xFFDAA520), // Golden rod
        ],
      ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(70),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'walletBalance'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+5.2%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$24,680.00',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    context: context,
                    title: 'goldBalance'.tr(),
                    value: '12.45 oz',
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceItem(
                    context: context,
                    title: 'cashBalance'.tr(),
                    value: '\$5,240.00',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build balance item
  Widget _buildBalanceItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51), // 0.2 opacity = 51/255
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(77), // 0.3 opacity = 77/255
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white
                            .withAlpha(204), // 0.8 opacity = 204/255
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build transaction history
  Widget _buildTransactionHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'transactionHistory'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.transactions);
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

        // Time range selector
        Row(
          children: [
            _buildTimeRangeButton(
              context: context,
              title: 'last7Days'.tr(),
              index: 0,
            ),
            const SizedBox(width: 12),
            _buildTimeRangeButton(
              context: context,
              title: 'last30Days'.tr(),
              index: 1,
            ),
            const SizedBox(width: 12),
            _buildTimeRangeButton(
              context: context,
              title: 'last90Days'.tr(),
              index: 2,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chart
        SizedBox(
          height: 200,
          child: LineChart(
            _mainData(),
          ),
        ),
      ],
    );
  }

  // Build time range button
  Widget _buildTimeRangeButton({
    required BuildContext context,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedTimeRange == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeRange = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Build quick actions
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'quickActions'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldDark,
                  ),
            ),
            Text(
              'goldShop'.tr(),
              style: TextStyle(
                color: AppTheme.goldDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF1E1E1E)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.secondaryGrey
                  : AppTheme.secondaryLightGrey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                context: context,
                title: 'buy'.tr(),
                icon: Icons.add_circle_outline,
                color: AppTheme.goldColor,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.buySell);
                },
              ),
              _buildQuickActionItem(
                context: context,
                title: 'sell'.tr(),
                icon: Icons.remove_circle_outline,
                color: AppTheme.accentColor,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.buySell);
                },
              ),
              _buildQuickActionItem(
                context: context,
                title: 'deposit'.tr(),
                icon: Icons.arrow_downward,
                color: AppTheme.successColor,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.depositWithdraw);
                },
              ),
              _buildQuickActionItem(
                context: context,
                title: 'withdraw'.tr(),
                icon: Icons.arrow_upward,
                color: AppTheme.warningColor,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.depositWithdraw);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build quick action item
  Widget _buildQuickActionItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha(25), // 0.1 opacity (25/255)
              shape: BoxShape.rectangle,
              border: Border.all(
                color: color.withAlpha(50),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[800],
                ),
          ),
        ],
      ),
    );
  }

  // Build latest gold price
  Widget _buildLatestGoldPrice(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'latestGoldPrice'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.goldPriceHistory);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withAlpha(25), // 0.1 opacity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        color: AppTheme.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '2.3%',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGoldPriceItem(
                context: context,
                title: '24K',
                price: '\$2,245.67',
                change: '+1.2%',
                isPositive: true,
              ),
              _buildGoldPriceItem(
                context: context,
                title: '22K',
                price: '\$2,058.30',
                change: '+1.1%',
                isPositive: true,
              ),
              _buildGoldPriceItem(
                context: context,
                title: '18K',
                price: '\$1,684.25',
                change: '+0.9%',
                isPositive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build gold price item
  Widget _buildGoldPriceItem({
    required BuildContext context,
    required String title,
    required String price,
    required String change,
    required bool isPositive,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(25), // 0.1 opacity
            shape: BoxShape.circle,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryDarkColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          price,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          change,
          style: TextStyle(
            color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Set flag for first time investment tab visit
  Future<void> _setFirstTimeInvestmentVisit() async {
    if (!mounted) return;

    // Update the investment provider
    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    await investmentProvider.setFirstTimeInvestmentVisit();
  }

  // Build bottom navigation bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        // Handle navigation
        setState(() {
          // Check if this is the first time navigating to the investment tab (index 2)
          if (index == 2 && _firstTimeInvestmentTab) {
            _firstTimeInvestmentTab = false;
            _setFirstTimeInvestmentVisit();
          }

          _selectedNavIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]
          : Colors.grey[600],
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Color(0xFF1E1E1E)
          : Colors.white,
      elevation: 8,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: 'home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag_outlined),
          activeIcon: const Icon(Icons.shopping_bag),
          label: 'catalog'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.trending_up_outlined),
          activeIcon: const Icon(Icons.trending_up),
          label: 'investments'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          activeIcon: const Icon(Icons.receipt_long),
          label: 'transactions'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: 'profile'.tr(),
        ),
      ],
    );
  }

  // Main chart data
  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
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
              final style = TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              );
              String text;
              // Using short day names that don't need translation
              // as they are standard abbreviations
              switch (value.toInt()) {
                case 0:
                  text = 'Mon';
                  break;
                case 2:
                  text = 'Wed';
                  break;
                case 4:
                  text = 'Fri';
                  break;
                case 6:
                  text = 'Sun';
                  break;
                default:
                  return Container();
              }
              return Text(text, style: style);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final style = TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              );
              String text;
              switch (value.toInt()) {
                case 1:
                  text = '1K';
                  break;
                case 3:
                  text = '3K';
                  break;
                case 5:
                  text = '5K';
                  break;
                default:
                  return Container();
              }
              return Text(text, style: style);
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 2),
            FlSpot(2, 4),
            FlSpot(3, 3.5),
            FlSpot(4, 4.5),
            FlSpot(5, 3.8),
            FlSpot(6, 5),
          ],
          isCurved: true,
          color: AppTheme.goldDark,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.goldColor.withAlpha(50), // 0.2 opacity
          ),
        ),
      ],
    );
  }
}
