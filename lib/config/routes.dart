import 'package:flutter/material.dart';
import 'package:golden_wallet/config/constants.dart';
import 'package:golden_wallet/features/auth/screens/phone_verification_screen.dart';
import 'package:golden_wallet/features/auth/screens/register_screen.dart';
import 'package:golden_wallet/features/auth/screens/reset_password_screen.dart';
import 'package:golden_wallet/features/catalog/screens/cart_screen.dart';
import 'package:golden_wallet/features/catalog/screens/checkout_screen.dart';
import 'package:golden_wallet/features/onboarding/screens/onboarding_screen.dart';
import 'package:golden_wallet/features/auth/screens/login_screen.dart';
import 'package:golden_wallet/features/auth/screens/forgot_password_screen.dart';
import 'package:golden_wallet/features/dashboard/screens/dashboard_screen.dart';
import 'package:golden_wallet/features/buy_sell/screens/buy_sell_screen.dart';
import 'package:golden_wallet/features/buy_sell/screens/gold_price_history_screen.dart';
import 'package:golden_wallet/features/settings/screens/settings_screen.dart';
import 'package:golden_wallet/features/transactions/screens/transaction_detail_screen.dart';
import 'package:golden_wallet/features/transactions/screens/transactions_screen.dart';
import 'package:golden_wallet/features/profile/screens/profile_screen.dart';
import 'package:golden_wallet/features/notifications/screens/notifications_screen.dart';
import 'package:golden_wallet/features/notifications/screens/notification_detail_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_dashboard_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_onboarding_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_plans_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_plan_detail_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_purchase_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_confirmation_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_success_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_detail_screen.dart';
import 'package:golden_wallet/features/investment/screens/investment_management_screen.dart';
import 'package:golden_wallet/features/deposit_withdraw/screens/deposit_withdraw_selection_screen.dart';
import 'package:golden_wallet/features/catalog/screens/catalog_screen.dart';
import 'package:golden_wallet/features/catalog/screens/product_detail_screen.dart';

/// Route configuration for the GoldenWallet application
class AppRoutes {
  // Define route names as constants
  static const String initial = '/';
  static const String onboarding = AppConstants.routeOnboarding;
  static const String login = AppConstants.routeLogin;
  static const String register = AppConstants.routeRegister;
  static const String forgotPassword = AppConstants.routeForgotPassword;
  static const String resetPassword = AppConstants.routeResetPassword;
  static const String phoneVerification = AppConstants.routePhoneVerification;
  static const String dashboard = AppConstants.routeDashboard;
  static const String buySell = AppConstants.routeBuySell;
  static const String goldPriceHistory = AppConstants.routeGoldPriceHistory;
  static const String depositWithdraw = AppConstants.routeDepositWithdraw;
  static const String catalog = AppConstants.routeCatalog;
  static const String cart = AppConstants.routeCart;
  static const String checkout = AppConstants.routeCheckout;

  static const String productDetail = AppConstants.routeProductDetail;
  static const String investment = AppConstants.routeInvestment;
  static const String investmentDetail = AppConstants.routeInvestmentDetail;
  static const String transactions = AppConstants.routeTransactions;
  static const String transactionDetail = AppConstants.routeTransactionDetail;
  static const String notifications = AppConstants.routeNotifications;
  static const String notificationDetail = AppConstants.routeNotificationDetail;
  static const String settings = AppConstants.routeSettings;
  static const String profile = AppConstants.routeProfile;

  // Investment routes
  static const String investmentOnboarding =
      AppConstants.routeInvestmentOnboarding;
  static const String investmentPlans = AppConstants.routeInvestmentPlans;
  static const String investmentPlanDetail =
      AppConstants.routeInvestmentPlanDetail;
  static const String investmentPurchase = AppConstants.routeInvestmentPurchase;
  static const String investmentConfirmation =
      AppConstants.routeInvestmentConfirmation;
  static const String investmentSuccess = AppConstants.routeInvestmentSuccess;
  static const String investmentManagement =
      AppConstants.routeInvestmentManagement;
  static const String admin = AppConstants.routeAdmin;
  static const String goldPriceManagement =
      AppConstants.routeGoldPriceManagement;

  // Define route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    // Extract route arguments if any
    final args = routeSettings.arguments;

    switch (routeSettings.name) {
      case initial:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        );

      case phoneVerification:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => PhoneVerificationScreen(phoneNumber: args),
          );
        }
        // Fallback if no phone number is provided
        return MaterialPageRoute(
          builder: (_) =>
              const PhoneVerificationScreen(phoneNumber: '+971 XX XXX XXXX'),
        );

      case buySell:
        return MaterialPageRoute(
          builder: (_) => const BuySellScreen(),
        );

     

      case goldPriceHistory:
        return MaterialPageRoute(
          builder: (_) => const GoldPriceHistoryScreen(),
        );

      case depositWithdraw:
        return MaterialPageRoute(
          builder: (_) => const DepositWithdrawSelectionScreen(),
        );

      case catalog:
        return MaterialPageRoute(
          builder: (_) => const CatalogScreen(),
        );

      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
        );

      case checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
        );

      case productDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: args),
          );
        }

        // Fallback if no product ID is provided
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Product not found'),
            ),
          ),
        );

      // Investment routes are now implemented below

      case transactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionsScreen(),
        );

      case transactionDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transactionId: args),
          );
        }
        // Fallback if no transaction ID is provided
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Transaction ID is required'),
            ),
          ),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      case notificationDetail:
        final notificationId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => NotificationDetailScreen(
            notificationId: notificationId,
          ),
        );

      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case investment:
        return MaterialPageRoute(
          builder: (_) => const InvestmentDashboardScreen(),
        );

      case investmentOnboarding:
        return MaterialPageRoute(
          builder: (_) => const InvestmentOnboardingScreen(),
        );

      case investmentPlans:
        return MaterialPageRoute(
          builder: (_) => const InvestmentPlansScreen(),
        );

      case investmentPlanDetail:
        final planId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => InvestmentPlanDetailScreen(
            planId: planId,
          ),
        );

      case investmentPurchase:
        final planId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => InvestmentPurchaseScreen(
            planId: planId,
          ),
        );

      case investmentConfirmation:
        final investmentData = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => InvestmentConfirmationScreen(
            investmentData: investmentData,
          ),
        );

      case investmentSuccess:
        final investmentData = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => InvestmentSuccessScreen(
            investmentData: investmentData,
          ),
        );

      case investmentDetail:
        final investmentId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => InvestmentDetailScreen(
            investmentId: investmentId,
          ),
        );

      // case investmentManagement:
      //   return MaterialPageRoute(
      //     builder: (_) => const InvestmentManagementScreen(),
      //   );

      case admin:
        // Placeholder for admin route - will be replaced with actual implementation
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Admin Screen - Placeholder'),
            ),
          ),
        );

      case goldPriceManagement:
        // Placeholder for gold price management route - will be replaced with actual implementation
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Gold Price Management Screen - Placeholder'),
            ),
          ),
        );

      default:
        // If the route is not defined, show an error page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${routeSettings.name} not found'),
            ),
          ),
        );
    }
  }
}
