import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/investment/providers/investment_provider.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';

/// Investment onboarding screen
class InvestmentOnboardingScreen extends StatefulWidget {
  const InvestmentOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentOnboardingScreen> createState() => _InvestmentOnboardingScreenState();
}

class _InvestmentOnboardingScreenState extends State<InvestmentOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _goToInvestmentDashboard,
                  child: Text(
                    'skip'.tr(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildOnboardingPage(
                    title: 'investmentOnboardingTitle1'.tr(),
                    description: 'investmentOnboardingDesc1'.tr(),
                    icon: Icons.trending_up,
                    context: context,
                  ),
                  _buildOnboardingPage(
                    title: 'investmentOnboardingTitle2'.tr(),
                    description: 'investmentOnboardingDesc2'.tr(),
                    icon: Icons.account_balance,
                    context: context,
                  ),
                  _buildOnboardingPage(
                    title: 'investmentOnboardingTitle3'.tr(),
                    description: 'investmentOnboardingDesc3'.tr(),
                    icon: Icons.monetization_on,
                    context: context,
                  ),
                  _buildOnboardingPage(
                    title: 'investmentOnboardingTitle4'.tr(),
                    description: 'investmentOnboardingDesc4'.tr(),
                    icon: Icons.security,
                    context: context,
                    showMinMaxAmounts: true,
                  ),
                ],
              ),
            ),

            // Page indicator and buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 4,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppTheme.primaryColor,
                      dotColor:
                          AppTheme.primaryColor.withAlpha(76), // 0.3 * 255 = 76
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next or Start Investing button
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
                      text: _currentPage == 3 ? 'startInvesting'.tr() : 'next'.tr(),
                      onPressed: _currentPage == 3 ? _goToInvestmentDashboard : _nextPage,
                      type: ButtonType.primary,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build onboarding page
  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required IconData icon,
    required BuildContext context,
    bool showMinMaxAmounts = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gold gradient
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title with gold color
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldDark,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          
          // Min and max investment amounts
          if (showMinMaxAmounts) ...[
            const SizedBox(height: 32),
            _buildAmountCard(
              title: 'minInvestmentAmount'.tr(),
              amount: '\$500',
              context: context,
            ),
            const SizedBox(height: 16),
            _buildAmountCard(
              title: 'maxInvestmentAmount'.tr(),
              amount: '\$100,000',
              context: context,
            ),
          ],
        ],
      ),
    );
  }
  
  // Build amount card
  Widget _buildAmountCard({
    required String title,
    required String amount,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldDark,
                ),
          ),
        ],
      ),
    );
  }

  // Go to next page
  void _nextPage() {
    _pageController.nextPage(
      duration: AppConstants.animationDurationMedium,
      curve: Curves.easeInOut,
    );
  }

  // Go to investment dashboard
  void _goToInvestmentDashboard() {
    // Mark that the user has seen the onboarding
    final investmentProvider = Provider.of<InvestmentProvider>(context, listen: false);
    investmentProvider.setHasSeenOnboarding();
    
    // Navigate to the investment dashboard
    Navigator.pushReplacementNamed(context, AppRoutes.investment);
  }
}
