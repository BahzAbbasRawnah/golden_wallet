import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/user_investment_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/features/investment/widgets/user_investment_card.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';

/// Investment management screen
class InvestmentManagementScreen extends StatefulWidget {
  const InvestmentManagementScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentManagementScreen> createState() =>
      _InvestmentManagementScreenState();
}

class _InvestmentManagementScreenState extends State<InvestmentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Fetch investment data
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    await investmentProvider.fetchUserInvestments();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);
    final userInvestments = investmentProvider.userInvestments;
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    // Filter investments by status
    final activeInvestments = userInvestments
        .where((i) =>
            i.status == InvestmentStatus.active ||
            i.status == InvestmentStatus.pending)
        .toList();

    final completedInvestments = userInvestments
        .where((i) => i.status == InvestmentStatus.completed)
        .toList();

    final cancelledInvestments = userInvestments
        .where((i) => i.status == InvestmentStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'myInvestments'.tr(),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.goldDark,
          labelColor: AppTheme.goldDark,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[300]
              : Colors.grey[700],
          tabs: [
            Tab(text: 'active'.tr()),
            Tab(text: 'completed'.tr()),
            Tab(text: 'cancelled'.tr()),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: AppTheme.goldDark,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active investments tab
                  _buildInvestmentsList(
                    context: context,
                    investments: activeInvestments,
                    emptyMessage: 'noActiveInvestments'.tr(),
                    emptyDescription: 'startInvestingNow'.tr(),
                    showEmptyButton: true,
                  ),

                  // Completed investments tab
                  _buildInvestmentsList(
                    context: context,
                    investments: completedInvestments,
                    emptyMessage: 'noCompletedInvestments'.tr(),
                    emptyDescription: 'completedInvestmentsDescription'.tr(),
                  ),

                  // Cancelled investments tab
                  _buildInvestmentsList(
                    context: context,
                    investments: cancelledInvestments,
                    emptyMessage: 'noCancelledInvestments'.tr(),
                    emptyDescription: 'cancelledInvestmentsDescription'.tr(),
                  ),
                ],
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

  /// Build investments list
  Widget _buildInvestmentsList({
    required BuildContext context,
    required List<UserInvestmentModel> investments,
    required String emptyMessage,
    required String emptyDescription,
    bool showEmptyButton = false,
  }) {
    if (investments.isEmpty) {
      return _buildEmptyState(
        context: context,
        message: emptyMessage,
        description: emptyDescription,
        showButton: showEmptyButton,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: investments.length,
      itemBuilder: (context, index) {
        final investment = investments[index];
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
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState({
    required BuildContext context,
    required String message,
    required String description,
    bool showButton = false,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
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
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              if (showButton) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}
