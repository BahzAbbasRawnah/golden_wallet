import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/models/investment_plan_model.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/features/investment/widgets/investment_plan_card.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';
import 'package:golden_wallet/shared/widgets/custom_card.dart';

/// Investment plans screen
class InvestmentPlansScreen extends StatefulWidget {
  const InvestmentPlansScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentPlansScreen> createState() => _InvestmentPlansScreenState();
}

class _InvestmentPlansScreenState extends State<InvestmentPlansScreen> {
  bool _isLoading = false;
  RiskLevel? _selectedRiskLevel;
  InvestmentPlanType? _selectedPlanType;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Fetch investment plans
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final investmentProvider =
        Provider.of<InvestmentProvider>(context, listen: false);
    await investmentProvider.fetchInvestmentPlans();

    setState(() {
      _isLoading = false;
    });
  }

  /// Clear filters
  void _clearFilters() {
    setState(() {
      _selectedRiskLevel = null;
      _selectedPlanType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context);
    final plans = investmentProvider.activeInvestmentPlans;
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    // Apply filters
    var filteredPlans = plans;
    if (_selectedRiskLevel != null) {
      filteredPlans = filteredPlans
          .where((plan) => plan.riskLevel == _selectedRiskLevel)
          .toList();
    }
    if (_selectedPlanType != null) {
      filteredPlans = filteredPlans
          .where((plan) => plan.type == _selectedPlanType)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'investmentPlans'.tr(),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
              ),
            )
          : Column(
              children: [
                // Filters
                _buildFilters(context),

                // Plans list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchData,
                    color: AppTheme.goldDark,
                    child: filteredPlans.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredPlans.length,
                            itemBuilder: (context, index) {
                              final plan = filteredPlans[index];

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
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Build filters section
  Widget _buildFilters(BuildContext context) {
    final hasFilters = _selectedRiskLevel != null || _selectedPlanType != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter title and clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'filters'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasFilters)
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'clearAll'.tr(),
                    style: TextStyle(
                      color: AppTheme.goldDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Risk level filters
                ...RiskLevel.values.map((riskLevel) {
                  final isSelected = _selectedRiskLevel == riskLevel;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(riskLevel.translationKey.tr()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRiskLevel = selected ? riskLevel : null;
                        });
                      },
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                      selectedColor: riskLevel.color.withOpacity(0.2),
                      checkmarkColor: riskLevel.color,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? riskLevel.color
                            : Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 8),

                // Plan type filters
                ...InvestmentPlanType.values.map((planType) {
                  final isSelected = _selectedPlanType == planType;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(planType.translationKey.tr()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPlanType = selected ? planType : null;
                        });
                      },
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                      selectedColor: AppTheme.goldColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.goldDark,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.goldDark
                            : Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
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
                Icons.search_off,
                size: 60,
                color: AppTheme.goldColor,
              ),
              const SizedBox(height: 16),
              Text(
                'noPlansFound'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'tryDifferentFilters'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'clearFilters'.tr(),
                onPressed: _clearFilters,
                icon: Icons.filter_list_off,
                type: ButtonType.secondary,
                textColor: AppTheme.goldDark,
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
